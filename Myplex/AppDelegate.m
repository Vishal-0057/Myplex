//
//  AppDelegate.m
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import "AppData.h"
#import "AppDelegate.h"
#import "NSDate+ServerDateFormat.h"
#import "NSManagedObjectContext+Utils.h"
#import "RegisterDevice.h"
#import "ServerStandardRequest.h"
#import "UIDevice+IdentifierAddition.h"
#import "SVProgressHUD.h"
#import "Reachability.h"

//Need to optimize
#import "RageIAPHelper.h"
#import "VideoPlayerViewController.h"
#import "GetContentDetails.h"
#import "NSManagedObject+Utils.h"
#import "UIAlertView+ReportError.h"
#import "Subscribe.h"
#import "Download.h"
//#import "Appirater.h"
#import "Notifications.h"
#import "OpenUDID.h"
#import "ToastMessageView.h"
#import "DownloadManager.h"
#import "UIAlertView+Blocks.h"
#import "Mixpanel.h"
#import "NSNotificationCenter+Utils.h"
#import "CacheManager.h"
#import "Messages.h"
#import "Player.h"
#import "LocationManager.h"

#import <Crashlytics/Crashlytics.h>

//MixPanle_tokens
//1c663d8de79a40b4c89b242d828fc475 Prod
//97c0697e7a9b3a1996252c925d56c811 Dev
//20541460115650ad4e07ab10de528e81 Beta

#define MIXPANEL_TOKEN @"97c0697e7a9b3a1996252c925d56c811"
#define CRASHLYTICS_TOKEN @"784e2ac3acf47e88cb22fdb3f84099dce8d74d79"

Reachability *_reachability;

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize networkReachable;
@synthesize synchronizeOnWIFI;
@synthesize systemWifiEnabled;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    ////////////test////////
    //    NSURL *tempFilePath = [NSURL fileURLWithPath:@"/var/mobile/Applications/F860AA0A-4E76-4D7E-90A7-3D14F78B1F1E/Library/Caches/com.apple.nsnetworkd/CFNetworkDownload_vl6hlW.tmp"];
    //    NSError *error = nil;
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    //    NSLog(@"Writing data to documents");
    //
    //    NSString *desinationPath = [self getDownloadDestinationPath:@"1" withName:@"test"];
    //    NSLog(@"Started coping data");
    //    BOOL success = [fileManager copyItemAtURL:tempFilePath toURL:[NSURL fileURLWithPath:desinationPath] error:&error];
    //
    //    if (success)
    //    {
    //        NSLog(@"finished coping data");
    //    }
    
    // set overall custom appearances
    //    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    // [self cardSelectedWithStatus:YES drmEnabled:NO contentId:@"200" packageId:nil delegate:self];
    
    //In-App puchase class instance.
    [RageIAPHelper sharedInstance];
    
    synchronizeOnWIFI = [[AppData shared].data[@"synchronizeOnWIFI"]boolValue];
    
    _reachability = [Reachability reachabilityWithHostname:@"api.myplex.com"];
    _reachability.reachableBlock = ^(Reachability *reachability) {
        NSLog(@"Network is reachable.");
        [AppDelegate writeLog:@"Network is reachable........\n"];
        networkReachable = YES;
        if ([_reachability isReachableViaWiFi]) {
            systemWifiEnabled = YES;
            //sleep(2);
            //testing remove it before release
            //[self startDownload:@"http://myplexv2betadrmstreaming.s3.amazonaws.com/1000BC/1000BC.sd2low.mp4"destinationPath:[self getDownloadDestinationPath:@"1002" withName:@"Test2"] fileFormat:@"mp4" remoteId:@"1002" name:@"Test2" image:nil resume:YES];
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationNetworkReachble object:nil];
            ////
            [self performSelectorOnMainThread:@selector(checkAndStartDownloading) withObject:nil waitUntilDone:NO];
        } else {
            systemWifiEnabled = NO;
        }
    };
    _reachability.unreachableBlock = ^(Reachability *reachability) {
        NSLog(@"Network is unreachable.");
        [AppDelegate writeLog:@"Network is unreachable........\n"];
        systemWifiEnabled = NO;
        networkReachable = NO;
        //        if (downloadOperationQueue) {
        //            //[downloadOperationQueue cancelAllOperations];
        //            //downloadOperationQueue = nil;
        //        }
    };
    // Start Monitoring
    [_reachability startNotifier];
    
    //[self checkAndStartDownloading];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // set caching mechanism
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                         diskCapacity:20 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    [Crashlytics startWithAPIKey:CRASHLYTICS_TOKEN];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    [mixpanel identify:mixpanel.distinctId];
    
    [Analytics setSuperProperties:nil];
    
    [[LocationManager shared]updateLocation];
    
    // Tell iOS you want  your app to receive push
    // notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    
    BOOL deviceRegistered = [self checkDeviceRegistration];
    if (!deviceRegistered) {
        
        //This will give us the entire screen's resolution in points
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        
        //This will give you the scale of the screen. For all iPhones and iPodTouches that do NOT have Retina Displays will return a 1.0f, while Retina Display devices will give a 2.0f.
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        //This gives us the resolution in pixels.
        CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
        
        RegisterDevice *registerDevice = [[RegisterDevice alloc]initWithManagedObjectContext:self.managedObjectContext];
        
        [registerDevice registerDeviceWithSerialNumber:[OpenUDID value] osName:[[UIDevice currentDevice]systemName] osVersion:[[UIDevice currentDevice]systemVersion] model:[[UIDevice currentDevice]model] resolution:[NSString stringWithFormat:@"%dx%d",(int)screenSize.width,(int)screenSize.height]];
    }
    
    BOOL validRegistration = [self isClientKeyValid];
    if (!validRegistration) {
        ;
    }
    
//    [Appirater setAppId:@"com.apalya.myplex2.0"];
//    [Appirater appLaunched:YES];
    
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:
(NSData *)deviceToken
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people addPushDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Show alert for push notifications recevied while the
    // app is running
    NSString *message = [[userInfo objectForKey:@"aps"]
                         objectForKey:@"alert"];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Viva"
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

-(void)cleanDownloadsTempDirectory {
    
    NSString *entityName = @"Download";
    NSArray *downloadsStarted = [self.managedObjectContext fetchObjectsForEntityName:entityName withPredicate:[NSPredicate predicateWithFormat:@"downloading==%d OR paused==%d OR temporaryDestinationFilePath!=nil OR temporaryDestinationFilePath!=null",TRUE,TRUE,0]];
    if (!downloadsStarted) {
		NSLog(@"Error fetching entity of type %@", entityName);
	} else if(downloadsStarted.count == 0) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *directory = [[self applicationLibraryDirectory] stringByAppendingPathComponent:@"Caches/com.apple.nsnetworkd/"];
        NSError *error = nil;
        for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", directory, file] error:&error];
            if (!success || error) {
#if DEBUG
                NSLog(@"didFailed to remove temporary downloded file WithError: %@", error);
#endif
            }
        }
    }
}

-(NSString *)applicationLibraryDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(void)checkAndStartDownloading {
    
    TCSTART
    //check for a downloaded started file.
    NSString *entityName = @"Download";
    NSArray *downloadsStarted = [self.managedObjectContext fetchObjectsForEntityName:entityName withPredicate:[NSPredicate predicateWithFormat:@"downloading==%d OR paused==%d",TRUE,TRUE]];
    if (!downloadsStarted) {
		NSLog(@"Error fetching entity of type %@", entityName);
	} else if(downloadsStarted.count > 0) {
        for (int i = 0; i < downloadsStarted.count; i++) {
            
            Download *download = [downloadsStarted objectAtIndex:i];
            if ([self isNull:download.sourcePath] || [self isNull:download.remoteId]) {
                [self.managedObjectContext deleteObject:download];
                NSError *error = nil;
                [self.managedObjectContext save:&error];
            } else {
               [self startDownload:download.sourcePath destinationPath:download.destinationPath fileFormat:@"" remoteId:download.remoteId name:download.videoName image:download.image resume:YES];
            }
        }
    } else if(downloadsStarted.count == 0){ // get all waiting downloads and start downloding them.
        NSArray *pendingDownloads = [self.managedObjectContext fetchObjectsForEntityName:@"Download" withPredicate:[NSPredicate predicateWithFormat:@"waiting=%d",TRUE]];
        if (pendingDownloads.count > 0) {
            NSLog(@"found %d waiting downloads",pendingDownloads.count);
            Download *download = [pendingDownloads objectAtIndex:0];
            [self startDownload:download.sourcePath destinationPath:download.destinationPath fileFormat:@"" remoteId:download.remoteId name:download.videoName image:download.image resume:YES];
        } else { //remove this else
            //            NSString *uniqueId = @"1240";
            //            //@"http://220.226.22.120:9090/aptv3-downloads/appdevclip.wvm";
            //            //http://commonsware.com/misc/test.mp4 //5.93MB
            //            //http://122.248.233.48/wvm/armag.wvm
            //
            //            [self startDownload: @"http://commonsware.com/misc/test.mp4" destinationPath:[self getDownloadDestinationPath:uniqueId] fileFormat:@"mp4" remoteId:uniqueId name:@"Armegaddon1" imagePath:@"imgPath" resume:YES];
            //            uniqueId = @"1241";
            //            [self startDownload: @"http://122.248.233.48/wvm/armag.wvm" destinationPath:[self getDownloadDestinationPath:uniqueId] fileFormat:@"wvm" remoteId:uniqueId name:@"Armegaddon5" imagePath:@"imgPath" resume:YES];
            //    uniqueId = @"1241";
            //    [self startDownload: @"http://commonsware.com/misc/test.mp4" destinationPath:[self getDownloadDestinationPath:uniqueId] fileFormat:@"mp4" remoteId:uniqueId name:@"Armegaddon7" imagePath:@"imgPath" resume:YES];
        }
    }
    TCEND
}

-(BOOL)isUserAuthenticated {
    
    if ([[AppData shared].data[@"user"][@"loggedInThrough"] isEqualToString:@"guest"]) {

        return NO;
    }
    return YES;
}

-(void)showAuthenticationMessage {
    
    [UIAlertView alertViewWithTitle:@"authentication" message:kAuthenticationMessage cancelBlock:nil dismissBlock:^(int buttonIndex) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSignedOut object:nil];
    }cancelButtonTitle:@"cancel" otherButtonsTitles:@"login", nil];
}

-(void)cardSelectedWithStatus:(BOOL)subscribed drmEnabled:(BOOL)drmEnabled contentId:(NSString *)contentId title:(NSString *)title image:(NSString *)image packageId:(NSString *)pacakgeId delegate:(id)delgate {
    
//    if (![self checkAuthentication]) {
//        return;
//    }
    
    NSManagedObjectContext *managedObjectContext_ = [NSManagedObjectContext childUIManagedObjectContext];
    
    Content *content = (Content *)[Content fetchByRemoteId:contentId context:managedObjectContext_];
    
    Download *download = (Download *)[Download fetchByRemoteId:contentId context:self.managedObjectContext];
    if (download && download.downloaded.boolValue) {
        NSString *videoName = [download.videoName stringByReplacingOccurrencesOfString:@" " withString:@""];
        [self initPlayerWithUrl:[NSString stringWithFormat:@"%@%@.wvm",videoName,download.remoteId] contentId:contentId title:download.videoName profile:download.profile drmEnabled:drmEnabled streaming:NO delegate:delgate elapsedTime:content.elapsedTime.integerValue];
    } else {
        if (subscribed) {
            
            GetContentDetails *contentDetails = [[GetContentDetails alloc]initWithManagedObjectContext:self.managedObjectContext];
            [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationShowActivityIndicator object:@YES];
            //[AppDelegate showActivityIndicatorWithText:@"Loading..."];
            [contentDetails getContentDetailsWith:contentId fields:@"videos" withCompletionHandler:^(BOOL success, NSDictionary *jsonResponse, NSError *error) {
                //[AppDelegate removeActivityIndicator];
                [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationShowActivityIndicator object:@NO];
#if DEBUG
                NSLog(@"subscibed %d, drmEnabled %d, contentId: %@, packageId %@",subscribed,drmEnabled,contentId,pacakgeId);
#endif
                if (error) {
                    [UIAlertView showAlertWithError:error];
                } else if (success) {
                    if ([jsonResponse[@"results"] isKindOfClass:[NSString class]]) {
                        
                    } else if([jsonResponse[@"results"] isKindOfClass:[NSArray class]] && [jsonResponse[@"results"] count] > 0) {
                        
                        //url = @"http://122.248.233.48/wvm/armag.wvm";
                        if (![[jsonResponse[@"results"] objectAtIndex:0][@"videos"][@"status"] isEqualToString:@"SUCCESS"]) {
                            [UIAlertView showAlertWithError:[NSError errorWithDomain:kAccountCreationErrors andCode:kAccountCreationErrorGeneric andDescriptionKey:[jsonResponse[@"results"] objectAtIndex:0][@"videos"][@"message"] andUnderlying:0]];
                            if ([[jsonResponse[@"results"] objectAtIndex:0][@"videos"][@"status"] isEqualToString:@"ERR_USER_NOT_SUBSCRIBED"]) {
                                
                                content.purchased = @NO;
                                NSError *error = nil;
                                [self.managedObjectContext save:&error];
                                if (!error) {
                                    NSLog(@"updating purchase info successful");
                                    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardsRefreshed object:nil];
                                }
                            }
                            return;
                        }
                        NSArray *values = [jsonResponse[@"results"] objectAtIndex:0][@"videos"][@"values"];
                        
                        NSString *streamUrl = nil;
                        NSString *downloadUrl = nil;
                        NSString *profile = nil;
                        NSInteger elapsedTime = 0;
                        
                        NSPredicate *predicate = nil;
                        //                        if (drmEnabled) {
                        //                            predicate = [NSPredicate predicateWithFormat:@"profile == 'sd' && format == 'http'"];
                        //                        }
                        //                        else {
                        if ([_reachability isReachableViaWiFi]) {
                            predicate = [NSPredicate predicateWithFormat:@"(profile == 'VeryHigh' || profile == 'High' || profile == 'sd') && (format == 'hls' || format == 'http')"];
                        } else {
                            predicate = [NSPredicate predicateWithFormat:@"(profile == 'High' || profile == 'Medium' || profile == 'sd') && (format == 'hls' || format == 'http')"];
                        }
                        //  }
                        NSArray *veryHighHttpLinks = [values filteredArrayUsingPredicate:predicate];
                        
                        for (NSDictionary *dict in veryHighHttpLinks) {
                            if ([dict[@"type"] isEqualToString:@"adaptive"] || [dict[@"type"] isEqualToString:@"streaming"]) {
                                profile = dict[@"profile"];
                                streamUrl = dict[@"link"];
                                elapsedTime = [dict[@"elapsedTime"]integerValue];
                            } else if ([dict[@"type"] isEqualToString:@"download"]) {
                                profile = dict[@"profile"];
                                downloadUrl = dict[@"link"];
                            }
                        }
                        
                        if (!streamUrl && !downloadUrl) {
                            [UIAlertView showAlertWithError:[NSError errorWithDomain:kAccountCreationErrors andCode:kAccountCreationErrorGeneric andDescriptionKey:kVideoFeedNotAvailableMessage andUnderlying:0]];
                        }
                        
                        if (downloadUrl && streamUrl) {
                            [UIAlertView alertViewWithTitle:@"Viva" message:@"Choose your choice" cancelBlock:nil dismissBlock:^(int buttonIndex) {
                                if (buttonIndex == -1) {
                                    
                                    [self startDownload:downloadUrl destinationPath:[self getDownloadDestinationPath:contentId withName:title] fileFormat:@"" remoteId:contentId name:title image:image resume:YES];
                                } else if (buttonIndex == 0) {
                                    NSLog(@"stream");
                                    [self initPlayerWithUrl:streamUrl contentId:contentId title:title profile:profile drmEnabled:drmEnabled streaming:YES delegate:delgate elapsedTime:elapsedTime];
                                } else {
                                    [self startDownload:downloadUrl destinationPath:[self getDownloadDestinationPath:contentId withName:title] fileFormat:@"" remoteId:contentId name:title image:image resume:YES];
                                    [self initPlayerWithUrl:streamUrl contentId:contentId title:title profile:profile drmEnabled:drmEnabled streaming:YES delegate:delgate elapsedTime:elapsedTime];
                                }
                            } cancelButtonTitle:nil otherButtonsTitles:@"Download",@"Stream",@"Download & Stream", nil];
                        }
                        else if (downloadUrl) {
                            [self startDownload:downloadUrl destinationPath:[self getDownloadDestinationPath:contentId withName:title] fileFormat:@"" remoteId:contentId name:title image:image resume:YES];
                        } else if (streamUrl) {
                            [self initPlayerWithUrl:streamUrl contentId:contentId title:title profile:profile drmEnabled:drmEnabled streaming:YES delegate:delgate elapsedTime:elapsedTime];
                        }
                    }else {
                        [UIAlertView showAlertWithError:[NSError errorWithDomain:kAccountCreationErrors andCode:kAccountCreationErrorGeneric andDescriptionKey:kVideoFeedNotAvailableMessage andUnderlying:0]];
                    }
                }
             }];
        }
    }
}

-(void)initPlayerWithUrl:(NSString *)url contentId:(NSString *)contentId title:(NSString *)title profile:(NSString *)profile drmEnabled:(BOOL)drmEnabled streaming:(BOOL)streaming delegate:(id)delegate elapsedTime:(NSInteger)elapsedTime
{
    UIViewController *playableView = (UIViewController *)delegate;
    
    isIPhone {
        VideoPlayerViewController *videoPlayerVC = [[VideoPlayerViewController alloc] initWithFrame:CGRectMake(0,0,playableView.view.frame.size.height,playableView.view.frame.size.width) videoPath:url contentId:contentId title:title profile:profile drmEnabled:drmEnabled streaming:streaming elapsedTime:elapsedTime];
        [playableView presentViewController:videoPlayerVC animated:YES completion:nil];
    }
    else
    {
        UIView *scrollingPlayerView = [playableView.view viewWithTag:67];
        VideoPlayerViewController *videoPlayerVC = [[VideoPlayerViewController alloc]initWithFrame:CGRectMake(0,0,scrollingPlayerView.frame.size.width,scrollingPlayerView.frame.size.height) videoPath:url contentId:contentId title:title profile:profile drmEnabled:drmEnabled streaming:streaming elapsedTime:elapsedTime];
        
        videoPlayerVC.videoPlayerDelegate = delegate;
        
        [scrollingPlayerView addSubview:videoPlayerVC.view];
        [playableView.view bringSubviewToFront:scrollingPlayerView];
        [[playableView.view viewWithTag:102] setHidden:YES];
        [[playableView.view viewWithTag:101] setHidden:YES];
        [scrollingPlayerView setNeedsDisplay];
        [scrollingPlayerView bringSubviewToFront:videoPlayerVC.view];
       
    }
}

#pragma mark Download Operation
- (void)startDownload:(NSString *)sourcePath destinationPath:(NSString *)desinationPath fileFormat:(NSString *)fileFormat remoteId:(NSString *)remoteId name:(NSString *)name image:(NSString *)imagePath resume:(BOOL)resume {
    
    TCSTART
    if (networkReachable) {
        if (synchronizeOnWIFI && systemWifiEnabled) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloading==%d",TRUE];
            NSArray *downlods = [self.managedObjectContext fetchObjectsForEntityName:@"Download" withPredicate:predicate];
            if (downlods.count > 0) {
                
                ToastMessageView *toastMessageView = [[ToastMessageView alloc]initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, 50)];
                [self.window addSubview:toastMessageView];
                [toastMessageView showForegroundNotificationBanner:[NSString stringWithFormat:kDownloadPrgoressMessage,[name lowercaseString]]];
                
                Download *download = [downlods objectAtIndex:0];
                if (![download.remoteId isEqualToString:remoteId]) {
                    id downloadData = @{@"waiting":[NSNumber numberWithBool:YES],@"downloading":[NSNumber numberWithBool:NO],@"remoteId":remoteId,@"videoName":name,@"image":imagePath,@"sourcePath":sourcePath,@"destinationPath":desinationPath};
                    [Download updateOrCreateFromJSONData:downloadData inContext:self.managedObjectContext uniqueSanitizedKey:@"remoteId" save:YES];
                    return;
                }
            } else {
                uint64_t totalFreeSpace = [CacheManager getFreeSpace];
                totalFreeSpace = ((totalFreeSpace/1024ll)/1024ll);
#if DEBUG
                NSLog(@"FreeSpace is %llu",totalFreeSpace);
#endif
                
                uint64_t requireSpace = 3072; //3 GB
                if (totalFreeSpace < requireSpace) {
                    [UIAlertView alertViewWithTitle:@"Viva" message:[NSString stringWithFormat:kLowDiskSpace,3.0,name]];
                    return;
                }
            }
            
            DownloadManager *downloadManager = [[DownloadManager alloc]initWithManagedObjectContect:self.managedObjectContext];
    
            TCSTART
            [downloadManager setStartedHandler:^(BOOL success, NSError *error) {
                
            }];
            TCEND
            
            TCSTART
            [downloadManager setProgressHandler:^(CGFloat progress, NSError *error) {
               // [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationRefreshSomething object:[NSNumber numberWithFloat:progress]];
            }];
            TCEND
            
            TCSTART
            [downloadManager setResumeHandler:^(int64_t fileOffset, int64_t expectedTotalBytes) {
                id downloadData = @{@"downloding":[NSNumber numberWithBool:YES],@"paused":[NSNumber numberWithBool:NO],@"remoteId":remoteId};
                [Download updateOrCreateFromJSONData:downloadData inContext:self.managedObjectContext uniqueSanitizedKey:@"remoteId" save:YES];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationDownloadResumed object:nil];
            }];
            TCEND
            
            
            NSDictionary *downloadParams = nil;
            if (sourcePath && remoteId) {
                downloadParams = @{@"urlString": sourcePath,@"contentId":remoteId,@"fileFormat":fileFormat?:@"",@"name":name?:@"",@"image":imagePath?:@"",@"destinationpath":desinationPath};
            }
            
            if (downloadParams) {
                [downloadManager startDownload:downloadParams withCompletionHandler:^(CGFloat progress, NSString *identifier, NSURL *location,NSURLResponse *response, NSError *error) {
                    
                    //[AppDelegate writeLog:[NSString stringWithFormat:@"Download finished with progress %f, Identifier:%@ and location %@.......\n",progress,identifier,location]];

                    if (error) {
                        TCSTART
                        
                        TCEND
                    }
                    if(!error && location) {
                        
                        
                    }
                }];
            } else {
                [UIAlertView showAlertWithError:[NSError errorWithDomain:kGenericErrors andCode:kServerErrorGeneric andDescriptionKey:@"Unknown Error. Please restart the application" andUnderlying:0]];
            }
        } else {
            [UIAlertView showAlertWithError:[NSError errorWithDomain:kGenericErrors andCode:kServerErrorGeneric andDescriptionKey:[NSString stringWithFormat:kWIFINotEnabledMessage,name] andUnderlying:0]];
        }
    } else {
        [UIAlertView showAlertWithError:[NSError errorWithDomain:kGenericErrors andCode:kGenericErrorInvalidOperation andDescriptionKey:kNetworkNotAvailableMessage andUnderlying:0]];
    }
    TCEND
    
    //Testing..........
    //NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:@"appdevclip.wvm"];
    //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://220.226.22.120:9090/aptv3-downloads/appdevclip.wvm"]];

    //    if (downloadOperationQueue) {
    //        for (int i = 0; i < downloadOperationQueue.operations.count; i++) {
    //            JGDownloadOperation *downloadOperation = [downloadOperationQueue.operations objectAtIndex:i];
    //            if ([downloadOperation.remoteId isEqualToString:remoteId]) {
    //                ToastMessageView *toastMessageView = [[ToastMessageView alloc]init];
    //                [self.window addSubview:toastMessageView];
    //                //[toastMessageView showToastMessage:[NSString stringWithFormat:@"Downloading %@ movie",name]];
    //                [toastMessageView showForegroundNotificationBanner:[NSString stringWithFormat:@"Downloading %@",name]];
    //                return;
    //            }
    //        }
    //    }
    //
    //    if (networkReachable) {
    //        if (synchronizeOnWIFI && systemWifiEnabled) {
    //
    //            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:sourcePath]];
    //            //customize the request if needed... Example:
    //            [request setTimeoutInterval:90];
    //
    //            //start downloading the YouTube video to the temporary directory
    //            JGDownloadOperation *operation = [[JGDownloadOperation alloc] initWithRequest:request destinationPath:desinationPath allowResume:resume];
    //
    //            [operation setTag:remoteId.integerValue]; //[self generateUniqueId]];
    //            [operation setName:name];
    //            [operation setRemoteId:remoteId];
    //            [operation setImgPath:imgPath];
    //            [operation setMaximumNumberOfConnections:1];
    //            [operation setRetryCount:20];
    //
    //            //Add to database
    //            if (operation) {
    //                id downloadData = @{@"remoteId":operation.remoteId,@"videoName":operation.name,@"imagePath":operation.imgPath,@"sourcePath":sourcePath,@"destinationPath":desinationPath};
    //                [Download updateOrCreateFromJSONData:downloadData inContext:self.managedObjectContext uniqueSanitizedKey:@"remoteId" save:YES];
    //            }
    //
    //            __block CFTimeInterval started;
    //
    //            //Download Started
    //            [operation setOperationStartedBlock:^(NSUInteger tag, unsigned long long totalBytesExpectedToRead,JGDownloadOperation *operation) {
    //                id downloadData = @{@"downloading":[NSNumber numberWithBool:YES],@"remoteId":operation.remoteId,@"videoName":operation.name,@"imagePath":operation.imgPath};
    //                [self performSelectorOnMainThread:@selector(updateDownloadData:) withObject:downloadData waitUntilDone:NO];
    //                started = CFAbsoluteTimeGetCurrent();
    //                NSLog(@"Operation Started, JGDownloadAcceleration version %@", kJGDownloadAccelerationVersion);
    //            }];
    //
    //            //Progress
    //            [operation setDownloadProgressBlock:^(NSUInteger bytesRead, unsigned long long totalBytesReadThisSession, unsigned long long totalBytesWritten, unsigned long long totalBytesExpectedToRead, NSUInteger tag) {
    //
    //                float progress = ((double)totalBytesWritten/(double)totalBytesExpectedToRead);
    //
    //                CFTimeInterval delta = CFAbsoluteTimeGetCurrent()-started;
    //                NSLog(@"Progress: %.2f%% Average Speed: %.2f kB/s",progress ,totalBytesReadThisSession/1024.0f/delta);
    //
    //                [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationRefreshSomething object:[NSNumber numberWithFloat:progress]];
    //
    //            }];
    //
    //            //Download completed.
    //            [operation setCompletionBlockWithSuccess:^(JGDownloadOperation *operation) {
    //                //Need to do the asset registration with WideVine to play offline.
    //                id downloadData = @{@"downloading":[NSNumber numberWithBool:NO],@"remoteId":operation.remoteId,@"downlodPercentage":[NSNumber numberWithFloat:100],@"downloaded":[NSNumber numberWithBool:YES],@"destinationPath":operation.destinationPath};
    //
    //                [self performSelectorOnMainThread:@selector(updateDownloadData:) withObject:downloadData waitUntilDone:NO];
    //                [self performSelectorOnMainThread:@selector(checkAndStartDownloading) withObject:nil waitUntilDone:NO];
    //
    //                [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationRefreshSomething object:[NSNumber numberWithFloat:1.0f]];
    //
    //                double kbLength = (double)operation.contentLength/1024.0f;
    //                CFTimeInterval delta = CFAbsoluteTimeGetCurrent()-started;
    //                NSLog(@"Success! Downloaded %.2f MB took %.1f seconds, average Speed: %.2f kb/s", kbLength/1024.0f, delta, kbLength/delta);
    //            } failure:^(JGDownloadOperation *operation, NSError *error) {
    //                NSLog(@"Operation Failed: %@", error.localizedDescription);
    //
    //                downloadOperationQueue = nil;
    //                [UIAlertView showAlertWithError:error];
    //                [self checkAndStartDownloading];
    //                //[self performSelectorOnMainThread:@selector(removeOperation:) withObject:operation waitUntilDone:NO];
    //            }];
    //
    //            if (!downloadOperationQueue) {
    //                downloadOperationQueue = [[JGOperationQueue alloc] init];
    //                downloadOperationQueue.handleNetworkActivityIndicator = YES;
    //                downloadOperationQueue.handleBackgroundTask = YES;
    //            }
    //
    //            [downloadOperationQueue addOperation:operation];
    //
    //        } else {
    //           [UIAlertView showAlertWithError:[NSError errorWithDomain:kGenericErrors andCode:kServerErrorGeneric andDescriptionKey:[NSString stringWithFormat:@"WIFI is required to Download the %@ movie, please make sure that your iOS device is connected to WIFI and you enabled the Synchronize WIFI Only in Settings.",name] andUnderlying:0]];
    //        }
    //    } else {
    //        [UIAlertView showAlertWithError:[NSError errorWithDomain:kGenericErrors andCode:kGenericErrorInvalidOperation andDescriptionKey:@"Your internet connection seems to be offline. Please check the internet connection" andUnderlying:0]];
    //    }
}

-(void)updateDownloadData:(id)downloadData {
    
    ToastMessageView *toastMessageView = [[ToastMessageView alloc]initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, 50)];
    [self.window addSubview:toastMessageView];
    //[toastMessageView showToastMessage:[NSString stringWithFormat:@"Started downloading %@ movie",downloadData[@"videoName"]]];
    [toastMessageView showForegroundNotificationBanner:[NSString stringWithFormat:@"Started Downloading %@",downloadData[@"videoName"]]];
    
    [Download updateOrCreateFromJSONData:downloadData inContext:self.managedObjectContext uniqueSanitizedKey:@"remoteId" save:YES];
}

-(NSString*)getDownloadDestinationPath:(NSString *)uniqueId withName:(NSString *)name
{
    NSString *documentDirectory = [self getApplicationDocumentDirectoryPath];
    NSString *videoName = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [NSString stringWithFormat:@"%@/%@%@.wvm", documentDirectory, videoName, uniqueId];
    
    //	for (int i = 0 ; TRUE ; i++)
    //	{
    //        NSString *documentDirectory = [self getApplicationDocumentDirectoryPath];
    //
    //		if(![[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"%@/Downloads/Video%d.wvm", documentDirectory , i]])
    //			return [NSString stringWithFormat:@"%@/Downloads/Video%d.wvm", documentDirectory , i];
    //	}
}

-(NSString *)getApplicationDocumentDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

//- (void)createDownloadsDirectory {
//
//    NSString *documentsDirectory = [self getApplicationDocumentDirectoryPath];
//    NSString *yourDirPath = [documentsDirectory stringByAppendingPathComponent:@"Downloads"];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL isDir = YES;
//    BOOL isDirExists = [fileManager fileExistsAtPath:yourDirPath isDirectory:&isDir];
//    if (!isDirExists) [fileManager createDirectoryAtPath:yourDirPath withIntermediateDirectories:YES attributes:nil error:nil];
//}

-(int)generateUniqueId {
	NSNumber * uniqueId = [[NSUserDefaults standardUserDefaults]objectForKey:@"uniqueId"];
	
	if(uniqueId == nil) {
		uniqueId = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
	}
    
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(uniqueId.intValue + 1)] forKey:@"uniqueId"];
	
	return (uniqueId.intValue + 1);
}

-(void)networkChanged:(NSNotification *)notification {
#if DEBUG
    NSLog(@"Networkd Changed");
#endif
    
    if ([_reachability isReachableViaWiFi]) {
    } else if([_reachability isReachableViaWWAN]) {
    } else if(NotReachable) {
    }
}

-(BOOL)checkDeviceRegistration {
    
    NSString *deviceId = [AppData shared].data[@"deviceId"];
    BOOL deviceRegistered = NO;
    if (deviceId.length > 0) {
        deviceRegistered = YES;
    }
    return deviceRegistered;
}

- (BOOL)isClientKeyValid {
    
    BOOL clientKeyValid = YES;
    
    NSDate *currentDate = [NSDate GMTDate];
    NSDate *clientExpirationDate = [NSDate formatStringToDate:[AppData shared].data[@"expiresAt"]];
    if ([currentDate compare:clientExpirationDate] == NSOrderedDescending || !clientExpirationDate) {
        NSLog(@"currentDate is later than clientExpirationDate");
        clientKeyValid = NO;
    }
    return clientKeyValid;
}

-(void)requestForClientKeyGenerationWithCompletionHandler:(RequestGenerateKeyWithCompletionHandler)completionHandler
{
   	NSDictionary* userData = @{@"deviceId": [AppData shared].data[@"deviceId"]};
    NSMutableDictionary* mutableUserData = [NSMutableDictionary dictionaryWithDictionary: userData];
    
    isIPhone
        [AppDelegate showActivityIndicatorWithText:@"Loading..."];
    
	//When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:@"/user/v2/generateKey" jsonData: mutableUserData requestType: ServerStandardRequestTypeCreate completionHandler: ^(NSDictionary* jsonResponse, NSError* error) {
        
		isIPhone
            [AppDelegate removeActivityIndicator];
        
        BOOL keyUpdated = NO;
		if (error) {
            
		} else {
            
            if ([jsonResponse[@"code"]integerValue] == 200) {
                [[[AppData shared]data]setObject:jsonResponse[@"clientKey"] forKey:@"clientKey"];
                [[[AppData shared]data]setObject:jsonResponse[@"expiresAt"] forKey:@"expiresAt"];
                [[AppData shared]save];
                keyUpdated = YES;
            }
		}
        completionHandler(keyUpdated,jsonResponse,error);
	}];
}

- (NSString *)formatDateToString:(NSDate *)date
{
    if (date == nil) {
        return nil;
    }
	return [NSString stringWithFormat:@"%@Z",[NSDate stringFromDate:date withFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"]];
}



+(void)showActivityIndicatorWithText:(NSString*)text
{
	[self removeActivityIndicator];
	
    [SVProgressHUD showWithStatus:text maskType:SVProgressHUDMaskTypeBlack];
    //	MBProgressHUD* hud   = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    //	hud.labelText        = text;
    //	hud.detailsLabelText = NSLocalizedString(@"Please Wait...", @"");
}

+(void)removeActivityIndicator
{
	[SVProgressHUD dismiss];
}

-(void)showAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Okay",
                          nil];
    [alert show];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Myplex" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Myplex.sqlite"];
    NSLog(@"Database path:%@", storeURL.path);
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    BOOL openFBURL = NO;
    NSLog(@"URL Call back");
    [AppDelegate showActivityIndicatorWithText:@"Loading..."];
    openFBURL = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    if (openFBURL) {
        return openFBURL;
    } else {
        return [GPPURLHandler handleURL:url
                      sourceApplication:sourceApplication
                             annotation:annotation];
    }
}


-(void)copyDownloadsDataIfAny {
    
    NSArray *downloads = [self.managedObjectContext fetchObjectsForEntityName:@"Download" withPredicate:[NSPredicate predicateWithFormat:@"temporaryDestinationFilePath!=nil OR temporaryDestinationFilePath!=null"]];
    NSError *error = nil;
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    for (Download *download in downloads) {
        if (download.temporaryDestinationFilePath.length > 0 && [fileManager fileExistsAtPath:download.temporaryDestinationFilePath]) {
            [AppDelegate writeLog:[NSString stringWithFormat:@"Writing downloaded data to %@.......\n",download.destinationPath]];
            
            [fileManager removeItemAtPath:download.destinationPath error:&error];
            
            NSDictionary *attributes = [[NSFileManager defaultManager]
                                        attributesOfItemAtPath:download.temporaryDestinationFilePath error:&error];
            NSNumber *sourceSize;
            __block NSNumber *destSize;
            if (!error) {
                sourceSize = [attributes objectForKey:NSFileSize];
                [AppDelegate writeLog:[NSString stringWithFormat:@"Copying file %@ of size %@ \n",download.temporaryDestinationFilePath ,sourceSize]];
            }
            
            [AppDelegate copyMovieAtURL:[NSURL fileURLWithPath:download.temporaryDestinationFilePath] toURL:[NSURL fileURLWithPath:download.destinationPath] withCompletionHandler:^(BOOL success, NSError *error){
                if (success)
                {
                    NSDictionary *attributes = [[NSFileManager defaultManager]
                                                attributesOfItemAtPath:download.destinationPath error:&error];
                    
                    if (!error) {
                       destSize = [attributes objectForKey:NSFileSize];
                        [AppDelegate writeLog:[NSString stringWithFormat:@"Copied to file %@ of size %@ \n",download.destinationPath ,destSize]];
                    }
                    
                    if (sourceSize != destSize) {
                        [AppDelegate writeLog:[NSString stringWithFormat:@"Failed Copying full file"]];
                        return ;
                    }
                    
                    if (download.temporaryDestinationFilePath.length > 0 && [fileManager fileExistsAtPath:download.temporaryDestinationFilePath]) {
                        [fileManager removeItemAtPath:download.temporaryDestinationFilePath error:&error];
                    }
                    if (!error) {
                        [AppDelegate writeLog:[NSString stringWithFormat:@"success removing the temp file \n"]];
                    }
                    
                    [AppDelegate writeLog:[NSString stringWithFormat:@"success writing downloaded data to %@ updating database.......\n",download.destinationPath]];
                    TCSTART
                    NSLog(@"updating database with complete status");
                    id downloadData = @{@"temporaryDestinationFilePath":[NSNull null],@"paused":[NSNumber numberWithBool:NO],@"downloading":[NSNumber numberWithBool:NO],@"remoteId":download.remoteId,@"downlodPercentage":[NSNumber numberWithFloat:100],@"downloaded":[NSNumber numberWithBool:YES],@"destinationPath":download.destinationPath};
                    Download *download_ = (Download *)[Download updateOrCreateFromJSONData:downloadData inContext:self.managedObjectContext uniqueSanitizedKey:@"remoteId" save:YES];
                    [AppDelegate writeLog:[NSString stringWithFormat:@"success updating database: downloading status %d, downloaded status %d.......\n",download_.downloading.boolValue,download_.downloaded.boolValue]];
                    
                    [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationDownloadFinished object:nil];
                    
                    VideoPlayerViewController *videoPlayerVC = [[VideoPlayerViewController alloc]init];
                    WViOsApiStatus initiazlizationStatus = [videoPlayerVC initializeWideVineWithProfile:download_.profile streaming:NO contentId:download_.remoteId];
                    if (initiazlizationStatus == WViOsApiStatus_OK) {
                        NSString *videoName = [download_.videoName stringByReplacingOccurrencesOfString:@" " withString:@""];
                        [videoPlayerVC registerAsset:[NSString stringWithFormat:@"%@%@.wvm",videoName,download_.remoteId]];
                        id updateData = @{@"drmRightsAcquired":@YES, @"remoteId":download_.remoteId};
                        download_ = (Download *)[Download updateOrCreateFromJSONData:updateData inContext:self.managedObjectContext uniqueSanitizedKey:@"remoteId" save:YES];
                        [AppDelegate writeLog:[NSString stringWithFormat:@"success acuiring rights: downloading status %d, downloaded status %d drmRightAcqire status %d.......\n",download_.downloading.boolValue,download_.downloaded.boolValue,download_.drmRightsAcquired.boolValue]];
                    }
                    
                    [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationDownloadFinished object:nil];
                    
                    //check for other waiting/paused downloads and start them.
                    [self checkAndStartDownloading];
                    TCEND
                }
                else
                {
                    TCSTART
                    [AppDelegate writeLog:[NSString stringWithFormat:@"Failed writing downloaded data to %@. Error: %@.......\n",download.destinationPath,error]];
                    /*
                     In the general case, what you might do in the event of failure depends on the error and the specifics of your application.
                     */
                    //Download *download = (Download *)[Download fetchByRemoteId:session.configuration.identifier context:_appDelegate.managedObjectContext];
                    [self.managedObjectContext deleteObject:download];
                    
                    [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationDownloadFailed object:nil];
                    
                    BLog(@"Error during the copy: %@", [error localizedDescription]);
                    TCEND
                }
            }];
        }
        
    }
    
    //                BOOL success = [fileManager copyItemAtURL:[NSURL fileURLWithPath:download.temporaryDestinationFilePath] toURL:[NSURL fileURLWithPath:download.destinationPath] error:&error];
}

+(void)copyMovieAtURL:(NSURL *)sourceUrl toURL:(NSURL *)destUrl withCompletionHandler:(void (^) (BOOL success, NSError *error))completionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSError *error = nil;
        NSFileManager *fileManager = [[NSFileManager alloc]init];
        //sleep(30);
        BOOL success = [fileManager copyItemAtURL:sourceUrl toURL:destUrl error:&error];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            completionBlock(success, error);
        });
    });
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    //isIPhone
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft |   UIInterfaceOrientationMaskLandscapeRight;
        //return UIInterfaceOrientationMaskLandscape;
    //return UIInterfaceOrientationMaskAll;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    [AppDelegate writeLog:@"handleEventsForBackgroundURLSessionIdentifier........\n"];
    
    DownloadManager *downloadManager = [[DownloadManager alloc]initWithManagedObjectContect:self.managedObjectContext];
    [downloadManager loadSession:identifier];
    
    [AppDelegate writeLog:[NSString stringWithFormat:@"Rejoining session with identifier %@ %@", identifier, downloadManager.session]];
    
    self.sessionCompletionHandler = completionHandler;
    
    NSLog(@"handleEventsForBackgroundURLSessionIdentifier %@",identifier);
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
#if DEBUG
    NSLog(@"applicationWillEnterForeground");
#endif
    [AppDelegate writeLog:@"applicationWillEnterForeground........\n"];
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
#if DEBUG
    NSLog(@"applicationDidBecomeActive");
#endif
    [AppDelegate writeLog:@"applicationDidBecomeActive........\n"];
    [self copyDownloadsDataIfAny];
    [self cleanDownloadsTempDirectory];
}

-(void)applicationWillResignActive:(UIApplication *)application
{
#if DEBUG
    NSLog(@"applicationWillResignActive");
#endif
    [AppDelegate writeLog:@"applicationWillResignActive........\n"];
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
#if DEBUG
    NSLog(@"applicationDidEnterBackground");
#endif
    [AppDelegate writeLog:@"applicationDidEnterBackground........\n"];
}

-(void)applicationWillTerminate:(UIApplication *)application
{
#if DEBUG
    NSLog(@"applicationWillTerminate");
#endif
    [AppDelegate writeLog:@"applicationWillTerminate........\n"];
}

+(void)writeLog:(NSString *)logString {
    
    TCSTART
    BOOL result = YES;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:@"DeveloperLog.txt"];
    
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if ( !fh ) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:path];
    }
    if ( !fh ) return;
    @try {
        [fh seekToEndOfFile];
        logString = [NSString stringWithFormat:@"%@:   %@",[NSDate date],logString];
        [fh writeData:[logString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    @catch (NSException * e) {
        result = NO;
    }
    [fh closeFile];
    TCEND
}

@end
