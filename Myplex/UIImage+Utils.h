//
//  UIImage+Utils.h
//  Myplex
//
//  Created by Igor Ostriz on 05/12/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

- (UIImage *)cropToRectangle:(CGRect)rect;
- (UIImage*)imageByScalingDownAndCroppingForSize:(CGSize)targetSize;

@end
