//
//  RegisterDevice.m
//  Myplex
//
//  Created by shiva on 9/14/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "RegisterDevice.h"
#import "Notifications.h"
#import "ServerStandardRequest.h"
#import "NSManagedObject+Utils.h"
#import "AppData.h"
#import "NSNotificationCenter+Utils.h"

static NSString* kMake = @"Apple Inc";
static NSString* kClientSecret = @"ApalyaiOS";
static NSString* kClientProfile = @"Work";
static NSString* kClientOS = @"iOS";

static NSString* kRegisterDeviceSerialNumber = @"serialNo";
static NSString* kRegisterDeviceOS = @"os";
static NSString* kRegisterDeviceOSVersion = @"osVersion";
static NSString* kRegisterDeviceMake = @"make";
static NSString* kRegisterDeviceModel = @"model";
static NSString* kRegisterDeviceResolution = @"resolution";
static NSString* kRegisterDeviceClientSecret = @"clientSecret";
static NSString* kRegisterDeviceProfile = @"profile";
static NSString* kDeviceRegistrationStatusCode = @"code";
static NSString* kDeviceRegistrationResult = @"result";

@implementation RegisterDevice {
    NSManagedObjectContext* _managedObjectContext;
}

- (id)initWithManagedObjectContext: (NSManagedObjectContext*)moc
{
	self = [super init];
	if (self) {
		_managedObjectContext = moc;
	}
	
	return self;
}

-(void)registerDeviceWithSerialNumber:(NSString *)serialNumber osName:(NSString *)osName osVersion:(NSString *)osVersion model:(NSString *)model resolution:(NSString *)resolution
{
    
	NSDictionary* userData = @{kRegisterDeviceSerialNumber: serialNumber, kRegisterDeviceOS: kClientOS, kRegisterDeviceOSVersion: osVersion, kRegisterDeviceMake: kMake,kRegisterDeviceModel: model, kRegisterDeviceResolution: resolution, kRegisterDeviceClientSecret: kClientSecret,kRegisterDeviceProfile:kClientProfile};
    NSMutableDictionary* mutableUserData = [NSMutableDictionary dictionaryWithDictionary: userData];
    
	//When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void) [[ServerStandardRequest alloc] initWithPath:@"/user/v2/registerDevice" jsonData: mutableUserData requestType: ServerStandardRequestTypeCreate completionHandler: ^(NSDictionary* jsonResponse, NSError* error) {
		
		if (error) {
            
            // already written in log, if cleanup is needed, do it here
            //[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationError object:error];
		} else {
            
            //BOOL authenticatedOnly = NO;
            if ([jsonResponse[kDeviceRegistrationStatusCode]integerValue] == 200 || [jsonResponse[kDeviceRegistrationStatusCode]integerValue] == 201) {
                
                [[[AppData shared]data]setObject:jsonResponse[@"deviceId"] forKey:@"deviceId"];
                [[[AppData shared]data]setObject:jsonResponse[@"clientKey"] forKey:@"clientKey"];
                [[[AppData shared]data]setObject:jsonResponse[@"expiresAt"] forKey:@"expiresAt"];
                [[AppData shared]save];

               // authenticatedOnly = YES;
            }
            
            // update local database here with new User from jsonData
            
            
            // send notification here
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationDeviceRegistered object:nil]; // nill can be a new user object
            
		}
	}];

}

@end
