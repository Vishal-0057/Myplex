//
//  CardViewPool.h
//  Myplex
//
//  Created by Igor Ostriz on 6.9.2013..
//  Copyright (c) 2013. Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardViewReusePool : NSObject

- (UIView *)findView:(int)i;
- (UIView *)reuseView:(int)i;
- (void)addView:(int)i view:(UIView *)view;
- (void)removeView:(UIView *)view;
- (void)finishUpdate;

@end
