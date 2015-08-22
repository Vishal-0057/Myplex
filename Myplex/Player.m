//
//  Player.m
//  Myplex
//
//  Created by shiva on 2/11/14.
//  Copyright (c) 2014 Igor Ostriz. All rights reserved.
//

#import "Player.h"
#import "ServerStandardRequest.h"
#import "Notifications.h"
#import "NSNotificationCenter+Utils.h"
#import "ErrorCodes.h"

static NSString* kUserAuthenticationClientKey = @"clientKey";
static NSString* kUpdatePlayerStatusCode = @"code";

@implementation Player


- (void)updateStatus:(NSDictionary *)statusInfo withClientKey:(NSString *)clientKey {
    
    NSMutableDictionary* mutableUserData = [[NSMutableDictionary alloc]init];
    
    if (clientKey) {
        [mutableUserData setObject:clientKey forKey:kUserAuthenticationClientKey];
    }
    
    [mutableUserData addEntriesFromDictionary:statusInfo];
    
#if DEBUG
    NSLog(@"updating player status %@",mutableUserData);
#endif
	//When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:[NSString stringWithFormat:@"/user/v2/events/player/%@/updateStatus",statusInfo[@"contentId"]] jsonData: mutableUserData requestType: ServerStandardRequestTypeCreate completionHandler: ^(NSDictionary* jsonResponse, NSError* error) {
		
		if (error) {
            
            // already written in log, if cleanup is needed, do it here
            // send notification here
            NSDictionary *requestFailedObject = @{@"error": error};
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationFailedUpdatingPlayerStatus  object:requestFailedObject];
		} else {
            if ([jsonResponse[kUpdatePlayerStatusCode]integerValue] == 200) {
                // send notification here
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationPlayerStatusUpdated object:jsonResponse];
            } else {
                NSError *error = [NSError errorWithDomain:kServerErrors andCode:kServerErrorNotAuthorized andDescriptionKey:jsonResponse[@"message"] andUnderlying:0];
                NSDictionary *requestFailedObject = @{@"error": error};
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationFailedUpdatingPlayerStatus object:requestFailedObject];
            }
		}
	}];
}

- (void)getStatus:(NSDictionary *)statusInfo withClientKey:(NSString *)clientKey withCompletionHandler:(RequestGetPlayerStatusWithCompletionHandler)completionHandler {
    
    NSMutableDictionary* mutableUserData = [[NSMutableDictionary alloc]init];
    
    
    if ([self isNotNull:statusInfo]) {
        [mutableUserData addEntriesFromDictionary:statusInfo]; 
    }
    
    if (clientKey) {
        [mutableUserData setObject:clientKey forKey:kUserAuthenticationClientKey];
    }
	//When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:[NSString stringWithFormat:@"/user/v2/events/player/%@/updateStatus",statusInfo[@"contentId"]] jsonData: mutableUserData requestType: ServerStandardRequestTypeRead completionHandler: ^(NSDictionary* jsonResponse, NSError* error) {
		
		if (error) {
            
            // already written in log, if cleanup is needed, do it here
            // send notification here
            //NSDictionary *requestFailedObject = @{@"error": error};
            //[[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationFailedRetrievingPlayerStatus  object:requestFailedObject];
            dispatch_sync(dispatch_get_main_queue(), ^{
                completionHandler(NO,nil,error);
            });
		} else {
            if ([jsonResponse[kUpdatePlayerStatusCode]integerValue] == 200) {
                // send notification here
                //[[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationPlayerStatusReceived object:jsonResponse];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    completionHandler(YES,jsonResponse,nil);
                });
            } else {
                NSError *error = [NSError errorWithDomain:kServerErrors andCode:kServerErrorNotAuthorized andDescriptionKey:jsonResponse[@"message"] andUnderlying:0];
                //NSDictionary *requestFailedObject = @{@"error": error};
                //[[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationFailedRetrievingPlayerStatus object:requestFailedObject];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    completionHandler(NO,nil,error);
                });
            }
		}
	}];
}

@end
