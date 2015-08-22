//
//  MainAuthenticationViewController.h
//  Myplex
//
//  Created by shiva on 10/10/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PosterView.h"

@interface MainAuthenticationViewController : UIViewController<UITextFieldDelegate,GPPSignInDelegate> {
    UIButton *facebookBtn;
    UIButton *googleBtn;
    UIButton *twitterBtn;
    UIButton *createAccountBtn;
    UIButton *signInToMyplexBtn;
    
    UIView *transperentView;
    UILabel *gapLbl;
    
    IBOutlet UIImageView *logoImageView;
    
    UIButton *letMeInBtn;
    
    AppDelegate *appDelegate;
    
    /** set to YES when view goes up and NO when view is down.
     */
    BOOL isViewModeUp;
    
    PosterView *posterView;
    //FBSession *session;
}

@end
