//
//  NSString+MakeCamelCase.h
//  Myplex
//
//  Created by Igor Ostriz on 8/16/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MakeCamelCase)

- (NSString*)camelCased;
- (NSString*)camelBackedFromBumpyCase;

@end
