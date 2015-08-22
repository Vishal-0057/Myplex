//
//  StandardKeySanitizer.m
//  Myplex
//
//  Created by Igor Ostriz on 8/16/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "NSString+MakeCamelCase.h"
#import "StandardKeySanitizer.h"

@implementation StandardKeySanitizer 
{
    NSDictionary *_sanitizeKeys;
}
+ (StandardKeySanitizer*)keySanitizer
{
	return [[self alloc] init];
}


// default dictionary
- (id)init
{
    self = [super init];
    if (self) {
        _sanitizeKeys = @{
                          @"_id": @"remoteId",
                          @"id": @"remoteId"
                          };
    }
    return self;
}


- (id)initWithKeys:(NSDictionary *)sanitizeKeys
{
    self = [self init];
    if (self) {
        NSMutableDictionary *md = [_sanitizeKeys mutableCopy];
        [md addEntriesFromDictionary:sanitizeKeys];
        _sanitizeKeys = md;
    }
    return self;
}

- (NSString*)sanitizeRemoteKey: (NSString*)remoteKey
{
//	static NSDictionary* sanitizeKeys = nil;
//	static dispatch_once_t onceToken;
//	dispatch_once(&onceToken, ^{
//		sanitizeKeys = @{ @"_id" : @"remoteId" };
//	});
	
	NSString* sanitizedKey = [_sanitizeKeys objectForKey: remoteKey];
	if (!sanitizedKey) {
		sanitizedKey = [remoteKey camelCased];
	}
	
	return sanitizedKey;
}

- (NSDictionary*)sanitizeRemoteKeys: (NSDictionary*)remoteKeys
{

    if ([remoteKeys isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary* __block sanitizedData = [[NSMutableDictionary alloc] initWithCapacity: [remoteKeys count]];
        
        [remoteKeys enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
            [sanitizedData setObject: obj forKey: [self sanitizeRemoteKey: key]];
        }];
        return sanitizedData;
    }
    return nil;
}

@end
