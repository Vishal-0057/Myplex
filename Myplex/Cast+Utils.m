//
//  Cast+Utils.m
//  Myplex
//
//  Created by Igor Ostriz on 10/6/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "Cast+Utils.h"
#import "StandardKeySanitizer.h"

@implementation Cast (Utils)

+ (id <RemoteKeySanitizer>)keySanitizer
{
    static StandardKeySanitizer *_sanitizer;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sanitizer = [[StandardKeySanitizer alloc] initWithKeys:@{
                                                                  @"types" : @"type",
                                                                  @"roles" : @"role",
                                                                  }];
    });
    
	return _sanitizer;
}

@end
