//
//  FDDetourSource.m
//  FireflyDevice
//
//  Created by Denis Bohm on 5/3/13.
//  Copyright (c) 2013-2014 Firefly Design LLC / Denis Bohm. All rights reserved.
//

#import <FireflyDevice/FDDetourSource.h>

@interface FDDetourSource ()

@property NSUInteger size;
@property NSData *data;
@property NSUInteger index;
@property uint8_t sequenceNumber;


@end

@implementation FDDetourSource

- (id)initWithSize:(NSUInteger)size data:(NSData *)data
{
    if (self = [super init]) {
        _size = size;
        uint16_t length = data.length;
        uint8_t bytes[2] = {length, length >> 8};
        NSMutableData *content = [NSMutableData dataWithBytes:bytes length:sizeof(bytes)];
        [content appendData:data];
        _data = content;
    }
    return self;
}

- (NSData *)next
{
    if (_index >= _data.length) {
        if (_endDate == nil) {
            _endDate = [NSDate date];
            
            NSUInteger rate = 0;
            NSTimeInterval duration = [_endDate timeIntervalSinceDate:_startDate];
            if (duration > 0.0) {
                rate = (NSUInteger)(_data.length / duration);
            }
//            NSLog(@"detour source success: %lu B (%lu B/s)", (unsigned long)_data.length, (unsigned long)rate);
        }
        return nil;
    }
    
    if (_startDate == nil) {
        _startDate = [NSDate date];
    }
    NSUInteger n = _data.length - _index;
    if (n > (_size - 1)) {
        n = _size - 1;
    }
    NSMutableData *subdata = [NSMutableData dataWithBytes:&_sequenceNumber length:1];
    [subdata appendData:[_data subdataWithRange:NSMakeRange(_index, n)]];
    _index += n;
    ++_sequenceNumber;
    return subdata;
}

@end
