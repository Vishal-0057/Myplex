//
//  SignUpViewController.m
//  Myplex
//
//  Created by shiva on 9/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "AppData.h"
#import "CreateUser.h"
#import "LoginNavigationController.h"
#import "Notifications.h"
#import "SignUpViewController.h"
#import "UIAlertView+ReportError.h"
#import "Validation.h"
#import "GetProfile.h"

#import <CoreText/CoreText.h>

@interface SignUpViewController ()

@end

@implementation SignUpViewController

@synthesize posterView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"Join %@",kAppTitle];
    
    self.navigationController.navigationBar.hidden = NO;

    appDelegate = [[UIApplication sharedApplication]delegate];
    
    //posterView = [[PosterView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:posterView];
    
    UIView *transperentView = [[UIView alloc]init];
    isIPhone
        transperentView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    else
        transperentView.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
    
    transperentView.tag = 1;
    transperentView.backgroundColor = [UIColor colorWithRed:57.0f/255.0f green:57.0f/255.0f blue:57.0f/255.0f alpha:0.65];
    [self.view addSubview:transperentView];
    
    [createAccountBtn setTitleColor:[UIColor colorWithRed:159.0f/255.0f green:159.0f/255.0f blue:159.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    inputFieldsView.layer.cornerRadius = 3.0;
    
    [self.view bringSubviewToFront:inputFieldsView];
    [self.view bringSubviewToFront:logoImageView];
    [self.view bringSubviewToFront:signUpMsgView];
    [self.view bringSubviewToFront:createAccountBtn];

//    userIdField.textColor = [UIColor colorWithRed:159.0f/255.0f green:159.0f/255.0f blue:159.0f/255.0f alpha:1.0f];
//    passwordField.textColor = [UIColor colorWithRed:159.0f/255.0f green:159.0f/255.0f blue:159.0f/255.0f alpha:1.0f];
    
    NSString *signupMsg = @"By creating an account and signing up to Viva, I accept the Terms of service and Privacy policy";
    NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString: signupMsg];
    
    [str beginEditing];
    
    [str addAttribute:NSFontAttributeName
                value:[UIFont fontWithName:@"Helvetica" size:14.0]
                range:[signupMsg rangeOfString:signupMsg]];
    
    [str addAttribute:NSLinkAttributeName value:@"http://s.myplex.tv/terms" range:[signupMsg rangeOfString:@"Privacy policy"]];
    [str addAttribute:NSFontAttributeName
                   value:[UIFont fontWithName:@"Helvetica-Bold" size:14.0]
                   range:[signupMsg rangeOfString:@"Privacy policy"]];
    [str addAttribute:(NSString*)kCTForegroundColorAttributeName
                value:[UIColor blueColor]
                range:[signupMsg rangeOfString:@"Privacy policy"]];
    
    [str addAttribute:NSLinkAttributeName value:@"http://s.myplex.tv/terms" range:[signupMsg rangeOfString:@"Terms of service"]];
    [str addAttribute:NSFontAttributeName
                value:[UIFont fontWithName:@"Helvetica-Bold" size:14.0]
                range:[signupMsg rangeOfString:@"Terms of service"]];
    [str addAttribute:(NSString*)kCTForegroundColorAttributeName
                value:(id)[[UIColor blueColor] CGColor]
                range:[signupMsg rangeOfString:@"Terms of service"]];
    
    [str endEditing];
    
    [signUpMsgView setAllowsEditingTextAttributes: YES];
    [signUpMsgView setSelectable: YES];
    [signUpMsgView setEditable:NO];
    [signUpMsgView setAttributedText:str];
    [signUpMsgView setTextColor:[UIColor whiteColor]];
    [signUpMsgView setBackgroundColor:[UIColor clearColor]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(singUpDidFail:) name:kNotificationUserCreateError object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(singUpDidSuccess:) name:kNotificationUserCreated object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [userIdField becomeFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
}

-(void)picProfile:(id)sender {
    
}

-(IBAction)createAccount:(id)sender {
    
    //[Flurry logEvent:@"SignUp-Selected"];

    userIdField.text = [userIdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    passwordField.text = [passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (userIdField.text.length == 0 && passwordField.text.length == 0) {
        [appDelegate showAlert:@"Oops!" withMessage:kUserIdEmptyMessage];
        return;
    }
    
    // init the validation class
    Validation *validate = [[Validation alloc] init];
    
    BOOL phoneNumber = [validate phoneNumber:userIdField.text];
    if (phoneNumber) {
        userIdField.text = [NSString stringWithFormat:@"%@@apalya.myplex.tv",userIdField.text];
    }
    BOOL emailValid = NO;
    if (userIdField.text.length > 0) {
        // validate email and pop alert if need be
        emailValid = [validate emailRegEx:userIdField.text];
        
        if (!emailValid) {
            [appDelegate showAlert:@"Invalid Email" withMessage:kInvalidEmailMessage];
            [userIdField becomeFirstResponder];
            return;
        }
    }
    
    // validate password and pop alert if need be
	BOOL passwordValid = [validate passwordMinLength:6 password:passwordField.text];
	
	if (!passwordValid) {
        [appDelegate showAlert:@"invalid password" withMessage:kPasswordStrengthMessage];
		[passwordField becomeFirstResponder];
        return;
	}
    
    BOOL clientKeyValid = [appDelegate isClientKeyValid];
    
    if (clientKeyValid) {
        [self requestForSignUp:[AppData shared].data[@"clientKey"]];
    } else {
        [appDelegate requestForClientKeyGenerationWithCompletionHandler:^(BOOL success, NSDictionary *response, NSError *error) {
            if (success) {
                [self requestForSignUp:[AppData shared].data[@"clientKey"]];
            }
        }];
    }
 
   	NSLog(@"emailEntry: %@",userIdField.text);
    NSLog(@"emailEntry: %@",passwordField.text);
}

-(void)requestForSignUp:(NSString *)clientKey {
    
    CreateUser *createUser = [[CreateUser alloc]initWithManagedObjectContext:nil];
    
    [AppDelegate showActivityIndicatorWithText:@"Loading..."];
    
    [Analytics logEvent:EVENT_SIGNUP parameters:@{SIGNUP_TYPE_PROPERTY:SIGNUP_TYPES_STRING(Myplex),SIGNUP_STATUS_PROPERTY:SIGNUP_STATUS_TYPES_STRING(clicked),SIGNUP_EMAIL_PROPERTY:userIdField.text,SIGNUP_DATE_PROPERTY:[NSDate date]}  timed:YES];
    //[Flurry logEvent:@"Login- SignUp" timed:YES];
    
    [createUser createUserWithEmail:userIdField.text phoneNumber:nil passowrd:passwordField.text fullName:nil receiveMailUpdate:0 receiveSMSUpdates:0 clientKey:clientKey];
}

-(void)singUpDidSuccess:(NSNotification *)notification {
    
    [AppDelegate removeActivityIndicator];
    
    NSDictionary *response = notification.object;
    
    //[Flurry endTimedEvent:@"Login- SignUp" withParameters:@{@"Status":@"Success"}];
    
    [Analytics endEvent:EVENT_SIGNUP parameters:@{SIGNUP_TYPE_PROPERTY:SIGNUP_TYPES_STRING(Myplex),SIGNUP_STATUS_PROPERTY:SIGNUP_STATUS_TYPES_STRING(SignUpSuccess),SIGNUP_STATUS_MESSAGE_PROPERTY:response[@"message"]?:@"Successfully registered to myplex", SIGNUP_DATE_PROPERTY:[NSDate date],EVENT_TIMED:[NSDate date]}];
    
    GetProfile *getProfile = [[GetProfile alloc]init];
    [getProfile getProfile:[AppData shared].data[@"clientKey"]];

    [posterView invalidateTimer];

    LoginNavigationController *lnc = (LoginNavigationController *)self.navigationController;
    [lnc dismiss];
}

-(void)singUpDidFail:(NSNotification *)notificaiton {
    
    [AppDelegate removeActivityIndicator];

    NSError *error = notificaiton.object;
    
    //[Flurry endTimedEvent:@"Login- SignUp" withParameters:@{@"Status":@"Failure"}];
    
    [Analytics endEvent:EVENT_SIGNUP parameters:@{SIGNUP_TYPE_PROPERTY:SIGNUP_TYPES_STRING(Myplex),SIGNUP_STATUS_PROPERTY:SIGNUP_STATUS_TYPES_STRING(SignUpFailure),SIGNUP_STATUS_MESSAGE_PROPERTY:[error userInfo][NSLocalizedDescriptionKey]?:@"Successfully registered to myplex", SIGNUP_DATE_PROPERTY:[NSDate date],EVENT_TIMED:[NSDate date]}];
    
    if ([notificaiton.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *response = notificaiton.object;
        [appDelegate showAlert:@"Oops!" withMessage:response[@"message"]];
    } else if([notificaiton.object isKindOfClass:[NSError class]]){
        NSError *error = notificaiton.object;
        //Cleanit up
        NSDictionary* userInfoDictionary = [error userInfo];
        NSString* errorMessage = [userInfoDictionary objectForKey: NSLocalizedDescriptionKey];
        
        if (errorMessage == nil) {
            errorMessage = userInfoDictionary[@"error"];
            if (errorMessage) {
                errorMessage = [errorMessage stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[errorMessage  substringToIndex:1] capitalizedString]];
            }
        }
        [appDelegate showAlert:@"Oops!" withMessage:errorMessage];
       // [UIAlertView showAlertWithError:notificaiton.object];
    }
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
//                    [userIdField becomeFirstResponder];
//                    return YES;
//                case 1:
//                    [passwordField becomeFirstResponder];
//                    return YES;
////                case 2:
////                    [fullNameField becomeFirstResponder];
////                    return YES;
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

#pragma mark UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    return TRUE;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    isIPhone
        // Return YES for supported orientations
        if (interfaceOrientation == UIInterfaceOrientationPortrait) {
            return YES;
        } else {
            return NO;
        }
    else
        if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            return YES;
        } else {
            return NO;
        }
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
