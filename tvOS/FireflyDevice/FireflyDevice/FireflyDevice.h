//
//  FireflyDevice.h
//  FireflyDevice
//
//  Created by Denis Bohm on 2/14/16.
//  Copyright © 2016 Firefly Design. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for FireflyDevice.
FOUNDATION_EXPORT double FireflyDeviceVersionNumber;

//! Project version string for FireflyDevice.
FOUNDATION_EXPORT const unsigned char FireflyDeviceVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <FireflyDevice/PublicHeader.h>

#import <FireflyDevice/FDHardwareId.h>
#import <FireflyDevice/FDBundle.h>
#import <FireflyDevice/FDBundleManager.h>
#import <FireflyDevice/FDFireflyDeviceLogger.h>
#import <FireflyDevice/FDFileLog.h>
#import <FireflyDevice/FDBinary.h>
#import <FireflyDevice/FDCrypto.h>
#import <FireflyDevice/FDDetour.h>
#import <FireflyDevice/FDDetourSource.h>
#import <FireflyDevice/FDIntelHex.h>
#import <FireflyDevice/FDObservable.h>
#import <FireflyDevice/FDExecutor.h>
#import <FireflyDevice/FDFireflyIce.h>
#import <FireflyDevice/FDFireflyIceChannel.h>
#if !TARGET_OS_WATCH
#import <FireflyDevice/FDFireflyIceChannelBLE.h>
#import <FireflyDevice/FDFireflyIceManager.h>
#endif
#if !TARGET_OS_IPHONE && !TARGET_OS_WATCH
#import <FireflyDevice/FDFireflyIceChannelUSB.h>
#import <FireflyDevice/FDUSBHIDMonitor.h>
#endif
#import <FireflyDevice/FDFireflyIceChannelMock.h>
#import <FireflyDevice/FDFireflyIceCoder.h>
#import <FireflyDevice/FDFireflyIceTaskSteps.h>
#import <FireflyDevice/FDGZIP.h>
#import <FireflyDevice/FDHelloTask.h>
#import <FireflyDevice/FDPullTask.h>
#import <FireflyDevice/FDSyncTask.h>
#import <FireflyDevice/FDFirmwareUpdateTask.h>
#import <FireflyDevice/FDFireflyIceSimpleTask.h>
#import <FireflyDevice/FDJSON.h>
#import <FireflyDevice/FDWeak.h>
#import <FireflyDevice/FDVMADecoder.h>
#import <FireflyDevice/FDIEEE754.h>
#import <FireflyDevice/FDFireflyIceChannelSocket.h>
#import <FireflyDevice/FDFireflyIceService.h>
#import <FireflyDevice/FDFireflyIceServiceBrowser.h>
