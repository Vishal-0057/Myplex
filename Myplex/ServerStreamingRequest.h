//
//  ServerStreamingRequest.h
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "ServerStandardRequest.h"

@interface ServerStreamingRequest : ServerStandardRequest


- (id)initWithPath:(NSString*)path jsonData:(NSDictionary*)jsonDict dataHandler:(void (^)(NSMutableData*))data completionHandler:(void (^)(NSData*, NSError*))completion;

@end
