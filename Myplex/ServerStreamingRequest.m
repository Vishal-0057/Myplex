//
//  ServerStreamingRequest.m
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "ServerStreamingRequest.h"

@implementation ServerStreamingRequest {
	void (^_dataBlock)(NSMutableData*);
}

- (id)initWithPath: (NSString*)path jsonData: (NSDictionary*)jsonDict dataHandler:(void (^)(NSMutableData*))data completionHandler:(void (^)(NSData*, NSError*))completion;
{
	self = [super initWithPath:path jsonData:jsonDict requestType:ServerStandardRequestTypeRead completionHandler:completion];
	if (self) {
		_dataBlock = [data copy];
	}
	
	return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.data appendData:data];
	
    if (_dataBlock)
        _dataBlock(self.data);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (_dataBlock)
        _dataBlock(self.data);
	

	_completionBlock(self.data, nil);
}

@end
