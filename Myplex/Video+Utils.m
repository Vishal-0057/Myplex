//
//  Video+Utils.m
//  Myplex
//
//  Created by Igor Ostriz on 24/10/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "Video+Utils.h"

@implementation Video (Utils)

- (BOOL)isContainedIn:(NSSet *)setOfVideos
{
    for (id obj in setOfVideos) {
        if (![obj isKindOfClass:[Video class]]) {
            continue;
        }
        Video *other = (Video *)obj;
        if ([self.link isEqualToString:other.link]) {
            return YES;
        }
    }
    return NO;

}

@end
