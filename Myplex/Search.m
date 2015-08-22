//
//  Search.m
//  Myplex
//
//  Created by shiva on 9/19/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "Search.h"
#import "ServerStandardRequest.h"
#import "AppData.h"
#import "Notifications.h"
#import "NSManagedObject+Utils.h"
#import "CoreDataModelHeaders.h"
#import "NSNotificationCenter+Utils.h"

@implementation Search {
    NSManagedObjectContext* _managedObjectContext;
}

static NSString* kUserClientKey = @"clientKey";

//Tags
static NSString* kTagCategory = @"category";
static NSString* kTagQualifier = @"qualifier";
static NSString* kNumberPerQualifier = @"numPerQualifier";
static NSString* kTagStartLetter = @"startLetter";
static NSString* kNumberPerStartLetter = @"numPerStartLetter";
//Search Query
static NSString* kSearchQuery = @"query";
static NSString* kSearchInline = @"inline";
static NSString* kSearchWhere = @"where";

static NSString* kResponseStatusCode = @"code";

- (id)initWithManagedObjectContext: (NSManagedObjectContext*)moc
{
	self = [super init];
	if (self) {
		_managedObjectContext = moc;
	}
	
	return self;
}

- (void)getTagsWithCategory: (NSString*)category qualifier: (NSString*)qualifier numPerQualifier: (NSString*)numPerQualifier startLetter:(NSString *)startLetter numStartLetter:(NSString *)numStartLetter clientKey:(NSString *)clientKey {
   
    NSMutableDictionary* mutableTagData = [[NSMutableDictionary alloc]init];
    
    if (category) {
        [mutableTagData setObject:category forKey:kTagCategory];
    }
//    if (qualifier) {
//        [mutableTagData setObject:qualifier forKey:kTagQualifier];
//    }
//    if (numPerQualifier) {
//        [mutableTagData setObject:numPerQualifier forKey:kNumberPerQualifier];
//    }
    if (startLetter) {
        [mutableTagData setObject:startLetter forKey:kTagStartLetter];
    }
//    if (numStartLetter) {
//        [mutableTagData setObject:numStartLetter forKey:kNumberPerStartLetter];
//    }
    if (clientKey) {
        [mutableTagData setObject:clientKey forKey:kUserClientKey];
    }
    
    [mutableTagData setObject:@"devicemax" forKey:@"level"];
    
    //https://api-beta.myplex.in/content/v2/tags/?clientKey=4a92e5b0328fc8f5399df71f2ac933f7957a4cd5750bf93872b01677adaa29da&startLetter=all&level=devicemax
	//When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath: @"/content/v2/tags/" jsonData: mutableTagData requestType: ServerStandardRequestTypeRead completionHandler: ^(NSDictionary* jsonResponse, NSError* error) {
		
		if (error) {
            
            // already written in log, if cleanup is needed, do it here
            // send notification here
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationSearchTagsFetchingError object:error];
		} else {
            
            if ([jsonResponse[kResponseStatusCode]integerValue] == 200) {
//                if (headerFields) {
//                    [[[AppData shared]data]setObject:headerFields[@"Expires"] forKey:@"searchTagsResponseExpiry"];
//                }
                [[[AppData shared]data]setObject:jsonResponse[@"tags"] forKey:@"searchTagsResponse"];
                [[AppData shared]save];
                // send notification here
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationSearchTagsFetched object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationSearchTagsFetchingError object:jsonResponse];
            }
		}
	}];
}

-(void)searchWithQuery:(NSString *)query inline:(NSNumber *)inline_ where:(NSString *)where clientKey:(NSString *)clientKey {
    
    NSMutableDictionary* mutableTagData = [[NSMutableDictionary alloc]init];
    
    if (query) {
        [mutableTagData setObject:query forKey:kSearchQuery];
    }
    if (inline_) {
        [mutableTagData setObject:inline_ forKey:kSearchInline];
    }
    if (where) {
        [mutableTagData setObject:where forKey:kSearchWhere];
    }
    if (clientKey) {
        [mutableTagData setObject:clientKey forKey:kUserClientKey];
    }
    [mutableTagData setObject:@"devicemax" forKey:@"level"];
    
	//When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath: @"/content/v2/search/" jsonData: mutableTagData requestType: ServerStandardRequestTypeRead completionHandler: ^(NSDictionary* jsonResponse, NSError* error) {
		
		if (error) {
            
            // already written in log, if cleanup is needed, do it here
            // send notification here
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationSearchTagsFetchingError object:error];
		} else {
            
            if ([jsonResponse[kResponseStatusCode]integerValue] == 200) {
                //[Content updateOrCreateFromJSONData:jsonResponse[@"results"] inContext:_managedObjectContext];
                // send notification here
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationSearchQueryFetched object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationSearchQueryFetchingError object:jsonResponse];
            }
		}
	}];
}

@end
