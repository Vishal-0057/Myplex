//
//  LoginUser.m
//  Myplex
//
//  Logind by shiva on 9/13/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "LoginUser.h"
#import "ServerStandardRequest.h"
#import "AppData.h"
#import "UIAlertView+ReportError.h"
#import "NSNotificationCenter+Utils.h"

static NSString* kUserAuthenticationClientKey = @"clientKey";

static NSString* kLoginUserUserId = @"userid";
static NSString* kLoginUserPassword = @"password";
static NSString* kUserAuthenticationStatus = @"status";
static NSString* kUserAuthenticationStatusCode = @"code";
static NSString* kUserAuthenticationResult = @"result";

//FaceBook
static NSString* kLoginUserFBId = @"facebookId";
static NSString* kLoginUserFBAuthToken = @"authToken";
static NSString* kLoginUserFBAuthTokenExpiry = @"tokenExpiry";

//Google+
static NSString* kLoginUserGooglePlusId = @"googleId";
static NSString* kLoginUserGooglePlusAuthToken = @"authToken";
static NSString* kLoginUserGooglePlusAuthTokenExpiry = @"tokenExpiry";

//Twitter
static NSString* kLoginUserTwitterId = @"twitterId";
static NSString* kLoginUserTwitterAuthToken = @"authToken";
static NSString* kLoginUserTwitterAuthTokenExpiry = @"tokenExpiry";

//ForgotPassword
static NSString* kCreateUserEmailAddress = @"email";

static NSString* kCreateUserStatusCode = @"code";

@implementation LoginUser

- (void)authenticateUserWithUserId:(NSString*)userId password: (NSString*)password clientKey:(NSString *)clientKey {
    
    NSDictionary* userData = @{kLoginUserUserId: userId, kLoginUserPassword: password,kUserAuthenticationClientKey:clientKey};
    NSMutableDictionary* mutableUserData = [NSMutableDictionary dictionaryWithDictionary: userData];
    
    NSString *path = @"/user/v2/signIn";
    
    [self createNetworkConnectionWithPath:path withData:mutableUserData];
}

- (void)authenticateUserWithFacebookId:(NSString*)fbId authToken: (NSString*)authToken tokenExpiry:(NSString*)tokenExpiry clientKey:(NSString *)clientKey {
    
    NSDictionary* userData = @{kLoginUserFBId: fbId?:@"", kLoginUserFBAuthToken: authToken?:@"", kLoginUserFBAuthTokenExpiry:tokenExpiry?:@"",kUserAuthenticationClientKey:clientKey};
    NSMutableDictionary* mutableUserData = [NSMutableDictionary dictionaryWithDictionary: userData];
    
    NSString *path = @"/user/v2/social/login/FB";
    
    [self createNetworkConnectionWithPath:path withData:mutableUserData];
}

- (void)authenticateUserWithGooglePlusId:(NSString*)googlePlusId authToken: (NSString*)authToken tokenExpiry:(NSString*)tokenExpiry clientKey:(NSString *)clientKey {
    
    NSDictionary* userData = @{kLoginUserGooglePlusId: googlePlusId, kLoginUserGooglePlusAuthToken: authToken, kLoginUserGooglePlusAuthTokenExpiry:tokenExpiry,kUserAuthenticationClientKey:clientKey};
    NSMutableDictionary* mutableUserData = [NSMutableDictionary dictionaryWithDictionary: userData];
    
    NSString *path = @"/user/v2/social/login/Google";
    
    [self createNetworkConnectionWithPath:path withData:mutableUserData];
}

- (void)authenticateUserWithTwitterId:(NSString*)twitterId authToken: (NSString*)authToken tokenExpiry:(NSString*)tokenExpiry clientKey:(NSString *)clientKey {
    
    NSDictionary* userData = @{kLoginUserTwitterId: twitterId, kLoginUserTwitterAuthToken: authToken, kLoginUserTwitterAuthTokenExpiry:tokenExpiry,kUserAuthenticationClientKey:clientKey};
    NSMutableDictionary* mutableUserData = [NSMutableDictionary dictionaryWithDictionary: userData];
    
    NSString *path = @"/user/v2/social/login/Twitter";
    
    [self createNetworkConnectionWithPath:path withData:mutableUserData];
}

-(void)retrievePasswordOf:(NSString *)email clientKey:(NSString *)clientKey {
    
    NSMutableDictionary* mutableUserData = [[NSMutableDictionary alloc]init];
    
    if (email) {
        [mutableUserData setObject:email forKey:kCreateUserEmailAddress];
    }
    if (clientKey) {
        [mutableUserData setObject:clientKey forKey:kUserAuthenticationClientKey];
    }
    
	//When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath: @"/user/v2/forgotPassword" jsonData: mutableUserData requestType: ServerStandardRequestTypeCreate completionHandler: ^(NSDictionary* jsonResponse, NSError* error) {
		
		if (error) {
            
            // already written in log, if cleanup is needed, do it here
            // send notification here
             NSDictionary *requestFailedObject = @{@"error": error};
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationRetrievePasswordError object:requestFailedObject]; // nill can be a new user object
		} else {
            if ([jsonResponse[kCreateUserStatusCode]integerValue] == 200) {
                // send notification here
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationRetrievePassword object:jsonResponse]; // nill can be a new user object
            } else {
                NSError *error = [NSError errorWithDomain:kServerErrors andCode:kServerErrorNotAuthorized andDescriptionKey:jsonResponse[@"message"] andUnderlying:0];
                NSDictionary *requestFailedObject = @{@"error": error};
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationRetrievePasswordError object:requestFailedObject];
            }
		}
	}];
}

- (void)signOut:(NSString *)clientKey {
    
    NSMutableDictionary* mutableUserData = [[NSMutableDictionary alloc]init];
    
    if (clientKey) {
        [mutableUserData setObject:clientKey forKey:kUserAuthenticationClientKey];
    }
    
	//When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath: @"/user/v2/signOut" jsonData: mutableUserData requestType: ServerStandardRequestTypeCreate completionHandler: ^(NSDictionary* jsonResponse, NSError* error) {
		
		if (error) {
            
            // already written in log, if cleanup is needed, do it here
            // send notification here
            // already written in log, if cleanup is needed, do it here
            NSDictionary *requestFailedObject = @{@"error": error};
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationSignOutError object:requestFailedObject]; // nill can be a new user object
		} else {
            if ([jsonResponse[kCreateUserStatusCode]integerValue] == 200) {
                // send notification here
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationSignedOut object:jsonResponse]; // nill can be a new user object
            } else {
                NSError *error = [NSError errorWithDomain:kServerErrors andCode:kServerErrorNotAuthorized andDescriptionKey:jsonResponse[@"message"] andUnderlying:0];
                NSDictionary *requestFailedObject = @{@"error": error};
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationSignOutError object:requestFailedObject];
            }
		}
	}];
}

-(void)createNetworkConnectionWithPath:(NSString*)path withData:(NSMutableDictionary *)mutableUserData {
    
	//When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath: path jsonData: mutableUserData requestType: ServerStandardRequestTypeCreate completionHandler: ^(NSDictionary* jsonResponse, NSError* error) {
		
		if (error) {
            
            [[[AppData shared]data][@"user"] removeAllObjects];

            // already written in log, if cleanup is needed, do it here
            NSDictionary *loginFailObject = @{@"error": error,@"loginPath":path};
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationLoginError object:loginFailObject];

		} else {
            
            //BOOL authenticated = NO;
            if ([jsonResponse[kUserAuthenticationStatusCode]integerValue] == 201 || [jsonResponse[kUserAuthenticationStatusCode]integerValue] == 200) {
                
                //jsonResponse = jsonResponse[kUserAuthenticationResult];
                
                [[[AppData shared]data]setObject:[NSNumber numberWithBool:YES] forKey:@"stayLoggedIn"];
                //[[[AppData shared]data][@"user"] setObject:mutableUserData[@"userid"] forKey:@"name"];
                [[AppData shared]save];
                
                // send notification here
                NSDictionary *loginResponseObject = @{@"loginPath":path,@"response":jsonResponse};
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationUserAuthenticated object:loginResponseObject]; // nil can be a new user object
                
                //authenticated = YES;
            } else {
                //remove users data
                [[[AppData shared]data][@"user"] removeAllObjects];
                
                NSError *error = [NSError errorWithDomain:kServerErrors andCode:kServerErrorNotAuthorized andDescriptionKey:jsonResponse[@"message"] andUnderlying:0];
                NSDictionary *loginFailObject = @{@"error": error,@"loginPath":path};
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationLoginError object:loginFailObject];
 
            }
		}
	}];
}
@end
