//
//  NSNotificationCenter+Utils.h
//  Myplex
//
//  Created by Igor Ostriz on 10/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (Utils)

-(void)postNotificationOnMainThread:(NSNotification *)notification;
-(void)postNotificationNameOnMainThread:(NSString *)aName object:(id)anObject;
-(void)postNotificationNameOnMainThread:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end
