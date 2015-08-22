//
//  Player.h
//  Myplex
//
//  Created by shiva on 2/11/14.
//  Copyright (c) 2014 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RequestGetPlayerStatusWithCompletionHandler)(BOOL success, NSDictionary *response, NSError *error);

@interface Player : NSObject

- (void)updateStatus:(NSDictionary *)statusInfo withClientKey:(NSString *)clientKey;
- (void)getStatus:(NSDictionary *)statusInfo withClientKey:(NSString *)clientKey withCompletionHandler:(RequestGetPlayerStatusWithCompletionHandler)completionHandler;

@end
