//
//  VideoPlayerViewController.h
//  Myplex
//
//  Created by shiva on 10/1/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#if TARGET_CPU_ARM
#import "WViPhoneAPI.h"
#endif

@interface VideoPlayerViewController : UIViewController {
    MPMoviePlayerController *moviePlayer_;
}

@property (nonatomic, retain) MPMoviePlayerController *moviePlayer_;
@property (nonatomic, retain) id videoPlayerDelegate;

- (id)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath contentId:(NSString *)contentId title:(NSString *)title profile:(NSString *)profile drmEnabled:(BOOL)drmEnabled streaming:(BOOL)streaming elapsedTime:(NSInteger)elapsedTime;

-(WViOsApiStatus)initializeWideVineWithProfile:(NSString *)profile streaming:(BOOL)streaming contentId:(NSString *)contentId;
-(WViOsApiStatus)registerAsset:(NSString *)asset;

@end
