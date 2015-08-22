//
//  SignUpViewController.h
//  Myplex
//
//  Created by shiva on 9/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PosterView.h"

@interface SignUpViewController : UIViewController <UITextFieldDelegate,UITextViewDelegate> {
    
    IBOutlet UITextField *userIdField;
    IBOutlet UITextField *passwordField;
    
    IBOutlet UITextView *signUpMsgView;
    
    IBOutlet UIView *inputFieldsView;
    IBOutlet UIImageView *logoImageView;
    
    IBOutlet UIButton *createAccountBtn;
    
    AppDelegate *appDelegate;
    
    PosterView *posterView;
}

@property (nonatomic, strong)PosterView *posterView;

-(IBAction)createAccount:(id)sender;

@end
