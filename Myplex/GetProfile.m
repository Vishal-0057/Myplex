//
//  GetProfile.m
//  Myplex
//
//  Created by shiva on 12/9/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "GetProfile.h"
#import "ServerStandardRequest.h"
#import "AppData.h"
#import "Notifications.h"
#import "NSNotificationCenter+Utils.h"

static NSString* kUserClientKey = @"clientKey";
static NSString* kGetProfileStatusCode = @"code";

@implementation GetProfile

-(void)getProfile:(NSString *)clientKey
{
    
	NSDictionary* userData = @{kUserClientKey:clientKey};
    NSMutableDictionary* mutableUserData = [NSMutableDictionary dictionaryWithDictionary: userData];
    
	//When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:@"/user/v2/profile" jsonData: mutableUserData requestType: ServerStandardRequestTypeRead completionHandler: ^(NSDictionary* jsonResponse, NSError* error) {
		
		if (error) {
            
            // already written in log, if cleanup is needed, do it here
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationGetProfileError object:nil]; // nill can be a new user object
		} else {
            
            //BOOL authenticatedOnly = NO;
            if ([jsonResponse[kGetProfileStatusCode]integerValue] == 200 || [jsonResponse[kGetProfileStatusCode]integerValue] == 201) {
                
                NSDictionary *profile = jsonResponse[@"result"][@"profile"];
                
                [[[AppData shared]data][@"user"] setObject:profile[@"first"] forKey:@"name"];
                [[[AppData shared]data][@"user"] setObject:profile[@"last"] forKey:@"last"];
                [[[AppData shared]data][@"user"] setObject:profile[@"gender"]?:@"Not Specified" forKey:@"gender"];
                [[[AppData shared]data][@"user"] setObject:profile[@"mobile_no"]?:@"" forKey:@"mobile"];
                [[[AppData shared]data][@"user"] setObject:profile[@"id"]?:profile[@"_id"] forKey:@"userId"];
                //[[[AppData shared]data][@"user"] setObject:profile[@"dob"] forKey:@"dob"];
                NSArray *emails = profile[@"emails"];
                if (emails.count > 0) {
                    emails = [emails filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"is_primary==%d",TRUE]]];
                }
                if (emails.count > 0) {
                    [[[AppData shared]data][@"user"] setObject:[emails lastObject][@"email"] forKey:@"email"];
                }
                
                [[AppData shared]save];
            }
            
            // send notification here
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationGetProfile object:nil]; // nill can be a new user object
            
		}
	}];
    
}

@end
