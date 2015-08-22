//
//  UIView+ImageSnapshot.m
//  RESideMenuExample, Myple
//
//  Created by Sam Oakley on 22/07/2013.
//  Modified by Igor Ostriz for Myplex project on 20/11/2013
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "UIView+ImageSnapshot.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (ImageSnapshot)

- (UIImage*)snapshotImage
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(self.bounds.size);
    }

    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]];
        [invoc setTarget:self];
        [invoc setSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)];
        CGRect arg2 = self.bounds;
        [invoc setArgument:&arg2 atIndex:2];
        BOOL afterUpdate = NO;
        [invoc setArgument:&afterUpdate atIndex:3];
        [invoc invoke];
    } else {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


- (UIImage*)snapshotImageWithRect:(CGRect)rect
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(self.bounds.size);
    }
    
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]];
        [invoc setTarget:self];
        [invoc setSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)];
        CGRect arg2 = rect;
        [invoc setArgument:&arg2 atIndex:2];
        BOOL afterUpdate = NO;
        [invoc setArgument:&afterUpdate atIndex:3];
        [invoc invoke];
    } else {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
