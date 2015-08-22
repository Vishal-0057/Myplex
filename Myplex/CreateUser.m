//
//  CreateUser.m
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "CreateUser.h"
#import "ServerStandardRequest.h"
#import "AppData.h"
#import "NSNotificationCenter+Utils.h"
#import "ErrorCodes.h"

static NSString* kCreateUserClientKey = @"clientKey";

static NSString* kCreateUserEmailAddress = @"email";
static NSString* kCreateUserPhoneNumber = @"mobile";
static NSString* kCreateUserPassword = @"password";
static NSString* kCreateUserConfirmPassword = @"password2";
static NSString* kCreateUserFullName = @"first";

static NSString* kCreateUserStatusCode = @"code";

@implementation CreateUser {
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

- (void)createUserWithEmail: (NSString*)emailAddress phoneNumber: (NSString*)phoneNumber passowrd: (NSString*)password fullName: (NSString*)fullName receiveMailUpdate:(BOOL)mailUpdate receiveSMSUpdates:(BOOL)smsUpdates clientKey:(NSString *)clientKey
{
    NSMutableDictionary* mutableUserData = [[NSMutableDictionary alloc]init];
    
    if (emailAddress) {
        [mutableUserData setObject:emailAddress forKey:kCreateUserEmailAddress];
    }
    if (phoneNumber) {
        [mutableUserData setObject:phoneNumber forKey:kCreateUserPhoneNumber];
    }
    if (password) {
        [mutableUserData setObject:password forKey:kCreateUserPassword];
    }
    if (password) {
        [mutableUserData setObject:password forKey:kCreateUserConfirmPassword];
    }
    if (fullName) {
        [mutableUserData setObject:fullName forKey:kCreateUserFullName];
    }
    if (clientKey) {
        [mutableUserData setObject:clientKey forKey:kCreateUserClientKey];
    }
    
	//When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath: @"/user/v2/signUp" jsonData: mutableUserData requestType: ServerStandardRequestTypeCreate completionHandler: ^(NSDictionary* jsonResponse,NSError* error) {
		
		if (error) {

            // already written in log, if cleanup is needed, do it here
            // send notification here
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationUserCreateError object:error]; // nill can be a new user object
		} else {
            if ([jsonResponse[kCreateUserStatusCode]integerValue] == 201) {
                [[[AppData shared]data][@"user"] setObject:jsonResponse[@"userid"] forKey:@"userId"];
                [[[AppData shared]data]setObject:[NSNumber numberWithBool:YES] forKey:@"stayLoggedIn"];
                [[AppData shared]save];
                // send notification here
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationUserCreated object:jsonResponse]; // nill can be a new user object
            } else {
                NSError *error = [NSError errorWithDomain:kServerErrors andCode:kServerErrorNotAuthorized andDescriptionKey:jsonResponse[@"message"] andUnderlying:0];
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationUserCreateError object:error];
            }
		}
	}];
}

-(void)createGuestUserWithClientKey:(NSString *)clientKey {
    
    NSMutableDictionary* mutableUserData = [[NSMutableDictionary alloc]init];
    
    if (clientKey) {
        [mutableUserData setObject:clientKey forKey:kCreateUserClientKey];
    }
    
	//When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath: @"/user/v2/guestSignIn/" jsonData: mutableUserData requestType: ServerStandardRequestTypeCreate completionHandler: ^(NSDictionary* jsonResponse,NSError* error) {
		
		if (error) {
            
            // already written in log, if cleanup is needed, do it here
            // send notification here
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationGuestUserCreateError object:error]; // nill can be a new user object
		} else {
            if ([jsonResponse[kCreateUserStatusCode]integerValue] == 200 || [jsonResponse[kCreateUserStatusCode]integerValue] == 201) {
                //[[[AppData shared]data][@"user"] setObject:jsonResponse[@"userid"] forKey:@"userId"];
                //[[[AppData shared]data]setObject:[NSNumber numberWithBool:YES] forKey:@"stayLoggedIn"];
                //[[AppData shared]save];
                // send notification here
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationGuestUserCreated object:jsonResponse]; // nill can be a new user object
            } else {
                NSError *error = [NSError errorWithDomain:kServerErrors andCode:kServerErrorNotAuthorized andDescriptionKey:jsonResponse[@"message"] andUnderlying:0];
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationGuestUserCreateError object:error];
            }
		}
	}];
}

@end
