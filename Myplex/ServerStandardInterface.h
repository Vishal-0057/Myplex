//
//  ServerStandardInterface.h
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerStandardInterface : NSObject

+ (ServerStandardInterface*)sharedServerStandardInterface;

- (BOOL)validateJSONResponse:(NSData*)responseData parsedJSON:(id*)jsonObj error:(NSError**)error;

@property (nonatomic) NSString* APIVersion;
@property (nonatomic) NSString* APIIdentifier;

@end
