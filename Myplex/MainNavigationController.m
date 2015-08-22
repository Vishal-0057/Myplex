//
//  ViewController.m
//  Myplex
//
//  Created by Igor Ostriz on 8/27/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "UIAlertView+Blocks.h"
#import "AppData.h"

#import "CardsViewController.h"
#import "CardDetailsViewController.h"
#import "DownloadsViewController.h"
#import "LoginNavigationController.h"
#import "MainNavigationController.h"
#import "RightViewController.h"

#import "SettingsViewController.h"
#import "RESideMenu.h"

#import "GooglePlus/GooglePlus.h"
#import "FHSTwitterEngine.h"
#import "AppDelegate.h"
#import "Notifications.h"
#import "LoginUser.h"
#import "UIAlertView+ReportError.h"


@implementation MainNavigationController {
    AppDelegate *_appDelegate;
    RESideMenu* _sideMenu;
    FBFriendPickerViewController *_friendPickerViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signOutDidSuccess:) name:kNotificationSignedOut  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signOutDidFail:) name:kNotificationSignOutError object:nil];
    
    isIPhone
    {
        _appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        
        RESideMenuItem *profileItem = [[RESideMenuItem alloc] initWithTitle:[[AppData shared]data][@"user"][@"name"] image:nil highlightedImage:nil imageAction:^(RESideMenu *menu, RESideMenuItem *item) {
            
        }action:^(RESideMenu *menu, RESideMenuItem *item) {
            
            [Analytics logEvent:EVENT_BROWSE parameters:@{BROWSE_TYPE_PROPERTY:BROWSE_NAVIGATION_TYPES_STRING(Profile) } timed:NO];
            //[menu hide];
            
        }];
        
        CGRect headerImageFrame = CGRectMake(0, 0, 150, 15);
        RESideMenuItem *logoItem = [[RESideMenuItem alloc] initWithTitle:nil image:[UIImage imageNamed:@""] highlightedImage:[UIImage imageNamed:@""] imageFrame:headerImageFrame type:RESideMenuItemTypeHeader imageAction:^(RESideMenu *menu, RESideMenuItem *item) {
            NSLog(@"Perform logo Image Action");
        }  action:^(RESideMenu *menu, RESideMenuItem *item) {
        }];
        
        RESideMenuItem *favoriteItem = [[RESideMenuItem alloc] initWithTitle:@"Favorites" image:[UIImage imageNamed:@"iconfav"] highlightedImage:[UIImage imageNamed:@"iconfav"] imageAction:^(RESideMenu *menu, RESideMenuItem *item) {
            
        }action:^(RESideMenu *menu, RESideMenuItem *item) {
            [Analytics logEvent:EVENT_BROWSE parameters:@{BROWSE_TYPE_PROPERTY:BROWSE_NAVIGATION_TYPES_STRING(Favourite) } timed:NO];
            
            [menu hide];
            
            CardsViewController *cvc;
            for (UIViewController *vc in self.viewControllers) {
                if ([vc isKindOfClass:[CardsViewController class]]) {
                    cvc = (CardsViewController *)vc;
                    //                [cvc refresh:CardsFavorites];
                    break;
                }
            }
            if (!cvc) {
                    cvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CardsViewControllerID"];
            }
        [cvc showDeletedCards];
            [cvc refresh:CardsFavorites];
            [self setViewControllers:@[cvc]];
            [menu displayContentController:self];
        }];
        
//        RESideMenuItem *downloadsItem = [[RESideMenuItem alloc] initWithTitle:@"downloads" image:[UIImage imageNamed:@"icondownload"] highlightedImage:[UIImage imageNamed:@"icondownload"] imageAction:^(RESideMenu *menu, RESideMenuItem *item) {
//            
//        }action:^(RESideMenu *menu, RESideMenuItem *item) {
//            //[menu hide];
//            [Analytics logEvent:EVENT_BROWSE parameters:@{BROWSE_TYPE_PROPERTY:BROWSE_NAVIGATION_TYPES_STRING(Downloads) } timed:NO];
//            
//            DownloadsViewController *downloadsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DownloadsViewControllerID"];
//            downloadsVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleBordered target:downloadsVC action:@selector(showMenu:)];
//            [self setViewControllers:@[downloadsVC]];
//            [menu displayContentController:self];
//        }];
        
        RESideMenuItem *purchasedItem = [[RESideMenuItem alloc] initWithTitle:@"Purchased" image:[UIImage imageNamed:@"iconpurchase"] highlightedImage:[UIImage imageNamed:@"iconpurchase"] imageAction:^(RESideMenu *menu, RESideMenuItem *item) {
            
        }action:^(RESideMenu *menu, RESideMenuItem *item) {
            [Analytics logEvent:EVENT_BROWSE parameters:@{BROWSE_TYPE_PROPERTY:BROWSE_NAVIGATION_TYPES_STRING(Purchases) } timed:NO];
            
            CardsViewController *cvc;
            for (UIViewController *vc in self.viewControllers) {
                if ([vc isKindOfClass:[CardsViewController class]]) {
                    cvc = (CardsViewController *)vc;
                    //                [cvc refresh:CardsPurchased];
                    break;
                }
            }
            if (!cvc) {
                cvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CardsViewControllerID"];
            }
        [cvc showDeletedCards];
            [cvc refresh:CardsPurchased];
            [self setViewControllers:@[cvc]];
            [menu displayContentController:self];
            
        }];
        
        RESideMenuItem *settingsItem = [[RESideMenuItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"iconsettings"] highlightedImage:[UIImage imageNamed:@"iconsettings"] imageAction:^(RESideMenu *menu, RESideMenuItem *item) {
            
        }action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
            [Analytics logEvent:EVENT_BROWSE parameters:@{BROWSE_TYPE_PROPERTY:BROWSE_NAVIGATION_TYPES_STRING(Settings) } timed:NO];
            //[Flurry logEvent:@"Side Bar- Select" withParameters:@{@"type": @"Settings"}];
            
            [self popToRootViewControllerAnimated:NO];
            
            SettingsViewController *settingsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsViewControllerID"];
            settingsVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleBordered target:settingsVC action:@selector(showMenu:)];
            //        [self setViewControllers:@[settingsVC]];
            //        [menu displayContentController:self];
            [self pushViewController:settingsVC animated:NO];
        }];
        
        RESideMenuItem *logOutItem = [[RESideMenuItem alloc] initWithTitle:@"Logout" image:[UIImage imageNamed:@"iconlogout"] highlightedImage:[UIImage imageNamed:@"iconlogout"] imageAction:^(RESideMenu *menu, RESideMenuItem *item) {
            
        } action:^(RESideMenu *menu, RESideMenuItem *item) {
            //[menu hide];
            [Analytics logEvent:EVENT_BROWSE parameters:@{BROWSE_TYPE_PROPERTY:BROWSE_NAVIGATION_TYPES_STRING(Logout) } timed:NO];
            //[Flurry logEvent:@"Side Bar- Select" withParameters:@{@"type": @"Logout"}];
            [self checkForLogin];
        }];
        
        headerImageFrame = CGRectMake(0, 0, 150, 15);
        RESideMenuItem *logoItem1 = [[RESideMenuItem alloc] initWithTitle:nil image:[UIImage imageNamed:@""] highlightedImage:[UIImage imageNamed:@""] imageFrame:headerImageFrame type:RESideMenuItemTypeHeader imageAction:^(RESideMenu *menu, RESideMenuItem *item) {
            NSLog(@"Perform logo Image Action");
        }  action:^(RESideMenu *menu, RESideMenuItem *item) {
        }];
        
        RESideMenuItem *liveItem = [[RESideMenuItem alloc] initWithTitle:@"Fifa 2014 Live" image:[UIImage imageNamed:@"iconlive"] highlightedImage:[UIImage imageNamed:@"iconlive"] imageAction:^(RESideMenu *menu, RESideMenuItem *item) {
            
        } action: ^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
            
            [Analytics logEvent:EVENT_BROWSE parameters:@{BROWSE_TYPE_PROPERTY:BROWSE_NAVIGATION_TYPES_STRING(Home) } timed:NO];
            
            CardsViewController *cvc;
            for (UIViewController *vc in self.viewControllers) {
                if ([vc isKindOfClass:[CardsViewController class]]) {
                    cvc = (CardsViewController *)vc;
                    //                [cvc refresh:CardsRecommendations];
                    break;
                }
            }
            if (!cvc) {
                cvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CardsViewControllerID"];
            }
        [cvc showDeletedCards];
            [cvc refresh:CardsRecommendations];
            [self setViewControllers:@[cvc]];
            [menu displayContentController:self];
        }];
        
        
        RESideMenuItem *matchItem = [[RESideMenuItem alloc] initWithTitle:@"Fifa 2014 Matches" image:[UIImage imageNamed:@"iconmatches"] highlightedImage:[UIImage imageNamed:@"iconmatches"] imageAction:^(RESideMenu *menu, RESideMenuItem *item) {
            
        }action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
            //[Flurry logEvent:@"Side Bar- Select" withParameters:@{@"type": @"Movies"}];
            [Analytics logEvent:EVENT_BROWSE parameters:@{BROWSE_TYPE_PROPERTY:BROWSE_NAVIGATION_TYPES_STRING(movie) } timed:NO];
            
            CardsViewController *cvc;
            for (UIViewController *vc in self.viewControllers) {
                if ([vc isKindOfClass:[CardsViewController class]]) {
                    cvc = (CardsViewController *)vc;
                    break;
                }
            }
            if (!cvc) {
                cvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CardsViewControllerID"];
            }
            [cvc showDeletedCards];
            [cvc refresh:CardsFIFA];
            [self setViewControllers:@[cvc]];
            [menu displayContentController:self];
            
        }];
        
//        RESideMenuItem *liveTVItem = [[RESideMenuItem alloc] initWithTitle:@"live tv" image:[UIImage imageNamed:@"iconlive"] highlightedImage:[UIImage imageNamed:@"iconlive"] imageAction:^(RESideMenu *menu, RESideMenuItem *item) {
//            
//        }action:^(RESideMenu *menu, RESideMenuItem *item) {
//            [menu hide];
//            //[Flurry logEvent:@"Side Bar- Select" withParameters:@{@"type": @"Live TV"}];
//            [Analytics logEvent:EVENT_BROWSE parameters:@{BROWSE_TYPE_PROPERTY:BROWSE_NAVIGATION_TYPES_STRING(LiveTv) } timed:NO];
//            CardsViewController *cvc;
//            for (UIViewController *vc in self.viewControllers) {
//                if ([vc isKindOfClass:[CardsViewController class]]) {
//                    cvc = (CardsViewController *)vc;
//                    //                [cvc refresh:CardsLiveTV];
//                    break;
//                }
//            }
//            if (!cvc) {
//               cvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CardsViewControllerID"];
//            }
//        [cvc showDeletedCards];
//            [self setViewControllers:@[cvc]];
//            [menu displayContentController:self];
//            [cvc refresh:CardsLiveTV];
//        }];
        
        
//        RESideMenuItem *fifaItem = [[RESideMenuItem alloc] initWithTitle:@"FIFA" image:[UIImage imageNamed:@"iconlive"] highlightedImage:[UIImage imageNamed:@"iconlive"] imageAction:^(RESideMenu *menu, RESideMenuItem *item) {
//            
//        }action:^(RESideMenu *menu, RESideMenuItem *item) {
//            [menu hide];
//            //[Flurry logEvent:@"Side Bar- Select" withParameters:@{@"type": @"Live TV"}];
//            //[Analytics logEvent:EVENT_BROWSE parameters:@{BROWSE_TYPE_PROPERTY:BROWSE_NAVIGATION_TYPES_STRING(LiveTv) } timed:NO];
//            CardsViewController *cvc;
//            for (UIViewController *vc in self.viewControllers) {
//                if ([vc isKindOfClass:[CardsViewController class]]) {
//                    cvc = (CardsViewController *)vc;
//                    //                [cvc refresh:CardsLiveTV];
//                    break;
//                }
//            }
//            if (!cvc) {
//                cvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CardsViewControllerID"];
//            }
//            [cvc showDeletedCards];
//            [self setViewControllers:@[cvc]];
//            [menu displayContentController:self];
//            [cvc refresh:CardsFIFA];
//        }];
        
        _sideMenu = [[RESideMenu alloc] initWithItems:@[profileItem,logoItem,liveItem,matchItem,/*tvShowsItem,*/logoItem1,favoriteItem,purchasedItem,settingsItem,logOutItem,]];
        _sideMenu.backgroundImage = [UIImage imageNamed:@"menubg"];
        _sideMenu.font = [UIFont fontWithName:@"MuseoSansRounded-700" size:16];
        
        // Call the home action rather than duplicating the initialisation
        liveItem.action(_sideMenu, liveItem);
        [[[UIApplication sharedApplication] delegate] window].rootViewController = _sideMenu;
        [self fullRefresh:NO];
    } else {
        [self performSelector:@selector(fullRefresh:) withObject:NO afterDelay:0.0];
    }
}

-(void) checkForLogin
{
    if (![[AppData shared].data[@"user"][@"loggedInThrough"] isEqualToString:@"guest"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAppTitle message:kLogoutMessage delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"logout", nil];
        [alertView show];
    } else {
        [self logout];
    }
}

-(void)refresh:(NSNumber *)number {
    [self fullRefresh:number.boolValue];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    isIPhone
    {
    BOOL addInviteFriends = YES;
    for (RESideMenuItem *sideMenuItem in _sideMenu.items) {
        if ([sideMenuItem.title isEqualToString:@"Invite Friends"]) {
            NSMutableArray *sideMenuItems = [[NSMutableArray alloc]initWithArray:_sideMenu.items];
            [sideMenuItems removeObject:sideMenuItem];
            [_sideMenu reloadWithItems:sideMenuItems];
        } else if([sideMenuItem.title isEqualToString:@"logout"] || [sideMenuItem.title isEqualToString:@"login"]) {
            if ([[AppData shared].data[@"user"][@"loggedInThrough"] isEqualToString:@"guest"]) {
                sideMenuItem.title = @"login";
            } else {
                sideMenuItem.title = @"logout";
            }
        }
    }
    if ([[[AppData shared]data][@"user"][@"loggedInThrough"] isEqualToString:@"Facebook"] && addInviteFriends) {
        
        RESideMenuItem *friendsItem = [[RESideMenuItem alloc] initWithTitle:@"Invite Friends" image:[UIImage imageNamed:@"iconfriends"] highlightedImage:[UIImage imageNamed:@"iconfriends"] imageAction:^(RESideMenu *menu, RESideMenuItem *item) {
            
        } action:^(RESideMenu *menu, RESideMenuItem *item) {
//            [menu hide];
//            //if (FBSession.activeSession.isOpen) {
//                [FBRequestConnection startForMyFriendsWithCompletionHandler:
//                 ^(FBRequestConnection *connection, id<FBGraphUser> friends, NSError *error)
//                 {
//                     if(!error){
//                         NSLog(@"results = %@", friends);
//                         [_friendPickerViewController updateView];
//                     }
//                 }
//                 ];
//                if (!_friendPickerViewController) {
//                    _friendPickerViewController = [[FBFriendPickerViewController alloc]
//                                                   initWithNibName:nil bundle:nil];
//                    
//                    // Set the friend picker delegate
//                    _friendPickerViewController.delegate = self;
//                    _friendPickerViewController.cancelButton = nil;
//                    _friendPickerViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleBordered target:self action:@selector(facebookViewControllerCancelWasPressed:)];
//                    _friendPickerViewController.doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(facebookViewControllerDoneWasPressed:)];
//                    _friendPickerViewController.title = @"Invite Friends";
//                }
//                
//                [_friendPickerViewController loadData];
//                [self popToRootViewControllerAnimated:NO];
//                [self pushViewController:_friendPickerViewController
//                                animated:false];
//            //[self presentViewController:_friendPickerViewController animated:YES completion:nil];
//  
//            //}
//            [Analytics logEvent:EVENT_BROWSE parameters:@{BROWSE_TYPE_PROPERTY:BROWSE_NAVIGATION_TYPES_STRING(InviteFriends) } timed:NO];
            [self showFBInviteDialog];
        }];
        
        NSMutableArray *sideMenuItems = [[NSMutableArray alloc]initWithArray:_sideMenu.items];
        [sideMenuItems insertObject:friendsItem atIndex:7];
        [_sideMenu reloadWithItems:sideMenuItems];
    }
    }
}

-(void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:YES];
}


-(void)showFBInviteDialog {
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
//                                     // 3. Suggest friends the user may want to request, could be game context specific?
//                                     [friendIds componentsJoinedByString:@","], @"suggestions",    nil];
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:[NSString stringWithFormat:@"Watching movies with %@",kAppTitle]
                                                    title:kAppTitle
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          [UIAlertView showAlertWithError:error];
                                                          
                                                          NSLog(@"Error sending request.");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              NSLog(@"User canceled request.");
                                                          } else {
                                                              NSLog(@"Request Sent.");
                                                          }
                                                      }}
                                              friendCache:nil];
}

//-(void)reloadMenuItems {
//    
//    RESideMenuItem *friendsItem = [[RESideMenuItem alloc] initWithTitle:@"Friends" image:[UIImage imageNamed:@"iconfriends"] highlightedImage:[UIImage imageNamed:@"iconfriends"] imageAction:^(RESideMenu *menu, RESideMenuItem *item) {
//        
//    }action:^(RESideMenu *menu, RESideMenuItem *item) {
//        [Flurry logEvent:@"Side Bar- Select" withParameters:@{@"type": @"Friends"}];
//    }];
//    
//    NSMutableArray *sideMenuItems = [[NSMutableArray alloc]initWithArray:_sideMenu.items];
//    [sideMenuItems insertObject:friendsItem atIndex:2];
//    [_sideMenu reloadWithItems:sideMenuItems];
//}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    
    [_friendPickerViewController.sideMenu show];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableArray *friendIds = [NSMutableArray array];
    for (NSDictionary<FBGraphUser>* friend in  _friendPickerViewController.selection) {
        NSLog(@"I have selected a friend named %@ with id %@", friend.name, friend.id);
        [friendIds addObject:friend.id];
    }
}

- (void)fullRefresh:(BOOL)animated
{
    BOOL stayLoggedIn = [[AppData shared].data[@"stayLoggedIn"] boolValue];
    if (!stayLoggedIn) {
        [self showUserInitiation:animated];
        return;
    } else {
        //[Flurry logEvent:@"Login- Screen" withParameters:@{@"Status": @"Not Shown",@"Network":ReachableViaWiFi?@"WIFI":@"Cellular Network"}];
    }
}

- (void)showUserInitiation:(BOOL)animated
{
    LoginNavigationController *loginNavigationControler;
    
    isIPhone
    {
        loginNavigationControler = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavigationControllerID"];
    }
    else
    {
        loginNavigationControler = [[UIStoryboard storyboardWithName:@"Main-iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavigationControllerID"];
    }
    
    [self presentViewController:loginNavigationControler animated:animated completion:^{
        //[Flurry logEvent:@"Login- Screen" withParameters:@{@"Status": @"Shown",@"Network":ReachableViaWiFi?@"WIFI":@"Cellular Network"}];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        [self logout];
    } else {
        [Analytics logEvent:EVENT_SIGNOUT  parameters:@{SIGNOUT_STATUS_PROPERTY:SIGNOUT_STATUS_TYPES_STRING(SignOutCancelled) } timed:YES];
    }
}

-(void)logout {
    
    if (![[AppData shared].data[@"user"][@"loggedInThrough"] isEqualToString:@"guest"]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        
        BOOL clientKeyValid = [appDelegate isClientKeyValid];
        
        if (clientKeyValid) {
            [self makeSignOutRequest:[AppData shared].data[@"clientKey"]];
        } else {
            [appDelegate requestForClientKeyGenerationWithCompletionHandler:^(BOOL success, NSDictionary *response, NSError *error) {
                if (success) {
                    [self makeSignOutRequest:[AppData shared].data[@"clientKey"]];
                }
            }];
        }
    } else {
        [self signOutDidSuccess:nil];
    }
}

-(void)makeSignOutRequest:(NSString *)clientKey {
    
    [AppDelegate showActivityIndicatorWithText:@"Loading..."];
    
    //[Flurry logEvent:@"Login- SignOut" timed:YES];
    [Analytics logEvent:EVENT_SIGNOUT  parameters:@{SIGNOUT_STATUS_PROPERTY:SIGNOUT_STATUS_TYPES_STRING(SignOutClicked) } timed:YES];
    
    LoginUser *loginUser = [[LoginUser alloc]init];
    [loginUser signOut:clientKey];

}

-(void)signOutDidSuccess:(NSNotification *)notification {
    
    //[Flurry endTimedEvent:@"Login- SignOut" withParameters:@{@"Status":@"Success"}];
    
    [Analytics endEvent:EVENT_SIGNOUT  parameters:@{SIGNOUT_STATUS_PROPERTY:SIGNOUT_STATUS_TYPES_STRING(SignOutSuccess) }];
    
    [AppDelegate removeActivityIndicator];
    
    [self popToRootViewControllerAnimated:YES];
    
    //[Flurry logEvent:[NSString stringWithFormat:@"LoggedOut of %@",[[AppData shared]data][@"user"][@"loggedInThrough"]]];
    
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession.activeSession close];
    [FBSession setActiveSession:nil];
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [cookies cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"facebook"];
        if(domainRange.length > 0)
        {
            [cookies deleteCookie:cookie];
        }
    }
    
    [[GPPSignIn sharedInstance] signOut];
    
    [[FHSTwitterEngine sharedEngine]clearAccessToken];
    
    [[[AppData shared]data][@"user"] setObject:@"" forKey:@"name"];
    [[[AppData shared]data][@"user"] setObject:@"" forKey:@"image"];
    [[[AppData shared]data][@"user"] setObject:@"" forKey:@"loggedInThrough"];
    [[[AppData shared]data]setObject:[NSNumber numberWithBool:NO] forKey:@"stayLoggedIn"];
    [[AppData shared]save];
    
    
    [[self sideMenu] hide];
    
    //    [self.revealViewController revealToggleAnimated:YES];
    //
    //    MainNavigationController *mnc = (MainNavigationController*)[self revealViewController].frontViewController;
    //    [mnc popToRootViewControllerAnimated:YES];
    //    [self.revealViewController revealToggle:nil];
    [self fullRefresh:YES];

}

-(void)signOutDidFail:(NSNotification *)notification {
    NSDictionary *dict = notification.object;
    NSError *error = dict[@"error"];
    
    [UIAlertView showAlertWithError:error];
    
    [Analytics endEvent:EVENT_SIGNOUT  parameters:@{SIGNOUT_STATUS_PROPERTY:SIGNOUT_STATUS_TYPES_STRING(SignOutFailure) }];

//    if (error) {
//        [Flurry logError:@"Login- SignOut" message:@"Failure" error:error];
//    }
//    [Flurry endTimedEvent:@"Login- SignOut" withParameters:@{@"Status": @"Failure"}];
    [AppDelegate removeActivityIndicator];
}

-(BOOL)shouldAutorotate
{
    BOOL shouldRotate = [[self.viewControllers lastObject] shouldAutorotate];
    
    return shouldRotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger supportedOrientation =  [[self.viewControllers lastObject] supportedInterfaceOrientations];
    return supportedOrientation;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end
