//
//  PaymentPickerAnimatedTransitioning.m
//  Myplex
//
//  Created by Igor Ostriz on 19/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "CardsViewController.h"
#import "PaymentPickerAnimatedTransitioning.h"
#import "UIImage+Additional.h"
#import "UIView+ImageSnapshot.h"
#import <QuartzCore/QuartzCore.h>

@implementation PaymentPickerAnimatedTransitioning


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    toViewController.view.frame = container.bounds;
    CGPoint toViewCenter = toViewController.view.center;
    
    CGAffineTransform trans = CGAffineTransformMakeScale(self.sinkRect.size.width/toViewController.view.bounds.size.width, self.sinkRect.size.height/toViewController.view.bounds.size.height);
    if (_reverse) {
        [container insertSubview:toViewController.view belowSubview:fromViewController.view];
    }
    else {
        UIImage *background = [fromViewController.view snapshotImage];
        UIColor *blurColor = [UIColor colorWithWhite:1.0 alpha:0.3];//[UIColor colorWithWhite:0.11 alpha:0.73];
        background = [background blurredImageWithRadius:5 tintColor:blurColor saturationDeltaFactor:1.8 maskImage:nil];
        toViewController.view.layer.contents = (__bridge id)([background CGImage]);

        // set to center of rectangle
        CGPoint c = CGPointMake(CGRectGetMidX(self.sinkRect), CGRectGetMidY(self.sinkRect));
        toViewController.view.center = c;
        toViewController.view.transform = trans;
        
        [container addSubview:toViewController.view];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (_reverse) {
            fromViewController.view.transform = trans;
            fromViewController.view.center = CGPointMake(CGRectGetMidX(self.sinkRect), CGRectGetMidY(self.sinkRect));
            fromViewController.view.alpha = 0;
        }
        else {
            toViewController.view.center = toViewCenter;
            toViewController.view.transform = CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

@end
