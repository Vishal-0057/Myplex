//
//  ServerFileUploadRequest.m
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "ServerDataUploadRequest.h"
#import "ServerSettingsManager.h"
#import "ServerStandardInterface.h"

@interface ServerDataUploadRequest () <NSURLConnectionDataDelegate>

@end

@implementation ServerDataUploadRequest {
	void (^_completionBlock)(id, NSError*);
	void (^_progress)(CGFloat);
	
	NSMutableData* _responseData;
}

- (id)initWithPath: (NSString*)path contentType: (NSString*)contentType data: (NSData*)data uploadProgressHandler: (void (^)(CGFloat))progress completionHandler: (void (^)(id, NSError*))completion
{
	self = [super init];
	if (self) {
		NSURL* apiURL = [[ServerSettingsManager sharedServerSettings] APIURLwithPath: path];
		
		NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL: apiURL cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 60];
			
		[request setHTTPMethod: @"POST"];
		[request setValue: contentType forHTTPHeaderField :@"Accept"];
		[request setValue: contentType forHTTPHeaderField: @"Content-Type"];
		[request setValue: [NSString stringWithFormat: @"%d", data.length] forHTTPHeaderField: @"Content-Size"];
		[request setHTTPBody: data];
		
		NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
		
		if (!connection) {
			NSLog(@"Failed to create connection for URL %@", apiURL);
		}
		
		_completionBlock = [completion copy];
		_responseData = [[NSMutableData alloc] init];
		_progress = [progress copy];
	}
	
	return self;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	_responseData.length = 0;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_responseData appendData: data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	_completionBlock(nil, error);
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (_progress) {
        _progress((float)totalBytesWritten/totalBytesExpectedToWrite);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSError* responseError = nil;
	id parsedJSON;
	BOOL responseIsValid = [[ServerStandardInterface sharedServerStandardInterface] validateJSONResponse: _responseData parsedJSON: &parsedJSON error: &responseError];
    
	if (!responseIsValid) {
		_completionBlock(nil, responseError);
		return;
	}
	
	_completionBlock(parsedJSON, nil);
}

@end
