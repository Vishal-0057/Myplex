//
//  UIDeviceHardware.h
//

#import <Foundation/Foundation.h>

typedef enum UIDeviceCaps {
    UIDeviceLowEnd,
    UIDeviceMid,
    UIDeviceHighEnd
} UIDeviceCapabilities;



@interface UIDeviceHardware : NSObject

+ (NSString *) platform;
+ (NSString *) platformString;
+ (UIDeviceCapabilities)capabilities;

@end
