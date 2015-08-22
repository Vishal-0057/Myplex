//
//  StandardKeySanitizer.h
//  Myplex
//
//  Created by Igor Ostriz on 8/16/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSManagedObject+Utils.h"

@interface StandardKeySanitizer : NSObject <RemoteKeySanitizer>

+ (StandardKeySanitizer*)keySanitizer;

- (id)initWithKeys:(NSDictionary *)sanitizeKeys;

@end
