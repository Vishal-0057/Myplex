//
//  ServerRequestsPool.h
//  Myplex
//
//  Created by Igor Ostriz on 28/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerRequestsPool : NSObject

+ (ServerRequestsPool *) sharedPool;

- (void)addRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDataDelegate>)delegate;
- (void)cancelAllCalls;

@end
