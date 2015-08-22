//
//  Positioner.h
//  Myplex
//
//  Created by Igor Ostriz on 9/4/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Positioner : NSObject

- (CGFloat)getPositionForCard:(NSUInteger)index;
- (CGFloat)getPreviousPositionForPosition:(CGFloat)position;
- (CGFloat)getNextPositionForPosition:(CGFloat)position;

@end
