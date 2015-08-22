//
//  ViewController.h
//  MyPlexLogin
//
//  Created by shiva on 9/5/13.
//  Copyright (c) 2013 Apalya Technlologies Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PosterView.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate> {
    
    IBOutlet UITextField *userField;
    IBOutlet UITextField *passwordField;
    
    IBOutlet UIView *inputFieldsView;
    
    IBOutlet UIButton *signInToMyplexBtn;
    IBOutlet UIButton *forgotPasswordBtn;
    IBOutlet UIButton *retrievePasswordBtn;
    
    IBOutlet UIImageView *logoImageView;
    
    IBOutlet UIButton *letMeInBtn;
    
    IBOutlet UIView *textFieldsView;
    
    IBOutlet UILabel *lineLbl;
    
    AppDelegate *appDelegate;
    
    /** set to YES when view goes up and NO when view is down.
     */
    BOOL isViewModeUp;
    
    PosterView *posterView;
    
}

@property (nonatomic, strong)PosterView *posterView;

-(IBAction)signInToMyplex:(id)sender;
-(IBAction)showForgotPasswordLayout:(id)sender;
-(IBAction)retrievePassword:(id)sender;

@end
