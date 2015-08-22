//
//  ServerRequestsPool.m
//  Myplex
//
//  Created by Igor Ostriz on 28/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <objc/runtime.h>
#import "ServerRequestsPool.h"


@interface NSURLConnection (Delegate)

@property (nonatomic) id<NSURLConnectionDataDelegate> delegate;

@end

static const char* _key = "delegate";

@implementation NSURLConnection (Delegate)

- (id<NSURLConnectionDataDelegate>)delegate
{
    return objc_getAssociatedObject(self, _key);
}

- (void)setDelegate:(id<NSURLConnectionDataDelegate>)delegate
{
    objc_setAssociatedObject(self, _key, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end




@interface ServerRequestsPool () <NSURLConnectionDataDelegate>

@end


@implementation ServerRequestsPool
{
    NSOperationQueue *_networkQueue;
    NSMutableArray *_connections;
}

+ (ServerRequestsPool *)sharedPool
{
    static ServerRequestsPool *_pool = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pool = [ServerRequestsPool new];
    });
    
    return _pool;
}


- (id)init {
    self = [super init];
    if (self) {
        _networkQueue = [[NSOperationQueue alloc] init];
        // We just have 1 thread for this work, that way canceling is easy
        _networkQueue.maxConcurrentOperationCount = 1;
        _connections = [NSMutableArray arrayWithCapacity:10];
//        _timeout = 5.0;
//        _cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return self;
}

- (id)tagObject
{
    return objc_getAssociatedObject(self, _key);
}

- (void)setTagObject:(id)tagObject
{
    objc_setAssociatedObject(self, _key, tagObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}


- (void)addRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDataDelegate>)delegate;
{
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection setDelegateQueue:_networkQueue];
    connection.delegate = delegate;
    [connection start];
    
    [_connections addObject:connection];
}

- (void)cancelAllCalls
{
    [_networkQueue setSuspended:YES];
    [_networkQueue cancelAllOperations];
    [_networkQueue addOperationWithBlock:^{
        for (NSURLConnection *connection in _connections) {
            [connection cancel];
        }
        [_connections removeAllObjects];
    }];
    [_networkQueue setSuspended:NO];

}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
//    if ([connection.delegate respondsToSelector:@selector(connection:willCacheResponse:)]) {
//        NSObject *obj = connection.delegate;
//        NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:[obj methodSignatureForSelector:@selector(connection:willCacheResponse:)]];
//        [invoc setTarget:obj];
//        [invoc setSelector:@selector(connection:willCacheResponse:)];
//        [invoc setArgument:&connection atIndex:2];
//        [invoc setArgument:&cachedResponse atIndex:3];
//        [invoc invoke];
//        
//        NSCachedURLResponse *rv;
//        [invoc getReturnValue:&rv];
//        return rv;
//    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)[cachedResponse response];
    // Look up the cache policy used in our request
    if([connection currentRequest].cachePolicy == NSURLRequestUseProtocolCachePolicy) {
        NSDictionary *headers = [httpResponse allHeaderFields];
        NSString *cacheControl = [headers valueForKey:@"Cache-Control"];
        NSString *expires = [headers valueForKey:@"Expires"];
        if((cacheControl == nil) && (expires == nil)) {
#if DEBUG
            NSLog(@"server does not provide expiration information and we are using NSURLRequestUseProtocolCachePolicy.\nURL:%@", [connection.originalRequest URL]);
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
    if ([connection.delegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        NSObject *obj = connection.delegate;
        NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:[obj methodSignatureForSelector:@selector(connection:didReceiveResponse:)]];
        [invoc setTarget:obj];
        [invoc setSelector:@selector(connection:didReceiveResponse:)];
        [invoc setArgument:&connection atIndex:2];
        [invoc setArgument:&response atIndex:3];
        [invoc invoke];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if ([connection.delegate respondsToSelector:@selector(connection:didReceiveData:)]) {
        NSObject *obj = connection.delegate;
        NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:[obj methodSignatureForSelector:@selector(connection:didReceiveData:)]];
        [invoc setTarget:obj];
        [invoc setSelector:@selector(connection:didReceiveData:)];
        [invoc setArgument:&connection atIndex:2];
        [invoc setArgument:&data atIndex:3];
        [invoc invoke];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_connections removeObject:connection];
    if ([connection.delegate respondsToSelector:@selector(connection:didFailWithError:)]) {
        NSObject *obj = connection.delegate;
        NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:[obj methodSignatureForSelector:@selector(connection:didFailWithError:)]];
        [invoc setTarget:obj];
        [invoc setSelector:@selector(connection:didFailWithError:)];
        [invoc setArgument:&connection atIndex:2];
        [invoc setArgument:&error atIndex:3];
        [invoc invoke];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_connections removeObject:connection];
    if ([connection.delegate respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        NSObject *obj = connection.delegate;
        NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:[obj methodSignatureForSelector:@selector(connectionDidFinishLoading:)]];
        [invoc setTarget:obj];
        [invoc setSelector:@selector(connectionDidFinishLoading:)];
        [invoc setArgument:&connection atIndex:2];
        [invoc invoke];
    }
}


@end
