//
//  ViewController.m
//  MyPlexLogin
//
//  Created by shiva on 9/5/13.
//  Copyright (c) 2013 Apalya Technlologies Pvt. Ltd. All rights reserved.
//

#import "AppData.h"
#import "LoginUser.h"
#import "LoginNavigationController.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "UIAlertView+ReportError.h"
#import "Validation.h"
#import "PosterView.h"
#import "GetProfile.h"
#import "UIAlertView+Blocks.h"

//Sample
//#define kGooglePlusClientId @"1056331385451.apps.googleusercontent.com"
//Apalya dev
//#define kGooglePlusClientId @"1077921160117-qcpe6i9ho1rlmtguv13n6d30v9c1jd2k.apps.googleusercontent.com"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize posterView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"Sign into %@",kAppTitle];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    retrievePasswordBtn.hidden = YES;
    self.navigationController.navigationBar.hidden = NO;

//    posterView = [[PosterView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:posterView];
    
    UIView *transperentView = [[UIView alloc]init];
    isIPhone
        transperentView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    else
        transperentView.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
    
//    CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    transperentView.tag = 1;
    transperentView.backgroundColor = [UIColor colorWithRed:57.0f/255.0f green:57.0f/255.0f blue:57.0f/255.0f alpha:0.65];
    [self.view addSubview:transperentView];
    
    [self.view bringSubviewToFront:inputFieldsView];
    [self.view bringSubviewToFront:logoImageView];
    [self.view bringSubviewToFront:signInToMyplexBtn];
    [self.view bringSubviewToFront:forgotPasswordBtn];
    [self.view bringSubviewToFront:retrievePasswordBtn];
    
    inputFieldsView.layer.cornerRadius = 3.0f;
    
    [signInToMyplexBtn setTitleColor:[UIColor colorWithRed:159.0f/255.0f green:159.0f/255.0f blue:159.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [forgotPasswordBtn setTitleColor:[UIColor colorWithRed:159.0f/255.0f green:159.0f/255.0f blue:159.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [retrievePasswordBtn setTitleColor:[UIColor colorWithRed:159.0f/255.0f green:159.0f/255.0f blue:159.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logInDidSuccess:) name:kNotificationUserAuthenticated object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logInDidFail:) name:kNotificationLoginError object:nil];
   
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(passwordRetrievalDidSuccess:) name:kNotificationRetrievePassword object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(passwordRetrievalDidFail:) name:kNotificationRetrievePasswordError object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [userField becomeFirstResponder];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
//    if (posterView) {
//        [posterView invalidateTimer];
//    }
}

-(IBAction)signInToMyplex:(id)sender
{
    
    //[Flurry logEvent:@"sign in to myplex selected"];
    
    userField.text = [userField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if (!userField.text.length > 0) {
		
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Invalid UserId"
							  message:kUserIdEmptyMessage
							  delegate:self
							  cancelButtonTitle:nil
							  otherButtonTitles:@"Okay",
							  nil];
		[alert show];
		[userField becomeFirstResponder];
		return;
	}
	
	// init the validation class
	Validation *validate = [[Validation alloc] init];
	
    BOOL phoneNumber = [validate phoneNumber:userField.text];
    if (phoneNumber) {
        userField.text = [NSString stringWithFormat:@"%@@apalya.myplex.tv",userField.text];
    }
    
	// validate password and pop alert if need be
//	BOOL passwordValid = [validate passwordMinLength:6 password:passwordField.text];
//	
//	if (!passwordValid) {
//		UIAlertView *alert = [[UIAlertView alloc]
//							  initWithTitle:@"Invalid Password"
//							  message:kPasswordStrengthMessage
//							  delegate:self
//							  cancelButtonTitle:nil
//							  otherButtonTitles:@"Okay",
//							  nil];
//		[alert show];
//		[passwordField becomeFirstResponder];
//        return;
//        
//	}
	
    BOOL clientKeyValid = [appDelegate isClientKeyValid];
    
    if (clientKeyValid) {
        [self makeLoginRequest:[AppData shared].data[@"clientKey"]];
    } else {
        [appDelegate requestForClientKeyGenerationWithCompletionHandler:^(BOOL success, NSDictionary *response, NSError *error) {
            if (success) {
                [self makeLoginRequest:[AppData shared].data[@"clientKey"]];
            }
        }];
    }
    
	NSLog(@"emailEntry: %@",userField.text);
	NSLog(@"passwordEntry: %@",passwordField.text);

}

-(void)makeLoginRequest:(NSString *)clientKey {
    [AppDelegate showActivityIndicatorWithText:@"Loading..."];
    
    //[Flurry logEvent:@"Login- SignIn" timed:YES];
    [Analytics logEvent:EVENT_LOGIN parameters:@{LOGIN_TYPE_PROPERTY:LOGIN_TYPES_STRING(myplex),LOGIN_DATE_PROPERTY:[NSDate date],LOGIN_EMAIL_PROPERTY:userField.text,LOGIN_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(Clicked), EVENT_TIMED:[NSDate date]}  timed:YES];
    
    LoginUser *loginUser = [[LoginUser alloc]init];
    [loginUser authenticateUserWithUserId:userField.text password:passwordField.text clientKey:clientKey];
}

-(void)logInDidSuccess:(NSNotification *)notification {
    
    NSDictionary *dict = notification.object;
    NSDictionary *response = dict[@"response"];
    [Analytics endEvent:EVENT_LOGIN parameters:@{LOGIN_TYPE_PROPERTY:LOGIN_TYPES_STRING(myplex),LOGIN_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(Success),LOGIN_STATUS_MESSAGE_PROPERTY:response[@"message"], EVENT_TIMED:[NSDate date]}];
    
    [AppDelegate removeActivityIndicator];
    
    GetProfile *getProfile = [[GetProfile alloc]init];
    [getProfile getProfile:[AppData shared].data[@"clientKey"]];
    
    [posterView invalidateTimer];

    LoginNavigationController *lnc = (LoginNavigationController *)self.navigationController;
    [lnc dismiss];
}

-(void)logInDidFail:(NSNotification *)notificaiton {
    
    NSDictionary *dict = notificaiton.object;
    NSError *error = dict[@"error"];
    
    [UIAlertView showAlertWithError:error];
    
    [Analytics endEvent:EVENT_LOGIN parameters:@{LOGIN_TYPE_PROPERTY:LOGIN_TYPES_STRING(myplex),LOGIN_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(Failure),LOGIN_STATUS_MESSAGE_PROPERTY:[error userInfo][NSLocalizedDescriptionKey]?:@"Login Failed", EVENT_TIMED:[NSDate date]}];
    
    [AppDelegate removeActivityIndicator];
}

-(IBAction)showForgotPasswordLayout:(id)sender
{
    CGRect viewFrame;
    CGRect retrievePasswordBtnFrame;
    CGRect forgotPasswordBtnFrame;
    
    if ([forgotPasswordBtn.titleLabel.text isEqualToString:[NSString stringWithFormat:@"Sign into %@",kAppTitle]]) {
        viewFrame = textFieldsView.frame;
        viewFrame.size.height = textFieldsView.frame.size.height + 46;
        retrievePasswordBtnFrame = signInToMyplexBtn.frame;
        retrievePasswordBtnFrame.origin.y = CGRectGetMaxY(viewFrame) + 10;
        forgotPasswordBtnFrame = retrievePasswordBtnFrame;
        forgotPasswordBtnFrame.origin.y = CGRectGetMaxY(retrievePasswordBtnFrame) + 10;
        passwordField.hidden = NO;
        retrievePasswordBtn.hidden = YES;
        signInToMyplexBtn.hidden = NO;
        lineLbl.hidden = NO;
        
        userField.placeholder = @"Email";

        [userField resignFirstResponder];

        [forgotPasswordBtn setTitle:@"Forgot password? Lets fix it here" forState:UIControlStateNormal];
    } else {
        viewFrame = textFieldsView.frame;
        viewFrame.size.height = textFieldsView.frame.size.height - 46;
        retrievePasswordBtnFrame = signInToMyplexBtn.frame;
        retrievePasswordBtnFrame.origin.y = CGRectGetMaxY(viewFrame) + 10;
        forgotPasswordBtnFrame = retrievePasswordBtnFrame;
        forgotPasswordBtnFrame.origin.y = CGRectGetMaxY(retrievePasswordBtnFrame) + 10;
        
        passwordField.hidden = YES;
        retrievePasswordBtn.hidden = NO;
        signInToMyplexBtn.hidden = YES;
        lineLbl.hidden = YES;
        
        userField.placeholder = @"Email";
        
        [forgotPasswordBtn setTitle:[NSString stringWithFormat:@"Sign into %@",kAppTitle] forState:UIControlStateNormal];
        [userField becomeFirstResponder];
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    textFieldsView.frame = viewFrame;
    retrievePasswordBtn.frame = retrievePasswordBtnFrame;
    signInToMyplexBtn.frame = retrievePasswordBtnFrame;
    forgotPasswordBtn.frame = forgotPasswordBtnFrame;
    
    [UIView commitAnimations];
}

-(IBAction)retrievePassword:(id)sender
{
    //[Flurry logEvent:@"forgot password requested"];
    
    userField.text = [userField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // init the validation class
	Validation *validate = [[Validation alloc] init];
	
    BOOL phoneNumber = [validate phoneNumber:userField.text];
    if (phoneNumber) {
        userField.text = [NSString stringWithFormat:@"%@@apalya.myplex.tv",userField.text];
    }
	
   BOOL emailValid = [validate emailRegEx:userField.text];
    
	if (!emailValid) {
		
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Invalid UserId"
							  message:kUserIdEmptyMessage
							  delegate:self
							  cancelButtonTitle:nil
							  otherButtonTitles:@"Okay",
							  nil];
		[alert show];
		[userField becomeFirstResponder];
		return;
	}
    
    BOOL clientKeyValid = [appDelegate isClientKeyValid];
    
    if (clientKeyValid) {
        [self makeForgotPasswordRequest:[AppData shared].data[@"clientKey"]];
    } else {
        [appDelegate requestForClientKeyGenerationWithCompletionHandler:^(BOOL success, NSDictionary *response, NSError *error) {
            if (success) {
                [self makeForgotPasswordRequest:[AppData shared].data[@"clientKey"]];
            }
        }];
    }
}

-(void)makeForgotPasswordRequest:(NSString *)clientKey {
    [AppDelegate showActivityIndicatorWithText:@"Loading..."];
    
    //[Flurry logEvent:@"Login- ForgotPassword" timed:YES];
    [Analytics logEvent:EVENT_LOGIN parameters:@{LOGIN_FORGOT_PASSWORD_PROPERTY:LOGIN_TYPES_STRING(ForgotPassword),LOGIN_DATE_PROPERTY:[NSDate date],LOGIN_EMAIL_PROPERTY:userField.text,LOGIN_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(Clicked), EVENT_TIMED:[NSDate date]}  timed:YES];
    
    LoginUser *loginUser = [[LoginUser alloc]init];
    [loginUser retrievePasswordOf:userField.text clientKey:clientKey];

}

-(void)passwordRetrievalDidSuccess:(NSNotification *)notification {
    
    //[Flurry endTimedEvent:@"Login- ForgotPassword" withParameters:@{@"Status":@"Success"}];
    NSDictionary *response = notification.object;
    
    [UIAlertView alertViewWithTitle:response[@"status"] message:response[@"message"]];
    
    [Analytics endEvent:EVENT_LOGIN parameters:@{LOGIN_FORGOT_PASSWORD_PROPERTY:LOGIN_TYPES_STRING(ForgotPassword),LOGIN_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(Success),LOGIN_STATUS_MESSAGE_PROPERTY:response[@"message"], EVENT_TIMED:[NSDate date]}];

    [AppDelegate removeActivityIndicator];
}

-(void)passwordRetrievalDidFail:(NSNotification *)notification {
    
    NSDictionary *dict = notification.object;
    NSError *error = dict[@"error"];
    
    [UIAlertView showAlertWithError:error];
    
//    if (error) {
//        [Flurry logError:@"Login- ForgotPassword" message:@"Failure" error:error];
//    }
//    [Flurry endTimedEvent:@"Login- ForgotPassword" withParameters:@{@"Status": @"Failure"}];
    
    [Analytics endEvent:EVENT_LOGIN parameters:@{LOGIN_FORGOT_PASSWORD_PROPERTY:LOGIN_TYPES_STRING(ForgotPassword),LOGIN_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(Failure),LOGIN_STATUS_MESSAGE_PROPERTY:[error userInfo][NSLocalizedDescriptionKey]?:@"Retrieve Failed", EVENT_TIMED:[NSDate date]}];
    
    [AppDelegate removeActivityIndicator];
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
	
    return TRUE;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
    @try {
//        if(textField.tag < 3) {
//            switch (textField.tag) {
//                case 0:
//                    [userField becomeFirstResponder];
//                    return YES;
//                case 1:
//                    [passwordField becomeFirstResponder];
//                    return YES;
//                    //                case 2:
//                    //                    [fullNameField becomeFirstResponder];
//                    //                    return YES;
//                default:
//                    break;
//            }
//        }
        
        [textField resignFirstResponder];
        
        return TRUE;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}

//For iOS 6
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    isIPhone
        return UIInterfaceOrientationMaskPortrait;
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    isIPhone
        return UIInterfaceOrientationPortrait;
    return UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
    
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
//        return YES;
//    } else {
//        return NO;
//    }
//}

//-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
//	
//    if (isViewModeUp) {
//        return TRUE;
//    } else {
//        [self textFieldDidBeginEditing:userIdField];
//        return FALSE;
//    }
//    //return TRUE;
//}
//
//-(void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    
//    @try {
//        if ([textField isEqual:userIdField] || [textField isEqual:passwordField])
//        {
//            //move the main view, so that the keyboard does not hide it.
//            if  (self.view.frame.origin.y >= 0)
//            {
//                if (!isViewModeUp) {
//                    [self setViewMovedUp:YES];
//                }
//            }
//        }
//    }
//    @catch (NSException *exception) {
//        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
//    }
//    @finally {
//    }
//}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//	
//    @try {
//        if(textField.tag < 1) {
//            switch (textField.tag) {
//                case 0:
//                    [passwordField becomeFirstResponder];
//                    return YES;
//                default:
//                    break;
//            }
//        }
//        
//        if (textField.tag == 1) {
//            if (isViewModeUp) {
//                [self setViewMovedUp:NO];
//            }
//        }
//        
//        [textField resignFirstResponder];
//        
//        return TRUE;
//    }
//    @catch (NSException *exception) {
//        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
//    }
//    @finally {
//        
//    }
//}
//
//-(void)setViewMovedUp:(BOOL)movedUp {
//    
//    @try {
//
//        NSInteger keyboardOffset = 0;
//        CGRect screenRect = [[UIScreen mainScreen] bounds];
//        if (screenRect.size.height == 568) {
//            keyboardOffset = 160;
//        } else {
//            keyboardOffset = 220;
//        }
//        
//        if (movedUp) {
//            isViewModeUp = YES;
//
//            [self fadeOutViews:0.5];
//        } else {
//            isViewModeUp = NO;
//
//            [self updateViewFrame:screenRect withKeyboardOffset:keyboardOffset];
//            
//        }
//        
//    }
//    @catch (NSException *exception) {
//        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
//    }
//    @finally {
//    }
//}
//
//-(void)fadeOutViews:(CGFloat)fadeOutValue {
//    //Fade In FB,G+ and OR views
//    [UIView beginAnimations:nil context:nil];
//    if (fadeOutValue > 0) {
//        [UIView setAnimationDidStopSelector: @selector(fadeOutComplete)];
//        [UIView setAnimationDelegate:self];
//    }
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//    [UIView setAnimationDuration:FADE_ANIMATION_DURATION];  //.25 looks nice as well.
//    
//    facebookBtn.alpha = fadeOutValue;
//    twitterBtn.alpha = fadeOutValue;
//    orLabel.alpha =  fadeOutValue;
//    facebookLbl.alpha = fadeOutValue;
//    googlePlugLbl.alpha = fadeOutValue;
//    logoImgView.alpha = fadeOutValue;
//
//    [UIView commitAnimations];
//}
//
//-(void)fadeInViews:(CGFloat)fadeInValue {
//    //Fade In FB,G+ and OR views
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//    [UIView setAnimationDuration:FADE_ANIMATION_DURATION];  //.25 looks nice as well.
//    
//    facebookBtn.alpha = fadeInValue;
//    twitterBtn.alpha = fadeInValue;
//    orLabel.alpha =  fadeInValue;
//    facebookLbl.alpha = fadeInValue;
//    googlePlugLbl.alpha = fadeInValue;
//    logoImgView.alpha = fadeInValue;
//    
//    [UIView commitAnimations];
//}

//-(void)updateViewFrame:(CGRect)screenRect withKeyboardOffset:(NSInteger)keyboardOffset {
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:VIEW_FRAMECHANGE_ANIMATION_DURATION]; // if you want to slide up the view
//    
//    CGRect viewRect = self.view.frame;
//    if (isViewModeUp)
//    {
//        [self fadeOutViews:0.0];
//
//        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
//        // 2. increase the size of the view so that the area behind the keyboard is covered up.
//        
//        viewRect.origin.y -= keyboardOffset;
//        viewRect.size.height += keyboardOffset;
//    }
//    else
//    {
//        [self fadeInViews:0.5f];
//        
//        // revert back to the normal state.
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector: @selector(updateViewFrameComplete)];
//        viewRect.origin.y += keyboardOffset;
//        viewRect.size.height -= keyboardOffset;
//    }
//    self.view.frame = viewRect;
//    [UIView commitAnimations];
//}
//
//-(void)updateViewFrameComplete {
//    [self fadeInViews:1.0f];
//}
//
//-(void)fadeOutComplete {
//    
//    NSInteger keyboardOffset = 0;
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    if (screenRect.size.height == 568) {
//        keyboardOffset = 160;
//    } else {
//        keyboardOffset = 220;
//    }
//
//    //[self textFieldShouldBeginEditing:userIdField];
//    [userIdField becomeFirstResponder];
//    [self updateViewFrame:screenRect withKeyboardOffset:keyboardOffset];
//}


@end
