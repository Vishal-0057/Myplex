//
//  UserMgmtNavigationControllerViewController.m
//  Myplex
//
//  Created by Igor Ostriz on 9/17/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "LoginNavigationController.h"
#import "SignUpViewController.h"

@interface LoginNavigationController () <UINavigationControllerDelegate>

@end

@implementation LoginNavigationController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
//        self.delegate = self;
        //[Flurry logAllPageViews:self];
    }
    return self;
}

- (void)dismiss;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//static UIViewController *_previousViewController;
//
//    if (!_previousViewController) {
//        // skip the dummy
//        [self pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewControllerID"] animated:NO];
//    
//    } else {
//    
//        if ([viewController.restorationIdentifier isEqualToString:@"dummyRootID"]) {
//            _previousViewController = viewController = nil;
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
//    
//    }
//    _previousViewController = viewController;
//}


@end
