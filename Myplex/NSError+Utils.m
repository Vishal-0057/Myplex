//
//  NSError+Utils.m
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "NSError+Utils.h"

@implementation NSError (Utils)

+ (NSError*)errorWithDomain:(NSString*)domain andCode:(NSInteger)code andDescriptionKey:(NSString*)descriptionKey andUnderlying:(NSError*)underlyingError
{
	NSMutableDictionary* userInfoDict = [NSMutableDictionary dictionaryWithDictionary: @{ NSLocalizedDescriptionKey : descriptionKey }];
	
	if (underlyingError != nil) {
		[userInfoDict setValue: [underlyingError copy] forKey: NSUnderlyingErrorKey];
	}
	
	NSError* err = [self errorWithDomain: domain code: code userInfo: userInfoDict];
	
	return err;
}


- (void)logDetailedError
{
    NSArray* _ft_detailedErrors = [[self userInfo] objectForKey:NSDetailedErrorsKey];
    if(_ft_detailedErrors != nil && [_ft_detailedErrors count] > 0) {
        for(NSError* _ft_detailedError in _ft_detailedErrors) {
            NSLog(@"DetailedError: %@", [_ft_detailedError userInfo]);
        }
    } else
        NSLog(@"Error %@", self.localizedDescription);

}

@end
