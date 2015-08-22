//
//  ServerStandardRequest.m
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "NSMutableURLRequest+AttachJSON.h"
#import "NSNotificationCenter+Utils.h"
#import "ServerRequestsPool.h"
#import "ServerSettingsManager.h"
#import "ServerStandardInterface.h"
#import "ServerStandardRequest.h"


NSString * const kDownloadingStarted = @"DownloadingStarted";
NSString * const kDownloadingDataReceived = @"DownloadingReceived";
NSString * const kDownloadingSucess = @"DownloadingSuccess";
NSString * const kDownloadingError = @"DownloadingError";



@implementation ServerStandardRequest

//this method will not return anything because "we will not use value stored in request"
- (id)initWithPath:(NSString*)path jsonData:(NSDictionary*)jsonDict requestType:(enum ServerStandardRequestType)methodType completionHandler:(void (^)(id, NSError*))block
{
	self = [super init];
	if (self) {
        NSURL* theURL;
        if ([path hasPrefix: @"/"] ) {
            theURL = [[ServerSettingsManager sharedServerSettings] staticURLWithPath: path];
        }
        else if ([[path lowercaseString] hasPrefix:@"http"]) {
            theURL = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        else {
            theURL = [[ServerSettingsManager sharedServerSettings] APIURLwithPath: path];
        }
        
		_data = [NSMutableData new];
        _url = [theURL copy];
		_completionBlock = [block copy];
        _expectedSize = 0;
        
        
		//NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
		NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:theURL];
        
		static NSArray* methodNames = nil;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			methodNames = @[@"GET", @"PUT", @"POST", @"DELETE"];
		});
				
		NSString* methodName = [methodNames objectAtIndex: methodType];
		[request setHTTPMethod: methodName];
        [request attachJSONDataUrlEncoded:jsonDict];

#ifdef DEBUG
        NSLog(@"Request : %@\n%@", request, [request allHTTPHeaderFields]);
#endif
//        [NSURLProtocol setProperty:@YES forKey:@"CacheSet" inRequest:request];
//        NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
//        if (cachedResponse) {
//            [self connection:nil didReceiveResponse:[cachedResponse response]];
//            [self connection:nil didReceiveData:[cachedResponse data]];
//            [self connectionDidFinishLoading:nil];
//        } else {
//            [[ServerRequestsPool sharedPool] addRequest:request delegate:self];
//
//        }
        
        [[ServerRequestsPool sharedPool] addRequest:request delegate:self];
    }

	return self;
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)[cachedResponse response];
    
    // Look up the cache policy used in our request
    if([connection currentRequest].cachePolicy == NSURLRequestUseProtocolCachePolicy) {
        NSDictionary *headers = [httpResponse allHeaderFields];
        NSString *cacheControl = [headers valueForKey:@"Cache-Control"];
        NSString *expires = [headers valueForKey:@"Expires"];
        if((cacheControl == nil) && (expires == nil)) {
#if DEBUG
            NSLog(@"server does not provide expiration information and we are using NSURLRequestUseProtocolCachePolicy.\nURL:%@", self.url);
#endif
            return nil; // don't cache this
        }
    }
    
    NSMutableDictionary *mutableUserInfo = [[cachedResponse userInfo] mutableCopy];
    NSMutableData *mutableData = [[cachedResponse data] mutableCopy];
    NSURLCacheStoragePolicy storagePolicy = NSURLCacheStorageAllowedInMemoryOnly;
    // ...
    return [[NSCachedURLResponse alloc] initWithResponse:[cachedResponse response]
                                                    data:mutableData
                                                userInfo:mutableUserInfo
                                           storagePolicy:storagePolicy];    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
#ifdef DEBUG
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSDictionary *headerFields = [(NSHTTPURLResponse*)response allHeaderFields];
        NSLog(@"URL: %@\n%@", [[connection currentRequest] URL], headerFields);
    }
#endif
    
	_data.length = 0;
    _expectedSize = (int)response.expectedContentLength;
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kDownloadingStarted object:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_data appendData: data];
    
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kDownloadingDataReceived object:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (_completionBlock)
        _completionBlock(nil, error);
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kDownloadingError object:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{

	NSError* responseError = nil;
	id response;
    
    BOOL responseIsValid = [[ServerStandardInterface sharedServerStandardInterface] validateJSONResponse:_data parsedJSON:&response error:&responseError];
    if (!responseIsValid) {

#ifdef DEBUG
        NSLog(@"%@ => %@", responseError, [[connection currentRequest] URL]);
#endif
        if (_completionBlock)
            _completionBlock(nil, responseError);
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kDownloadingError object:self];
        return;
    }
        
#ifdef DEBUG
    NSLog(@"%@ => %@", _url, response);
#endif

    if (_completionBlock)
        _completionBlock(response, nil);
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kDownloadingSucess object:self];
}

@end
