//
//  ServerStandardRequest.h
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

enum ServerStandardRequestType {
	ServerStandardRequestTypeRead = 0,      // GET
	ServerStandardRequestTypeUpdate = 1,    // PUT
	ServerStandardRequestTypeCreate = 2,    // POST
	ServerStandardRequestTypeDelete = 3,    // DELETE
	ServerStandardRequestTypeUnknown
};

// Downloading notifications
UIKIT_EXTERN NSString * const kDownloadingStarted;
UIKIT_EXTERN NSString * const kDownloadingDataReceived;
UIKIT_EXTERN NSString * const kDownloadingSucess;
UIKIT_EXTERN NSString * const kDownloadingError;


@interface ServerStandardRequest : NSObject <NSURLConnectionDataDelegate>
{
    void (^_completionBlock)(id, NSError*);
}


@property (nonatomic) NSURL *url;
@property (nonatomic) NSMutableData *data;
@property (nonatomic) NSUInteger expectedSize;


- (id)initWithPath:(NSString*)path jsonData:(NSDictionary*)jsonDict requestType:(enum ServerStandardRequestType)methodType completionHandler:(void (^)(id, NSError*))block;

@end
