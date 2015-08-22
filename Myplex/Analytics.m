//
//  Analytics.m
//  Myplex
//
//  Created by shiva on 12/13/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "Analytics.h"
#import "Mixpanel.h"
#import "Flurry.h"

@implementation Analytics

+(void)setSuperProperties:(NSDictionary *)properties {
    
    //set hardcoded superProperties here
    NSMutableDictionary *mutableCopy = nil;
    if (properties != nil) {
        mutableCopy = [properties mutableCopy];
    } else {
        mutableCopy = [[NSMutableDictionary alloc]init];
    }
    [mutableCopy setObject:@"native" forKey:@"browser"];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel registerSuperProperties:mutableCopy];
}

+(void)logEvent:(NSString *)event parameters:(NSDictionary *)params timed:(BOOL)timed {
    
    if (timed) {
        [Flurry logEvent:event withParameters:params timed:timed];
    } else {
        [Flurry logEvent:event];
    }
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:event properties:params];
}

+(void)endEvent:(NSString *)event parameters:(NSDictionary *)params {
    [Flurry endTimedEvent:EVENT_LOGIN withParameters:params];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:event properties:params];
}

@end
