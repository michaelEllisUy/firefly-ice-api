//
//  FDHelloTask.m
//  FireflyDevice
//
//  Created by Denis Bohm on 10/6/13.
//  Copyright (c) 2013-2014 Firefly Design LLC / Denis Bohm. All rights reserved.
//

#import "FDFireflyIceCoder.h"
#import "FDHelloTask.h"
#import "FDFireflyDeviceLogger.h"

#define _log self.fireflyIce.log

@interface FDHelloTask ()

@property NSTimeInterval maxOffset;

@property NSMutableSet *selectorNames;
@property uint32_t properties;

@property NSDate *time;
@property FDFireflyIceReset *reset;

@end

@implementation FDHelloTask

+ (FDHelloTask *)helloTask:(FDFireflyIce *)fireflyIce channel:(id<FDFireflyIceChannel>)channel delegate:(id<FDHelloTaskDelegate>)delegate
{
    FDHelloTask *helloTask = [[FDHelloTask alloc] init];
    helloTask.fireflyIce = fireflyIce;
    helloTask.channel = channel;
    helloTask.delegate = delegate;
    return helloTask;
}

- (id)init
{
    if (self = [super init]) {
        self.priority = 100;
        _maxOffset = 120;
        _propertyValues = [NSMutableDictionary dictionary];
        _selectorNames = [NSMutableSet set];
        
        [self queryProperty:FD_CONTROL_PROPERTY_VERSION delegateMethodName:@"fireflyIce:channel:version:"];
        [self queryProperty:FD_CONTROL_PROPERTY_BOOT_VERSION delegateMethodName:@"fireflyIce:channel:bootVersion:"];
        [self queryProperty:FD_CONTROL_PROPERTY_HARDWARE_ID delegateMethodName:@"fireflyIce:channel:hardwareId:"];
        [self queryProperty:FD_CONTROL_PROPERTY_RTC delegateMethodName:@"fireflyIce:channel:time:"];
        [self queryProperty:FD_CONTROL_PROPERTY_RESET delegateMethodName:@"fireflyIce:channel:reset:"];
    }
    return self;
}

- (void)queryProperty:(uint32_t)property delegateMethodName:(NSString *)delegateMethodName
{
    _properties |= property;
    [_selectorNames addObject:delegateMethodName];
}

- (BOOL)respondsToSelector:(SEL)selector {
    if ([super respondsToSelector:selector]) {
        return YES;
    }
    
    NSString *selectorName = NSStringFromSelector(selector);
    return [_selectorNames containsObject:selectorName];
}

- (void)forwardInvocation:(NSInvocation *)invocation  {
    SEL selector = invocation.selector;
    NSString *selectorName = NSStringFromSelector(selector);
    NSArray *parts = [selectorName componentsSeparatedByString:@":"];
    NSString *key = parts[2];
    __unsafe_unretained id object;
    [invocation getArgument:&object atIndex:4];
    
    [_propertyValues setObject:object forKey:key];
}

- (void)executorTaskStarted:(FDExecutor *)executor
{
    [super executorTaskStarted:executor];
    
    [self.fireflyIce.coder sendGetProperties:self.channel properties:_properties];
    [self next:@selector(checkVersion)];
}

- (void)checkVersion
{
    FDFireflyIceVersion *version = _propertyValues[@"version"];
    FDFireflyIceHardwareId *hardwareId = _propertyValues[@"hardwareId"];
    FDFireflyIceVersion *bootVersion = _propertyValues[@"bootVersion"];
    NSDate *time = _propertyValues[@"time"];
    FDFireflyIceReset *reset = _propertyValues[@"reset"];
    
    if ((version == nil) || (hardwareId == nil)) {
        NSString *description = NSLocalizedString(@"Incomplete information received on initial communication with the device", @"");
        FDFireflyDeviceLogInfo(description);
        [self.channel close];
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: description,
                                   NSLocalizedRecoveryOptionsErrorKey: NSLocalizedString(@"Make sure the device stays in close range", @"")
                                   };
        NSError *error = [NSError errorWithDomain:FDHelloTaskErrorDomain code:FDHelloTaskErrorCodeIncomplete userInfo:userInfo];
        [self.fireflyIce.executor fail:self error:error];
        return;
    }
    
    self.fireflyIce.version = version;
    self.fireflyIce.bootVersion = bootVersion;
    self.fireflyIce.hardwareId = hardwareId;
    self.time = time;
    self.reset = reset;
    
    if (self.fireflyIce.version.capabilities & FD_CONTROL_CAPABILITY_BOOT_VERSION) {
        [self.fireflyIce.coder sendGetProperties:self.channel properties:FD_CONTROL_PROPERTY_BOOT_VERSION];
        [self next:@selector(checkTime)];
    } else {
        [self checkTime];
    }
}

- (void)setTime
{
    FDFireflyDeviceLogInfo(@"setting the time");
    [self.fireflyIce.coder sendSetPropertyTime:self.channel time:[NSDate date]];
}

- (void)checkTime
{
    FDFireflyDeviceLogInfo(@"hello (hardware %@) (firmware %@)", self.fireflyIce.hardwareId, self.fireflyIce.version);
    
    if (_time == nil) {
        FDFireflyDeviceLogInfo(@"time not set for hw %@ fw %@ (last reset %@)", self.fireflyIce.hardwareId, self.fireflyIce.version, _reset);
        [self setTime];
    } else {
        NSTimeInterval offset = [_time timeIntervalSinceDate:[NSDate date]];
        if (fabs(offset) > _maxOffset) {
            FDFireflyDeviceLogInfo(@"time is off by %0.3f seconds for hw %@ fw %@ (last reset %@)", offset, self.fireflyIce.hardwareId, self.fireflyIce.version, _reset);
            [self setTime];
        } else {
//            FDFireflyDeviceLogDebug(@"time is off by %0.3f seconds for hw %@ fw %@", offset, self.fireflyIce.hardwareId, self.fireflyIce.version);
        }
    }
    [self done];
}

- (void)executorTaskCompleted:(FDExecutor *)executor
{
    [super executorTaskCompleted:executor];
    [_delegate helloTaskSuccess:self];
}

- (void)executorTaskFailed:(FDExecutor *)executor error:(NSError *)error
{
    [super executorTaskFailed:executor error:error];
    [_delegate helloTask:self error:error];
}

@end
