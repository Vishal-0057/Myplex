//
//  UIViewController+ShowModalFromView.m
//  Myplex
//
//  Created by Igor Ostriz on 18/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "UIViewController+ShowModalFromView.h"

@implementation UIViewController (ShowModalFromView)

- (void)presentModalViewController:(UIViewController *)modalViewController fromView:(UIView *)view
{
    modalViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // Add the modal viewController but don't animate it. We will handle the animation manually
    [self presentViewController:modalViewController animated:NO completion:nil];
    
    // Remove the shadow. It causes weird artifacts while animating the view.
    CGColorRef originalShadowColor = modalViewController.view.layer.shadowColor;
    modalViewController.view.layer.shadowColor = [[UIColor clearColor] CGColor];
    
    // Save the original size of the viewController's view
    CGRect originalFrame = modalViewController.view.frame;
    
    // Set the frame to the one of the view we want to animate from
    modalViewController.view.frame = view.frame;
    
    // Begin animation
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
        modalViewController.view.frame = originalFrame;
    } completion:^(BOOL finished) {
        modalViewController.view.layer.shadowColor = originalShadowColor;
    }];
    
//    [UIView animateWithDuration:1.0f
//                     animations:^{
//                         // Set the original frame back
//                         modalViewController.view.frame = originalFrame;
//                     }
//                     completion:^(BOOL finished) {
//                         // Set the original shadow color back after the animation has finished
//                         modalViewController.view.layer.shadowColor = originalShadowColor;
//                     }];
}

@end
