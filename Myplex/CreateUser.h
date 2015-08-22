//
//  CreateUser.h
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Notifications.h"


enum CreateUserOptions {
	CreateUserOptionDefault = 0,
	CreateUserOptionFacebookOnly = 1,
	CreateUserOptionUnknown
};

@interface CreateUser : NSObject

- (id)initWithManagedObjectContext: (NSManagedObjectContext*)moc;
- (void)createUserWithEmail: (NSString*)emailAddress phoneNumber: (NSString*)phoneNumber passowrd: (NSString*)password fullName: (NSString*)fullName receiveMailUpdate:(BOOL)mailUpdate receiveSMSUpdates:(BOOL)smsUpdates clientKey:(NSString *)clientKey;
-(void)createGuestUserWithClientKey:(NSString *)clientKey;

@end
