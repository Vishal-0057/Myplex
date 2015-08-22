//
//  ServerSettingsManager.m
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "NSObject+PListCreation.h"
#import "ServerSettingsManager.h"
#import "ServerStandardInterface.h"

static NSString* kScoreTypeRetina = @"ipad_hires";
static NSString* kScoreTypeNonRetina = @"ipad_lores";

@implementation ServerSettingsManager
{
    NSString *_localhostAddress;
}


+ (ServerSettingsManager*)sharedServerSettings
{
	static ServerSettingsManager* sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [ServerSettingsManager new];
        sharedInstance.domain = [[NSBundle mainBundle] infoDictionary][@"Domain"];
        sharedInstance.protocol = [[NSBundle mainBundle] infoDictionary][@"Protocol"];
        if (![sharedInstance.protocol length]) {
            sharedInstance.protocol = @"https";
        }
	});
	
	return sharedInstance;
}


- (NSString*)baseHostURL
{
    return [NSString stringWithFormat: @"%@://%@", self.protocol, self.domain];
}
- (NSString*)rawBaseAPIURLPath
{
    return [NSString stringWithFormat: @"%@/", [self baseHostURL]];
}

- (NSURL*)APIURLwithPath:(NSString*)path
{
	NSString* basePath = [self rawBaseAPIURLPath];
    ServerStandardInterface* remoteAPI = [ServerStandardInterface sharedServerStandardInterface];

    NSMutableArray *components = [[path componentsSeparatedByString:@"/"] mutableCopy];
    [components insertObject:remoteAPI.APIVersion atIndex:1];
    
	NSString* apiPath = [basePath stringByAppendingString:[components componentsJoinedByString:@"/"]];
	
	return [NSURL URLWithString: apiPath];
}

- (NSURL*)staticURLWithPath: (NSString*)path
{
    NSString* baseUrl = [self baseHostURL];
    return [NSURL URLWithString: [baseUrl stringByAppendingString: path]];
}





@end
