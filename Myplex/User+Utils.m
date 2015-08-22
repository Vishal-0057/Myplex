//
//  User+Utils.m
//  Myplex
//
//  Created by Igor Ostriz on 02/01/14.
//  Copyright (c) 2014 Igor Ostriz. All rights reserved.
//

#import "AppData.h"
#import "User+Utils.h"

@implementation User (Utils)

+ (BOOL)isLoggedIn
{
    NSString *lint = [[[AppData shared] data][@"user"][@"loggedInThrough"] lowercaseString];
    return [lint isEqualToString:@"guest"] ? NO : YES;
}

@end
