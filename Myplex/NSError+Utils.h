//
//  NSError+Utils.h
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Utils)

+ (NSError*)errorWithDomain:(NSString*)domain andCode:(NSInteger)code andDescriptionKey: (NSString*)descriptionKey andUnderlying:(NSError*)underlyingError;

- (void)logDetailedError;

@end
