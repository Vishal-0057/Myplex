//
//  ServerStandardInterface.m
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "ErrorCodes.h"
#import "ErrorDescriptions.h"
#import "NSObject+PListCreation.h"
#import "NSError+Utils.h"
#import "ServerStandardInterface.h"

#define kErrorCodeGeneric 10400
#define kErrorCodeNotAuthorized 10401

@implementation ServerStandardInterface

+ (ServerStandardInterface*)sharedServerStandardInterface
{
	static ServerStandardInterface* sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [self awakenFromPList:@"ServerAPIInfo"];
	});
	
	return sharedInstance;
}

- (BOOL)validateJSONResponse:(NSData*)responseData parsedJSON:(id*)jsonObj error:(NSError**)error
{
	if (jsonObj == nil) {
		if (error) {
			*error = [NSError errorWithDomain:kGenericErrors andCode:0 andDescriptionKey:kGenericErrorDescription andUnderlying:0];
		}
		
		return NO;
	}
    
	NSError* jsonError = nil;
	*jsonObj = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&jsonError];
	if (!*jsonObj) {
		if (error) {
			*error = [NSError errorWithDomain: kServerErrors andCode: kServerErrorGeneric andDescriptionKey: kGenericServerErrorDescription andUnderlying: jsonError];
		}
		
		return NO;
	}
	
	if ([*jsonObj isKindOfClass:[NSArray class]]) {
		return YES;
	}
	
	BOOL isError = (![[[*jsonObj valueForKey:@"status"] lowercaseString] isEqualToString:@"success"]);
	if (!isError) {
		return YES;
	}
	
	NSNumber* errorCode = [*jsonObj valueForKey:@"code"];
	NSString* errorMessage;
	if( [errorCode intValue] == kErrorCodeNotAuthorized ) {
		errorMessage = kNotAuthorizedDescription;
	}
	else if( [errorCode intValue] == kErrorCodeGeneric ) {
		errorMessage = kGenericServerErrorDescription;
	}
	else {
		errorMessage = [*jsonObj valueForKey: @"message"];
	}
	
	if (error) {
		*error = [NSError errorWithDomain: kServerErrors andCode: kServerErrorNotAuthorized andDescriptionKey: errorMessage andUnderlying: jsonError];
	}
	
	return NO;
}

@end
