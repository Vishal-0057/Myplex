//
//  UIViewController+ShowModalFromView.h
//  Myplex
//
//  Created by Igor Ostriz on 18/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ShowModalFromView)

- (void)presentModalViewController:(UIViewController *)modalViewController fromView:(UIView *)view;

@end
