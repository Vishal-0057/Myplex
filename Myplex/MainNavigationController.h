//
//  ViewController.h
//  Myplex
//
//  Created by Igor Ostriz on 8/27/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface MainNavigationController : UINavigationController <FBFriendPickerDelegate,FBViewControllerDelegate>

- (void)fullRefresh:(BOOL)animated;
-(void) checkForLogin;
-(void)showFBInviteDialog;
//-(void)reloadMenuItems;

@end
