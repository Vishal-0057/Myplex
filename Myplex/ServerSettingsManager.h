//
//  ServerSettingsManager.h
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerSettingsManager : NSObject

+ (ServerSettingsManager*)sharedServerSettings;

- (NSURL*)APIURLwithPath: (NSString*)path;
- (NSURL*)staticURLWithPath: (NSString*)path;   // path prefixed with '/'

//@property (nonatomic) NSString* protocol;
//@property (nonatomic) BOOL local;
//@property (nonatomic) BOOL production;
//@property (nonatomic) NSString* productionSubdomain;
//@property (nonatomic) NSNumber *productionPort;
//@property (nonatomic) NSString* stagingSubdomain;
//@property (nonatomic) NSNumber *stagingPort;
@property (nonatomic) NSString* domain;
@property (nonatomic) NSString* protocol;


@end
