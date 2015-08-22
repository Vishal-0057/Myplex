//
//  VideoPlayerViewController.m
//  Myplex
//
//  Created by shiva on 10/1/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "AppData.h"
#import "UIAlertView+ReportError.h"
#import "VideoPlayerViewController.h"
#import "Content.h"
#import "NSManagedObjectContext+Utils.h"
#import "NSManagedObject+Utils.h"
#import "ToastMessageView.h"
#import "Notifications.h"
#import "ServerSettingsManager.h"
#import "Player.h"
#import "AppDelegate.h"

@interface VideoPlayerViewController () {
    BOOL _streaming;
    NSString *_contentId;
    NSString *_profile;
    NSString *_name;
    Content *_content;
    float _elapsedTime;
}

@end

@implementation VideoPlayerViewController

static VideoPlayerViewController *v_view_controller;

@synthesize moviePlayer_;

- (id)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath contentId:(NSString *)contentId title:(NSString *)title profile:(NSString *)profile drmEnabled:(BOOL)drmEnabled streaming:(BOOL)streaming elapsedTime:(NSInteger)elapsedTime
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        
        _streaming = streaming;
        _contentId = contentId;
        _profile = profile;
        _name = title;
        _elapsedTime = elapsedTime;;
        
        NSManagedObjectContext *moctx = [NSManagedObjectContext childUIManagedObjectContext];
        _content = (Content *)[Content fetchByRemoteId:_contentId context:moctx];
        
        if (drmEnabled) { //Initialze widevine
            //videoPath = @"The Pursuit of Happyness258.wvm";
           NSString *responseUrl = [self initializeWidevineWith:streaming videoPath:videoPath];
            if (responseUrl) {
                [self play:responseUrl streaming:streaming];
            } else { //failed initializing asset.
#if DEBUG
                NSLog(@"Failed registering asset");
#endif
            }
        } else {
            [self play:videoPath streaming:streaming];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    v_view_controller = self;
    //we can add required playback notifications here
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStopHandler:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer_];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doneButtonClick:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stop:) name:@"StopPlay" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkReachable:) name:kNotificationNetworkReachble object:nil];
}

-(void)doneButtonClick:(NSNotification*)notification {
#if DEBUG
    NSLog(@"moviePlayer Done button clicked");
#endif
    NSNumber *reason = [notification.userInfo objectForKey:MPMoviePlayerFullscreenAnimationCurveUserInfoKey];
    
    if ([reason intValue] == MPMovieFinishReasonUserExited) {
        // done button clicked!
        [self.moviePlayer_ play];
#if DEBUG
        NSLog(@"moviePlayer Done button clicked");
#endif
    }
}


-(void)networkReachable:(NSNotification *)notification {
    //WV_NowOnline();
}

-(void)applicationWillResignActive:(NSNotification *)notification {
    if (![self.moviePlayer_ isPreparedToPlay]) {
        NSLog(@"moviePlayer is not prepared to play");
        [self stop:nil];
    }
}

-(void)applicationWillEnterForeground:(NSNotification *)notification {
   //if(moviePlayer_.playbackState == MPMoviePlaybackStatePaused) {
    NSLog(@"moviePlayerPlaybackState %d",self.moviePlayer_.playbackState);

    [self.moviePlayer_ prepareToPlay];
    //[self.moviePlayer_ pause];
   //}
}

-(void)updateStatus:(NSString *)action {
    
    if (_elapsedTime > 2.0 && self.moviePlayer_.currentPlaybackTime < 1) {
        return;
    }

    _content.elapsedTime = [NSNumber numberWithInteger:self.moviePlayer_.currentPlaybackTime];
    NSManagedObjectContext *tmp = [NSManagedObjectContext tempManagedObjectContext];
    [tmp savePropagateWait];

    Player *player = [[Player alloc]init];

    int currentPlaybackTime = self.moviePlayer_.currentPlaybackTime;
    
    if (!self.moviePlayer_.currentPlaybackTime < (self.moviePlayer_.duration - 20)) {
        currentPlaybackTime = 0;
    }
    NSDictionary *statusInfo = @{@"action":action,@"elapsedTime":[NSNumber numberWithInteger:currentPlaybackTime],@"duration":[NSNumber numberWithInteger:self.moviePlayer_.duration],@"streamName":_name,@"contentId":_contentId};
    [player updateStatus:statusInfo withClientKey:[[AppData shared]data][@"clientKey"]];
}

-(void)stop:(NSNotification *)notification {
    [self playStopHandler:nil];
}

-(void)loadStateChanged:(NSNotification *)notification {
    
    if(self.moviePlayer_.loadState == MPMovieLoadStatePlayable) {
#if DEBUG 
        NSLog(@"Movie resume time %f",self.moviePlayer_.currentPlaybackTime);
#endif
//        if (_elapsedTime > 2.0) {
//            [moviePlayer_ setInitialPlaybackTime:_elapsedTime];
//        }
    }
}

-(void)playbackStateChanged:(NSNotification *)notification {
    
    NSLog(@"moviePlayerPlaybackState %d",self.moviePlayer_.playbackState);
    
    if(self.moviePlayer_.playbackState == MPMoviePlaybackStatePaused)
    {
        [Analytics logEvent:EVENT_PLAY parameters:@{PLAY_CONTENT_ID_PROPERTY:_contentId,PLAY_CONTENT_NAME_PROPERTY:_name,PLAY_CONTENT_STATUS_PROPERTY:PLAY_CONTENT_STATUS_TYPES_STRING(Pause),PLAY_CONTENT_PAUSE_TIME_PROPERTY:[NSDate date]} timed:NO];
        
        
    }
    else if(self.moviePlayer_.playbackState == MPMoviePlaybackStateSeekingForward || self.moviePlayer_.playbackState == MPMoviePlaybackStateSeekingBackward)
    {
        [Analytics logEvent:EVENT_PLAY parameters:@{PLAY_CONTENT_ID_PROPERTY:_contentId,PLAY_CONTENT_NAME_PROPERTY:_name,PLAY_CONTENT_STATUS_PROPERTY:PLAY_CONTENT_STATUS_TYPES_STRING(Seek),PLAY_CONTENT_SEEK_TIME_PROPERTY:[NSDate date]} timed:NO];
        

    }
    else if(self.moviePlayer_.playbackState == MPMoviePlaybackStatePlaying)
    {
        [Analytics logEvent:EVENT_PLAY parameters:@{PLAY_CONTENT_ID_PROPERTY:_contentId,PLAY_CONTENT_NAME_PROPERTY:_name,PLAY_CONTENT_STATUS_PROPERTY:PLAY_CONTENT_STATUS_TYPES_STRING(Playing)} timed:NO];
    }
    else if(self.moviePlayer_.playbackState == MPMoviePlaybackStateInterrupted)
    {
        [self.moviePlayer_ pause];
    }
}

-(void)playStopHandler:(NSNotification *)notification {
    
    [self updateStatus:@"Stop"];

    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.moviePlayer_ stop];
#if TARGET_CPU_ARM
    WV_Stop();
    WV_Terminate();
#endif
    NSError *mediaPlayerError = nil;
    NSDictionary *notificationUserInfo = [notification userInfo];
    NSNumber *resultValue = [notificationUserInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    MPMovieFinishReason reason = [resultValue intValue];
    if (reason == MPMovieFinishReasonPlaybackError)
    {
        mediaPlayerError = [notificationUserInfo objectForKey:@"error"];
        if (mediaPlayerError)
        {
            [Analytics logEvent:EVENT_PLAY parameters:@{PLAY_CONTENT_ID_PROPERTY:_contentId,PLAY_CONTENT_NAME_PROPERTY:_name,PLAY_CONTENT_STATUS_PROPERTY:PLAY_CONTENT_STATUS_TYPES_STRING(End),PLAY_CONTENT_ERROR_PROPERTY:[mediaPlayerError localizedDescription]} timed:NO];
            
            NSLog(@"playback failed with error description: %@", [mediaPlayerError localizedDescription]);
        }
        else
        {
            NSLog(@"playback failed without any given reason");
        }
    }
    if (mediaPlayerError) {
        [Analytics logEvent:EVENT_PLAY parameters:@{PLAY_CONTENT_ID_PROPERTY:_contentId,PLAY_CONTENT_NAME_PROPERTY:_name,PLAY_CONTENT_STATUS_PROPERTY:PLAY_CONTENT_STATUS_TYPES_STRING(End),PLAY_CONTENT_END_TIME_PROPERTY:[NSDate date]} timed:NO];
    }
    isIPhone
        [self dismissViewControllerAnimated:YES completion:nil];
    else
    {
        [self.moviePlayer_.view removeFromSuperview];
        [[self.videoPlayerDelegate view] sendSubviewToBack:[[self.videoPlayerDelegate view] viewWithTag:67]];
        [[[self.videoPlayerDelegate view] viewWithTag:102] setHidden:NO];
        [[[self.videoPlayerDelegate view] viewWithTag:101] setHidden:NO];
    }
    self.moviePlayer_ = nil;
}

#if TARGET_CPU_ARM

WViOsApiStatus WViOSCallback(WViOsApiEvent event, NSDictionary *attributes)
{
    SEL selector = 0;
    //NSString* logMessage = [NSString stringWithFormat:@"callback %d %@%@\n", event, NSStringFromWViOsApiEvent(event), attributes];
   // [v_view_controller performSelectorOnMainThread:NSSelectorFromString(@"updateText:") withObject:logMessage waitUntilDone:NO];
    NSLog(@"callback %d %@ %@\n", event, NSStringFromWViOsApiEvent(event), attributes);
    switch(event){
        case WViOsApiEvent_Bitrates:
            selector = NSSelectorFromString(@"HandleBitrates:");
            break;
        case WViOsApiEvent_SetCurrentBitrate:
            selector = NSSelectorFromString(@"HandleCurrentBitrate:");
            break;
        case WViOsApiEvent_StoppingOnError:
            //[UIAlertView showAlertWithError:[NSError errorWithDomain:@"tv.myplex.playerror" andCode:[attributes[@"WVErrorKey"]intValue] andDescriptionKey:[NSString stringWithFormat:kDRMPlayMessage,[attributes[@"WVErrorKey"]intValue]] andUnderlying:0]];
            break;
        case WViOsApiEvent_EMMReceived:
            //[UIAlertView showAlertWithError:[NSError errorWithDomain:@"tv.myplex.playerror" andCode:[attributes[@"WVErrorKey"]intValue] andDescriptionKey:[NSString stringWithFormat:@"Rights installed time remianing = %d",[attributes[@"WVEMMTimeRemainingKey"]intValue]] andUnderlying:0]];
            break;
        default:break;
    }
    if(selector){
        //[v_view_controller performSelectorOnMainThread:selector withObject:attributes waitUntilDone:NO];
    }
    return WViOsApiStatus_OK;
}

#endif

-(NSString *) initializeWidevineWith:(BOOL)streaming videoPath:(NSString *)videoPath {
 
#if TARGET_CPU_ARM
    
    WViOsApiStatus initializeStatus = [self initializeWideVineWithProfile:_profile streaming:streaming contentId:_contentId];
    
    if (!streaming) {
        [self registerAsset:videoPath];
    }
    
    if(initializeStatus == WViOsApiStatus_AlreadyInitialized)
    {
        return [self initializeAssetWithWideVinePlayer:videoPath];
    }
    else if(initializeStatus != WViOsApiStatus_OK)
    {
        [Analytics logEvent:EVENT_PLAY parameters:@{PLAY_CONTENT_ID_PROPERTY:_contentId,PLAY_CONTENT_NAME_PROPERTY:_name,PLAY_CONTENT_STATUS_PROPERTY:PLAY_CONTENT_STATUS_TYPES_STRING(Error),PLAY_CONTENT_WIDEVINE_ERROR:[NSNumber numberWithInteger:initializeStatus]} timed:NO];
        NSLog(@"Could not initialize WVLibrary %d", initializeStatus);
    }   else {
        return [self initializeAssetWithWideVinePlayer:videoPath];
    }
#endif

    return nil;
}

-(WViOsApiStatus)initializeWideVineWithProfile:(NSString *)profile streaming:(BOOL)streaming contentId:(NSString *)contentId  {
    
    NSString *url = nil;
    
    //url = @"http://ec2-122-248-233-48.ap-southeast-1.compute.amazonaws.com/widevine/cypherpc/cgi-bin/GetEMMs.cgi";
    
    //Loads based on the build configuration.
    url = [[[ServerSettingsManager sharedServerSettings] APIURLwithPath:@"licenseproxy/license"]absoluteString];
    
    //url = @"http://api-beta.myplex.in/licenseproxy/v2/license"; //Beta
    
    //url = @"http://api.myplex.com/licenseproxy/v2/license/"; //Prod
    
    //url = @"http://ec2-54-254-107-243.ap-southeast-1.compute.amazonaws.com/widevine/cypherpc/cgi-bin/GetEMMs.cgi";
    
    //    if (streaming) {
    //        //url = @"http://drmvod2.sotal-iptv.com/widevine/cypherpc/cgi-bin/GetEMMs.cgi";
    //        url = @"http://ec2-122-248-233-48.ap-southeast-1.compute.amazonaws.com/widevine/cypherpc/cgi-bin/GetEMMs.cgi";
    //        //url = @"http://dev.myplex.in:80/licenseproxy/v2/license";
    //        //url = @"http://api-beta.myplex.in/licenseproxy/v2/license";
    //    } else {
    //       //url =  @"https://staging.shibboleth.tv/widevine/cypherpc/cgi-bin/GetEMMs.cgi";
    //         //url = @"http://api-beta.myplex.in/licenseproxy/v2/license";
    //    }
    
    //    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:/*@"http://213.243.4.66/widevine/cypherpc/cgi-bin/GetEMMs.cgi"@"http://drmvod2.sotal-iptv.com/widevine/cypherpc/cgi-bin/GetEMMs.cgi"@"https://staging.shibboleth.tv/widevine/cypherpc/cgi-bin/GetEMMs.cgi"*/url, WVDRMServerKey,
    //                                @"session123", WVSessionIdKey,
    //                                @"ipad123456", WVClientIdKey,
    //                                /*@"sotalinteractive"*/@"OEM", WVPortalKey,
    //                                [[NSBundle mainBundle] resourcePath], WVAssetRootKey,
    //                                NULL];
    
#if TARGET_CPU_ARM
    
    int profile_ = 1;
    if ([profile isEqualToString:@"sd"]) {
        profile_ = 0;
    }
    NSData *optData = [[NSString stringWithFormat:@"clientkey:%@,contentid:%@,type:%@,profile:%d",[[AppData shared]data][@"clientKey"],contentId,streaming?@"st":@"lp",profile_] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedOptString = [optData base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];

#if DEBUG
    NSString *optString = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"clientkey:%@,contentid:%@,type:%@,profile:%d",[[AppData shared]data][@"clientKey"],contentId,streaming?@"st":@"lp",profile_]];
    NSLog(@"OptData....... %@",optString);
#endif
    
    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:/*@"http://213.243.4.66/widevine/cypherpc/cgi-bin/GetEMMs.cgi"@"http://drmvod2.sotal-iptv.com/widevine/cypherpc/cgi-bin/GetEMMs.cgi"@"https://staging.shibboleth.tv/widevine/cypherpc/cgi-bin/GetEMMs.cgi"*/url, WVDRMServerKey,
                                @"session123", WVSessionIdKey,
                                @"ipad123456", WVClientIdKey,
                                /*@"sotalinteractive"*/@"sotalapalya", WVPortalKey,
                                /*[[NSBundle mainBundle] resourcePath], WVAssetRootKey,*/base64EncodedOptString,WVCAUserDataKey,@"123456789",@"clientid",
                                NULL];
    NSLog(@"drm params %@",dictionary);
    
    
     return WV_Initialize(WViOSCallback, dictionary);
#endif

}

-(WViOsApiStatus)registerAsset:(NSString *)asset {
    //videoPath = @"http://46.137.243.190/wvm/267fs_test.wvm";
    WViOsApiStatus assetRegisterStatus = WV_RegisterAsset(asset);
    NSLog(@"Asset Registration Status %d",assetRegisterStatus);
    //    if (assetRegisterStatus != WViOsApiStatus_OK) {
    //        return nil;
    //    }
    return assetRegisterStatus;
}

-(NSString *)initializeAssetWithWideVinePlayer:(NSString *)videoPath
{

#if TARGET_CPU_ARM

    @try {
        
        [Analytics logEvent:EVENT_PLAY parameters:@{PLAY_CONTENT_ID_PROPERTY:_contentId,PLAY_CONTENT_NAME_PROPERTY:_name,PLAY_CONTENT_STATUS_PROPERTY:PLAY_CONTENT_STATUS_TYPES_STRING(PlayerRightsAcquisition)} timed:NO];
        
        NSMutableString *responseUrl = [NSMutableString string];
        
        //videoPath = @"http://46.137.243.190/wvm/267fs_test.wvm";
        NSLog(@"VideoPath:%@ and responseurl %@",videoPath,responseUrl);
        WViOsApiStatus status = WV_Play(videoPath, responseUrl, 0);
        
        if(status!=WViOsApiStatus_OK){
            [Analytics logEvent:EVENT_PLAY parameters:@{PLAY_CONTENT_ID_PROPERTY:_contentId,PLAY_CONTENT_NAME_PROPERTY:_name,PLAY_CONTENT_STATUS_PROPERTY:PLAY_CONTENT_STATUS_TYPES_STRING(Error),PLAY_CONTENT_WIDEVINE_ERROR:[NSNumber numberWithInteger:status]} timed:NO];
            NSLog(@"WVPlay failed %d", status);
        } else {
            return responseUrl;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
    
#endif
    
    return nil;
}

-(void)play:(NSString *)videoPath streaming:(BOOL)streaming {
    
    @try {
        NSURL *url = nil;
        //if (streaming) {
            url = [NSURL URLWithString:videoPath];
        //} else {
        //    url = [NSURL fileURLWithPath:videoPath];
        //}
        
        MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] init];
        if(mp) {
            self.moviePlayer_ = mp;
//            [self.moviePlayer_ setContentURL:url];
//            [self.moviePlayer_ prepareToPlay];
            self.moviePlayer_.view.frame = self.view.frame;
            [self.moviePlayer_ setContentURL:url];
            [self.moviePlayer_ prepareToPlay];
            isIPhone
                [self.moviePlayer_ setControlStyle:MPMovieControlStyleFullscreen];
            else
                [self.moviePlayer_ setControlStyle:MPMovieControlStyleDefault];
            //[self.moviePlayer_ setScalingMode:MPMovieScalingModeFill];
//            [self.moviePlayer_ setControlStyle:MPMovieControlStyleEmbedded];
//            self.moviePlayer_.scalingMode = MPMovieScalingModeFill;
//            if (streaming) {
//                self.moviePlayer_.movieSourceType = MPMovieSourceTypeStreaming;
//            }
            [self.view addSubview:self.moviePlayer_.view];
//            [self presentMoviePlayerViewControllerAnimated:self.moviePlayer_];
            
            
            NSLog(@"MoviePlayer Added");
//                    if (streaming) {
//                        self.moviePlayer_.movieSourceType = MPMovieSourceTypeStreaming;
//                    }
            //[self.moviePlayer_ prepareToPlay];
            [self.moviePlayer_ play];
            
            if (_elapsedTime > 2.0) {
                [self.moviePlayer_ setInitialPlaybackTime:_elapsedTime];
            }

            [self performSelector:@selector(showRatingWarning) withObject:nil afterDelay:2.0];
            
            [Analytics logEvent:EVENT_PLAY parameters:@{PLAY_CONTENT_ID_PROPERTY:_contentId,PLAY_CONTENT_NAME_PROPERTY:_name,PLAY_CONTENT_START_TIME_PROPERTY:[NSDate date],PLAY_CONTENT_STATUS_PROPERTY:PLAY_CONTENT_STATUS_TYPES_STRING(Start)} timed:NO];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}

-(void)showRatingWarning {
    
    if ([_content.type isEqualToString:@"trailer"])
        return;
    
    NSArray *ratingA = [[_content.certifiedRatings filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"(rating == 'A')"]]allObjects];
    if (ratingA.count > 0) {
        ToastMessageView *toastMessageView = [[ToastMessageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, 50)];
        [self.view addSubview:toastMessageView];
        [toastMessageView showToastMessage:@"18+"];
    }
}

//For iOS 6
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
