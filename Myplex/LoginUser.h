//
//  LoginUser.h
//  Myplex
//
//  Created by shiva on 9/13/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Notifications.h"

@interface LoginUser : NSObject

- (void)authenticateUserWithUserId:(NSString*)userId password: (NSString*)password clientKey:(NSString *)clientKey;
- (void)authenticateUserWithFacebookId:(NSString*)fbId authToken: (NSString*)authToken tokenExpiry:(NSString*)tokenExpiry clientKey:(NSString *)clientKey;
- (void)authenticateUserWithGooglePlusId:(NSString*)googlePlusId authToken: (NSString*)authToken tokenExpiry:(NSString*)tokenExpiry clientKey:(NSString *)clientKey;
- (void)authenticateUserWithTwitterId:(NSString*)twitterId authToken: (NSString*)authToken tokenExpiry:(NSString*)tokenExpiry clientKey:(NSString *)clientKey;
- (void)retrievePasswordOf:(NSString *)email clientKey:(NSString *)clientKey;
- (void)signOut:(NSString *)clientKey;

@end
