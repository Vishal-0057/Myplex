//
//  MainAuthenticationViewController.m
//  Myplex
//
//  Created by shiva on 10/10/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "MainAuthenticationViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "AppData.h"
#import "LoginUser.h"
#import "LoginNavigationController.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "UIAlertView+ReportError.h"
#import "Validation.h"
#import "FHSTwitterEngine.h"
#import "OAToken.h"
#import "GetProfile.h"
#import "CreateUser.h"

#define kGooglePlusClientId @"409663879192.apps.googleusercontent.com"

#define kFacebooId @"582364305158936"

//Ayansys Saycheese Twitter
#define kOAuthTwitterConsumerKey @"jkUJcSNdfbnEMvK1RhD1Q"
#define kOAuthTwitterConsumerSecret @"0Z60rf1NDTm1GQJ6ArzN75wK2uc7w4bWe8me06sV6w"

#define FADE_ANIMATION_DURATION 0.25
#define VIEW_FRAMECHANGE_ANIMATION_DURATION 0.5


@interface MainAuthenticationViewController () {
    /** instance of FHSTwitterEngine class, contains the accesstoken & secret key and also contains the methods required to authenicate user and to check whther autheriztion required or not.
     */
    FHSTwitterEngine *_twitterEngine;
}

@end

@implementation MainAuthenticationViewController

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
    
//    NSDictionary *flurryParams = @{@"Status":@"Shown",@"Netowrk":ReachableViaWiFi?@"WIFI":@"Celllar Network",@"Previous Screen":@"None"};
//    
//    [Flurry logEvent:@"Login- Screen" withParameters:flurryParams];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0];
    
    appDelegate = [[UIApplication sharedApplication]delegate];
    
    CGRect screenRect = CGRectZero;
    isIPhone
    {
        posterView = [[PosterView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
        transperentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
        screenRect = [[UIScreen mainScreen] bounds];
    }
    else
    {
        posterView = [[PosterView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height,self.view.frame.size.width)];
        
        transperentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height,self.view.frame.size.width)];
        
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGFloat width = rect.size.height;
        CGFloat height = rect.size.width;
        screenRect = CGRectMake(rect.origin.x, rect.origin.y, width, height);
        
    }

//    posterView = [[PosterView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    
//    transperentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    
    transperentView.tag = 1;
    transperentView.backgroundColor = [UIColor colorWithRed:57.0f/255.0f green:57.0f/255.0f blue:57.0f/255.0f alpha:0.65];
    
    letMeInBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect letmeInBtnRect = CGRectZero;
    isIPhone
    {
        letmeInBtnRect = CGRectMake((screenRect.size.width/2 - 200/2), (screenRect.size.height - 30), 200, 30);//CGRectMake(60, (screenRect.size.height - 30), 200, 30);
        [letMeInBtn.titleLabel setFont:[UIFont fontWithName:@"MuseoSansRounded-700" size:14]];
    }
    else
    {
        letmeInBtnRect = CGRectMake((screenRect.size.width/2 - 350/2), (screenRect.size.height - 60), 350, 60);
        [letMeInBtn.titleLabel setFont:[UIFont fontWithName:@"MuseoSansRounded-700" size:28]];
    }
    
    letMeInBtn.frame = letmeInBtnRect;
    [letMeInBtn setTitle:@"browse as guest" forState:UIControlStateNormal];
    [letMeInBtn setTitleColor:[UIColor colorWithRed:159.0f/255.0f green:159.0f/255.0f blue:159.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [letMeInBtn addTarget:self action:@selector(skipAuthentication:) forControlEvents:UIControlEventTouchUpInside];
    //[letMeInBtn setHidden:YES];
    
    
    //Sign in to Myplex Button.
    signInToMyplexBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect signInBtnRect = CGRectZero;
    isIPhone
    {
        signInBtnRect = CGRectMake((letmeInBtnRect.origin.x - 37), (letmeInBtnRect.origin.y - 12 - 22), 127, 22);//CGRectMake(23, (letmeInBtnRect.origin.y - 12 - 22), 127, 22);
        [signInToMyplexBtn.titleLabel setFont:[UIFont fontWithName:@"MuseoSansRounded-700" size:14]];
    }
    else
    {
        signInBtnRect = CGRectMake((letmeInBtnRect.origin.x - 37*2), (letmeInBtnRect.origin.y - 18 - 44), 230, 44);
        [signInToMyplexBtn.titleLabel setFont:[UIFont fontWithName:@"MuseoSansRounded-700" size:28]];
    }
    
    signInToMyplexBtn.frame = signInBtnRect;
    [signInToMyplexBtn setTitle:[NSString stringWithFormat:@"Sign into %@",kAppTitle] forState:UIControlStateNormal];
    [signInToMyplexBtn setTitleColor:[UIColor colorWithRed:159.0f/255.0f green:159.0f/255.0f blue:159.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [signInToMyplexBtn addTarget:self action:@selector(loginWithMyPlex:) forControlEvents:UIControlEventTouchUpInside];
    
    isIPhone
        gapLbl = [[UILabel alloc]initWithFrame:CGRectMake(signInBtnRect.origin.x + signInBtnRect.size.width + 10, signInBtnRect.origin.y - 1, 1, 25)];
    else
        gapLbl = [[UILabel alloc]initWithFrame:CGRectMake(signInBtnRect.origin.x + signInBtnRect.size.width + 20, signInBtnRect.origin.y - 2, 2, 50)];
    
    gapLbl.backgroundColor = [UIColor colorWithRed:59.0f/255.0f green:59.0f/255.0f blue:59.0f/255.0f alpha:1.0f];
    
    
    //Create Account.
    CGRect createAccountBtnRect = CGRectZero;
    createAccountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    isIPhone
    {
        createAccountBtnRect = CGRectMake(gapLbl.frame.origin.x + gapLbl.frame.size.width + 10, (letmeInBtnRect.origin.y - 12 - 22), 127, 22);
        [createAccountBtn.titleLabel setFont:[UIFont fontWithName:@"MuseoSansRounded-700" size:14]];
    }
    else
    {
        createAccountBtnRect = CGRectMake(gapLbl.frame.origin.x + gapLbl.frame.size.width + 15, (letmeInBtnRect.origin.y - 18 - 44), 190, 44);
        [createAccountBtn.titleLabel setFont:[UIFont fontWithName:@"MuseoSansRounded-700" size:28]];
    }
    
    createAccountBtn.frame = createAccountBtnRect;
    [createAccountBtn setTitle:[NSString stringWithFormat:@"Join %@",kAppTitle] forState:UIControlStateNormal];
    [createAccountBtn setTitleColor:[UIColor colorWithRed:159.0f/255.0f green:159.0f/255.0f blue:159.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [createAccountBtn addTarget:self action:@selector(createAccount:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    //Google
    googleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect googleBtnRect  = CGRectZero;
    isIPhone
    {
        googleBtnRect = CGRectMake((screenRect.size.width/2 - 275/2), (signInBtnRect.origin.y - 12 - 39), /*132*/275, 39);//CGRectMake(23, (signInBtnRect.origin.y - 12 - 39), /*132*/275, 39);
        [googleBtn setImage:[UIImage imageNamed:@"signgoogle"] forState:UIControlStateNormal];
    }
    else
    {
        googleBtnRect = CGRectMake((screenRect.size.width/2 - 410/2), (signInBtnRect.origin.y - 12 - 78), /*132*/410, 78);
        [googleBtn setImage:[UIImage imageNamed:@"signingoogle-ipad"] forState:UIControlStateNormal];
    }
    
    googleBtn.frame = googleBtnRect;
    [googleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [googleBtn addTarget:self action:@selector(loginWithGooglePlus:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //Twitter
//    CGRect twitterBtnRect = CGRectMake(googleBtnRect.origin.x + googleBtnRect.size.width + 10, (signInBtnRect.origin.y - 12 - 39), 132, 39);
//    twitterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    twitterBtn.frame = twitterBtnRect;
//    [twitterBtn setImage:[UIImage imageNamed:@"signtwitter"] forState:UIControlStateNormal];
//    [twitterBtn addTarget:self action:@selector(loginWithTwitter:) forControlEvents:UIControlEventTouchUpInside];
//    [transperentView addSubview:twitterBtn];
    
    //Facebook
    facebookBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect facebookBtnRect = CGRectZero;
    isIPhone
    {
        facebookBtnRect = CGRectMake(googleBtnRect.origin.x, (googleBtnRect.origin.y - 12 - 39), 275, 39);
        [facebookBtn setImage:[UIImage imageNamed:@"signfb"] forState:UIControlStateNormal];
    }
    else
    {
        facebookBtnRect = CGRectMake(googleBtnRect.origin.x, (googleBtnRect.origin.y - 12 - 78), 410, 78);
        [facebookBtn setImage:[UIImage imageNamed:@"signinfb-ipad"] forState:UIControlStateNormal];
    }
    
    facebookBtn.frame = facebookBtnRect;
    [facebookBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [facebookBtn addTarget:self action:@selector(loginWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    // On iOS 4.0+ only, listen for background notification
    if(&UIApplicationWillResignActiveNotification != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    }
    
    // On iOS 4.0+ only, listen for foreground notification
    if(&UIApplicationWillEnterForegroundNotification != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self.view addSubview:posterView];

    [self.view addSubview:transperentView];
    
    [transperentView addSubview:logoImageView];
    [transperentView addSubview:signInToMyplexBtn];
    [transperentView addSubview:gapLbl];
    [transperentView addSubview:createAccountBtn];
    [transperentView addSubview:googleBtn];
    [transperentView addSubview:facebookBtn];
    [transperentView addSubview:letMeInBtn];

    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logInDidFail:) name:kNotificationLoginError object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logInDidSuccess:) name:kNotificationUserAuthenticated object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotificationLoginError object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotificationUserAuthenticated object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    // NSLog(@"applicationWillResignActive from loginview");
    //    [userIdField resignFirstResponder];
    //    [passwordField resignFirstResponder];
    //
    //    if (isViewModeUp) {
    //        [self setViewMovedUp:NO];
    //    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    NSLog(@"applicationWillEnterForeground in loginview");
    [AppDelegate removeActivityIndicator];
    
    //    if ([self isNotNull:userIdField]) {
    //        //[userNameTextField becomeFirstResponder];
    //        //[self setViewMovedUp:YES];
    //    }
}
//

#pragma mark LoginWithFacebook
-(void)loginWithFacebook:(id)sender {
    
    // if the session is open, then load the data for our view controller
    [Analytics logEvent:EVENT_LOGIN_SOCIAL  parameters:@{LOGIN_TYPE_PROPERTY:LOGIN_FACEBOOK, LOGIN_SOCIAL_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(clicked),EVENT_TIMED:[NSDate date]} timed:YES];
    
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [AppDelegate showActivityIndicatorWithText:@"Loading..."];

        NSArray *permissions =
        [NSArray arrayWithObjects:@"email", nil];
        
        [FBSession  openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
        return;
    } else {
        [self socialLoginFB:FBSession.activeSession];
    }
}

- (void)sessionStateChanged:(FBSession *)session_
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    [AppDelegate removeActivityIndicator];
    
    switch (state) {
            
        case FBSessionStateOpen: {
            [Analytics endEvent:EVENT_LOGIN_SOCIAL  parameters:@{LOGIN_TYPE_PROPERTY:LOGIN_FACEBOOK, LOGIN_SOCIAL_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(Success),EVENT_TIMED:[NSDate date]}];
            //flurryParams = @{@"Status":@"Success"};
#if DEBUG
            NSLog(@"fb accesstoken %@, expiration date %@",session_.accessTokenData.accessToken,session_.accessTokenData.expirationDate);
            NSLog(@"Completed fb login show home screen");
#endif
            [[[AppData shared]data][@"user"] setObject:@"Facebook" forKey:@"loggedInThrough"];
            [[AppData shared]save];
            [self socialLoginFB:session_];
            if (FBSession.activeSession.isOpen) {
                [[FBRequest requestForMe] startWithCompletionHandler:
                 ^(FBRequestConnection *connection,
                   NSDictionary<FBGraphUser> *user,
                   NSError *error) {
                     if (!error) {
                         [[[AppData shared]data][@"user"] setObject:user.name?:[NSString stringWithFormat:@"%@ %@",user.first_name,user.last_name] forKey:@"name"];
                         [[[AppData shared]data][@"user"] setObject:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",user.id] forKey:@"image"];
                         [[AppData shared]save];
                     }
                 }];      
            }
        }
            break;
        case FBSessionStateClosed:
            //flurryParams = @{@"Status":@"Cancel",@"Error":error?error:@"FBSessionStateClosed"};
        case FBSessionStateClosedLoginFailed:
            //flurryParams = @{@"Status":@"Failure",@"Error":error?error:@"FBSessionStateClosedLoginFailed"};
            // Once the user has logged in, we want them to
            // be looking at the home view.
            [FBSession.activeSession closeAndClearTokenInformation];
            
            break;
        default:
            break;
    }
    
    if (state != FBSessionStateOpen) {
        [Analytics endEvent:EVENT_LOGIN_SOCIAL  parameters:@{LOGIN_TYPE_PROPERTY:LOGIN_GOOGLE, LOGIN_SOCIAL_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(Failure),EVENT_TIMED:[NSDate date]}];
//        if (error) {
//            [Flurry logError:@"Login- Facebook" message:@"Failure" error:error];
//        }
//        [Flurry endTimedEvent:@"Login- Facebook" withParameters:flurryParams];
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark Google+ Methods
-(void)loginWithGooglePlus:(id)sender {
    
    //[Flurry logEvent:@"Login- Google" timed:YES];
    
    [Analytics logEvent:EVENT_LOGIN_SOCIAL  parameters:@{LOGIN_TYPE_PROPERTY:LOGIN_GOOGLE, LOGIN_SOCIAL_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(clicked),EVENT_TIMED:[NSDate date]} timed:YES];
    
    [AppDelegate showActivityIndicatorWithText:@"Loading..."];
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kGooglePlusClientId;
    signIn.scopes = [NSArray arrayWithObjects:
                     kGTLAuthScopePlusLogin,kGTLAuthScopePlusMe, // defined in GTLPlusConstants.h
                     nil];
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.shouldFetchGoogleUserID = YES;
    signIn.delegate = self;
    
    [signIn authenticate];
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    NSLog(@"Received error %@ and auth object %@",error, auth);
    [AppDelegate removeActivityIndicator];
    if (!error) {
        
        [Analytics endEvent:EVENT_LOGIN_SOCIAL  parameters:@{LOGIN_TYPE_PROPERTY:LOGIN_GOOGLE, LOGIN_SOCIAL_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(Success),EVENT_TIMED:[NSDate date]}];
        
        [[[AppData shared]data][@"user"] setObject:@"Google" forKey:@"loggedInThrough"];
        [[AppData shared]save];
        
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
        [plusService setAuthorizer:auth];

        plusService.retryEnabled = YES;
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPerson *person,
                                    NSError *error) {
                    if (error) {
                        GTMLoggerError(@"Error: %@", error);
                    } else {
                        [[[AppData shared]data][@"user"] setObject:person.displayName forKey:@"name"];
                        [[[AppData shared]data][@"user"] setObject:person.image.url forKey:@"image"];
                        [[AppData shared]save];
                    }
                }];
        BOOL clientKeyValid = [appDelegate isClientKeyValid];
        
        if (clientKeyValid) {
            [self makeLoginRequestWithGooglePlus:[AppData shared].data[@"clientKey"] auth:auth];
        } else {
            [appDelegate requestForClientKeyGenerationWithCompletionHandler:^(BOOL success, NSDictionary *response, NSError *error) {
                if (success) {
                    [self makeLoginRequestWithGooglePlus:[AppData shared].data[@"clientKey"] auth:auth];
                }
            }];
        }
    } else {
        [Analytics endEvent:EVENT_LOGIN_SOCIAL  parameters:@{LOGIN_TYPE_PROPERTY:LOGIN_GOOGLE, LOGIN_SOCIAL_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(Failure),EVENT_TIMED:[NSDate date]}];
//        [Flurry logError:@"Login- Google" message:@"Fail" error:error];
//        [Flurry endTimedEvent:@"Login- Google" withParameters:@{@"Status":@"Failure"}];
    }
}

-(void)socialLoginFB:(FBSession *)session_ {
    
    BOOL clientKeyValid = [appDelegate isClientKeyValid];
    
    if (clientKeyValid) {
        [self makeLoginRequestWithFB:[AppData shared].data[@"clientKey"] session:session_];
    } else {
        [appDelegate requestForClientKeyGenerationWithCompletionHandler:^(BOOL success, NSDictionary *response, NSError *error) {
            if (success) {
                [self makeLoginRequestWithFB:[AppData shared].data[@"clientKey"] session:session_];
            }
        }];
    }
}

-(void)makeLoginRequestWithFB:(NSString *)clientKey session:(FBSession *)session_ {
    [AppDelegate showActivityIndicatorWithText:@"Loading..."];
    
    [Analytics logEvent:EVENT_LOGIN parameters:@{LOGIN_TYPE_PROPERTY:LOGIN_TYPES_STRING(FaceBook),LOGIN_DATE_PROPERTY:[NSDate date],LOGIN_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(Clicked), EVENT_TIMED:[NSDate date]}  timed:YES];
    
    LoginUser *loginUser = [[LoginUser alloc]init];
    [loginUser authenticateUserWithFacebookId:session_.accessTokenData.accessToken authToken:session_.accessTokenData.accessToken tokenExpiry:[appDelegate formatDateToString:session_.accessTokenData.expirationDate]clientKey:clientKey];
}

-(void)makeLoginRequestWithGooglePlus:(NSString *)clientKey auth:(GTMOAuth2Authentication *)auth {
    [AppDelegate showActivityIndicatorWithText:@"Loading..."];
    
    [Analytics logEvent:EVENT_LOGIN parameters:@{LOGIN_TYPE_PROPERTY:LOGIN_TYPES_STRING(Google),LOGIN_DATE_PROPERTY:[NSDate date],LOGIN_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(Clicked), EVENT_TIMED:[NSDate date]}  timed:YES];
    
    LoginUser *loginUser = [[LoginUser alloc]init];
    [loginUser authenticateUserWithGooglePlusId:auth.parameters[@"access_token"] authToken:auth.parameters[@"access_token"] tokenExpiry:[appDelegate formatDateToString:auth.expirationDate] clientKey:clientKey];
}

-(void)loginWithTwitter:(id)sender {
    _twitterEngine.delegate = (id)self;
    if(!_twitterEngine) {
        [self initializeTwitterEngineWithDelegate:self];
    }
    [_twitterEngine loadAccessToken];
    if(![_twitterEngine isAuthorized]) {
        [self authenticateTwitterAccountWithDelegate:self andPresentFromVC:self];
    } else { //get profile from twitter
        [[[AppData shared]data][@"user"] setObject:@"Twitter" forKey:@"loggedInThrough"];
        [[AppData shared]save];
        [self  socialLoginTwitter:_twitterEngine];
        [self getTwitterUserProfileByUserId:_twitterEngine.loggedInID];
    }
}


#pragma mark Twitter & it's delegate methods.
- (void)initializeTwitterEngineWithDelegate:(id)delegate {
    
    @try {
        // Twitter Initialization / Login Code Goes Here
        if(!_twitterEngine) {
            _twitterEngine = [FHSTwitterEngine sharedEngine];
            NSLog(@"Twitter engine:%@",_twitterEngine);
            [_twitterEngine permanentlySetConsumerKey:kOAuthTwitterConsumerKey andSecret:kOAuthTwitterConsumerSecret];
            _twitterEngine.delegate = delegate;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)authenticateTwitterAccountWithDelegate:(id)viewController andPresentFromVC:(MainAuthenticationViewController *)VC {
    
    @try {
        if(_twitterEngine) {
            [_twitterEngine loadAccessToken];
            _twitterEngine.delegate = viewController;
            
            if ([viewController isKindOfClass:[MainAuthenticationViewController class]]) {
                [[FHSTwitterEngine sharedEngine]showOAuthLoginControllerFromViewController:VC withCompletion:^(BOOL success) {
                    if (!success) {
                        [UIAlertView showAlertWithError:[NSError errorWithDomain:kAccountCreationErrors andCode:kAccountCreationErrorGeneric andDescriptionKey:@"Couldn't authenticate, please try after some time" andUnderlying:0]];
                    } else {
                        [[[AppData shared]data][@"user"] setObject:@"Twitter" forKey:@"loggedInThrough"];
                        [[AppData shared]save];
                        [self socialLoginTwitter:_twitterEngine];
                        [self getTwitterUserProfileByUserId:_twitterEngine.loggedInID];
                    }
                }];
            }
            
            [AppDelegate removeActivityIndicator];
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}

-(void)socialLoginTwitter:(FHSTwitterEngine *)twitterEngine
{
    BOOL clientKeyValid = [appDelegate isClientKeyValid];
    
    if (clientKeyValid) {
        [self makeLoginRequestWithTwitter:[AppData shared].data[@"clientKey"] engine:twitterEngine];
    } else {
        [appDelegate requestForClientKeyGenerationWithCompletionHandler:^(BOOL success, NSDictionary *response, NSError *error) {
            if (success) {
                [self makeLoginRequestWithTwitter:[AppData shared].data[@"clientKey"] engine:twitterEngine];
            }
        }];
    }
}

-(void)makeLoginRequestWithTwitter:(NSString *)clientKey engine:(FHSTwitterEngine *)twitterEngine {
    
    [AppDelegate showActivityIndicatorWithText:@"Loading..."];
    
    //Should send Key, Secret & Pin.
    LoginUser *loginUser = [[LoginUser alloc]init];
    [loginUser authenticateUserWithTwitterId:twitterEngine.loggedInID authToken:[NSString stringWithFormat:@"%@,%@",twitterEngine.accessToken.key,twitterEngine.accessToken.secret] tokenExpiry:[appDelegate formatDateToString:[NSDate date]] clientKey:clientKey];
   // [self performSelector:@selector(removeLoginScreen) withObject:nil afterDelay:1.0];
    //[self removeLoginScreen]; //testing
}

- (void) getTwitterUserProfileByUserId:(NSString *)userId {
    
    NSDictionary *dict = [_twitterEngine getUserProfileForUserId:userId];
#if DEBUG
    NSLog(@"Profile from Twitter %@",dict);
#endif
    if (dict) {
        [[[AppData shared]data][@"user"] setObject:[dict objectForKey:@"name"]?:@"" forKey:@"name"];
        [[[AppData shared]data][@"user"] setObject:[dict objectForKey:@"profile_image_url_https"]?:@"" forKey:@"image"];
        [[AppData shared]save];
    }
}

-(void)logInDidSuccess:(NSNotification *)notification {
    
    NSDictionary *dict = notification.object;
    NSString *loginPath = dict[@"loginPath"];
    
    LOGIN_TYPES logintype = [self getEventType:loginPath];
    
    NSDictionary *response = dict[@"response"];
    [Analytics endEvent:EVENT_LOGIN parameters:@{LOGIN_TYPE_PROPERTY:LOGIN_TYPES_STRING(logintype),LOGIN_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(Success),LOGIN_STATUS_MESSAGE_PROPERTY:response[@"message"], EVENT_TIMED:[NSDate date]}];
//    NSDictionary *flurryParams = @{@"Status":@"Success"};
//    [Flurry endTimedEvent:eventName withParameters:flurryParams];
    [AppDelegate removeActivityIndicator];
    
    GetProfile *getProfile = [[GetProfile alloc]init];
    [getProfile getProfile:[AppData shared].data[@"clientKey"]];

    [self removeLoginScreen];
}

-(void)logInDidFail:(NSNotification *)notificaiton {

    [AppDelegate removeActivityIndicator];

    NSDictionary *dict = notificaiton.object;
    NSError *error = dict[@"error"];
    NSString *loginPath = dict[@"loginPath"];
    
    [UIAlertView showAlertWithError:error];
    
    LOGIN_TYPES logintype = [self getEventType:loginPath];
    
    [Analytics endEvent:EVENT_LOGIN parameters:@{LOGIN_TYPE_PROPERTY:LOGIN_TYPES_STRING(logintype),LOGIN_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(Failure),LOGIN_STATUS_MESSAGE_PROPERTY:[error userInfo][NSLocalizedDescriptionKey]?:@"Login Failed", EVENT_TIMED:[NSDate date]}];
//    if (error) {
//        [Flurry logError:eventName message:@"Failure" error:error];
//    }
//    NSDictionary *flurryParams = @{@"Status": @"Failure"};
//    [Flurry endTimedEvent:eventName withParameters:flurryParams];
}

-(LOGIN_TYPES)getEventType:(NSString *)loginPath {
    LOGIN_TYPES logintype;
    if ([loginPath rangeOfString:@"FB"].location != NSNotFound) {
        //eventName = @"Facebook";
        logintype = FaceBook;
    } else if([loginPath rangeOfString:@"Google"].location != NSNotFound) {
        //eventName = @"Google";
        logintype = Google;
    } else if([loginPath rangeOfString:@"Twitter"].location != NSNotFound) {
        //eventName = @"Twitter";
        logintype = Twitter;
    } else {
        logintype = myplex;
        //eventName = @"SignIn";
    }
    return logintype;
}

-(void)loginWithMyPlex:(id)sender {
    
    LoginViewController *loginVC;
    
    isIPhone
        loginVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewControllerID"];
    else
        loginVC = [[UIStoryboard storyboardWithName:@"Main-iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewControllerID"];
    
    loginVC.posterView = posterView;
    [self.navigationController pushViewController:loginVC animated:YES];
    
}

-(void)createAccount:(id)sender
{
    SignUpViewController *singupVC;
    
    isIPhone
        singupVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpViewControllerID"];
    else
        singupVC = [[UIStoryboard storyboardWithName:@"Main-iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpViewControllerID"];
    
    singupVC.posterView = posterView;
    [self.navigationController pushViewController:singupVC animated:YES];
}

-(void)removeLoginScreen
{
    [posterView invalidateTimer];
    
    LoginNavigationController *lnc = (LoginNavigationController *)self.navigationController;
    _twitterEngine.delegate = nil;
    [lnc dismiss];
}

-(void)skipAuthentication:(id)sender {
    
    [Analytics logEvent:EVENT_LOGIN parameters:@{LOGIN_TYPE_PROPERTY:LOGIN_TYPES_STRING(Guest),LOGIN_DATE_PROPERTY:[NSDate date],LOGIN_STATUS_PROPERTY:LOGIN_STATUS_TYPES_STRING(Clicked), EVENT_TIMED:[NSDate date]}  timed:YES];
    
    //[[[AppData shared]data]setObject:[NSNumber numberWithBool:YES] forKey:@"stayLoggedIn"];
    [[[AppData shared]data][@"user"] setObject:@"guest" forKey:@"loggedInThrough"];
    [[[AppData shared]data][@"user"] setObject:@"Guest" forKey:@"name"];

    [[AppData shared]save];
    
    [self removeLoginScreen];
    
    BOOL clientKeyValid = [appDelegate isClientKeyValid];
    
    if (clientKeyValid) {
        [self requestForAutoSignIn:[AppData shared].data[@"clientKey"]];
    } else {
        [appDelegate requestForClientKeyGenerationWithCompletionHandler:^(BOOL success, NSDictionary *response, NSError *error) {
            if (success) {
                [self requestForAutoSignIn:[AppData shared].data[@"clientKey"]];
            }
        }];
    }
}

-(void)requestForAutoSignIn:(NSString *)clientKey {
    CreateUser *createUser = [[CreateUser alloc]initWithManagedObjectContext:nil];
    
    //[AppDelegate showActivityIndicatorWithText:@"Loading..."];
    
    //[Analytics logEvent:EVENT_SIGNUP parameters:@{SIGNUP_TYPE_PROPERTY:SIGNUP_TYPES_STRING(Myplex),SIGNUP_STATUS_PROPERTY:SIGNUP_STATUS_TYPES_STRING(clicked),SIGNUP_EMAIL_PROPERTY:userIdField.text,SIGNUP_DATE_PROPERTY:[NSDate date]}  timed:YES];
    //[Flurry logEvent:@"Login- SignUp" timed:YES];
    
    [createUser createGuestUserWithClientKey:clientKey];
}

-(void)singUpDidSuccess:(NSNotification *)notification {
    
    //[AppDelegate removeActivityIndicator];
    
    //NSDictionary *response = notification.object;
    
    //[Analytics endEvent:EVENT_SIGNUP parameters:@{SIGNUP_TYPE_PROPERTY:SIGNUP_TYPES_STRING(Myplex),SIGNUP_STATUS_PROPERTY:SIGNUP_STATUS_TYPES_STRING(SignUpSuccess),SIGNUP_STATUS_MESSAGE_PROPERTY:response[@"message"]?:@"Successfully registered to myplex", SIGNUP_DATE_PROPERTY:[NSDate date],EVENT_TIMED:[NSDate date]}];
    
//    GetProfile *getProfile = [[GetProfile alloc]init];
//    [getProfile getProfile:[AppData shared].data[@"clientKey"]];
//    
//    [posterView invalidateTimer];
//    
//    LoginNavigationController *lnc = (LoginNavigationController *)self.navigationController;
//    [lnc dismiss];
}

-(void)singUpDidFail:(NSNotification *)notificaiton {
    
//    [AppDelegate removeActivityIndicator];
    
    //NSError *error = notificaiton.object;
    
    //[Flurry endTimedEvent:@"Login- SignUp" withParameters:@{@"Status":@"Failure"}];
    
//    [Analytics endEvent:EVENT_SIGNUP parameters:@{SIGNUP_TYPE_PROPERTY:SIGNUP_TYPES_STRING(Myplex),SIGNUP_STATUS_PROPERTY:SIGNUP_STATUS_TYPES_STRING(SignUpFailure),SIGNUP_STATUS_MESSAGE_PROPERTY:[error userInfo][NSLocalizedDescriptionKey]?:@"Successfully registered to myplex", SIGNUP_DATE_PROPERTY:[NSDate date],EVENT_TIMED:[NSDate date]}];
    
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

//For iOS 6
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    // Vishal Gupta:- Date: Jan 23, 2014
    /*
     * To Load the iPad storyboard and it's view Controller, Added a Check for the device on which this app is running.
     */
    isIPhone
        return UIInterfaceOrientationMaskPortrait;
    return UIInterfaceOrientationMaskLandscape;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    // Vishal Gupta:- Date: Jan 23, 2014
    /*
     * To Load the iPad storyboard and it's view Controller, Added a Check for the device on which this app is running.
     */
    isIPhone
        return UIInterfaceOrientationPortrait;
    return UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Vishal Gupta:- Date: Jan 23, 2014
    /*
     * To Load the iPad storyboard and it's view Controller, Added a Check for the device on which this app is running.
     */
    isIPhone
    {
    // Return YES for supported orientations
        if (interfaceOrientation == UIInterfaceOrientationPortrait) {
            return YES;
        } else {
            return NO;
        }
    }
    else
    {
        if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
