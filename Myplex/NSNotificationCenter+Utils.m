//
//  NSNotificationCenter+Utils.m
//  Myplex
//
//  Created by Igor Ostriz on 10/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "NSNotificationCenter+Utils.h"


@implementation NSNotificationCenter (Utils)

-(void)postNotificationOnMainThread:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    });
}

-(void)postNotificationNameOnMainThread:(NSString *)aName object:(id)anObject
{
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject];
    });
}

-(void)postNotificationNameOnMainThread:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject userInfo:aUserInfo];
    });
}

@end
