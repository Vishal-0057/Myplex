//
//  PosterView.m
//  Myplex
//
//  Created by shiva on 10/28/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "PosterView.h"

static CGFloat UIScrollViewDefaultScrollPointsPerSecond = 30.0f;

@implementation PosterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        [self addPoster];
    }
    return self;
}

-(void)addPoster {
    UIScrollView *scr = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    scr.tag = 2;
    scr.autoresizingMask=UIViewAutoresizingNone;
    [self addSubview:scr];
    [self setupScrollView:scr];
}

- (void)setupScrollView:(UIScrollView*)scrMain {
    // we have 4 images here.
    
    NSInteger iOSbackdropPostersCount = 0;

    NSString *backdropImageName = nil;
    isIPhone {
        iOSbackdropPostersCount = 2;
        backdropImageName = @"iOSbackdrop%02i";
    }
    else {
        iOSbackdropPostersCount = 2;
        backdropImageName = @"fifaBG%02i";
    }
    
    for (int i=1; i<=iOSbackdropPostersCount; i++) {
        // create image
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:backdropImageName,i]];
        if (i == iOSbackdropPostersCount) {
            image = [UIImage imageNamed:[NSString stringWithFormat:backdropImageName,1]];
        }
        // create imageView
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake((i-1)*scrMain.frame.size.width, 0, scrMain.frame.size.width, scrMain.frame.size.height)];
        // set scale to fill
        imgV.contentMode=UIViewContentModeScaleToFill;
        // set image
        [imgV setImage:image];
        // apply tag to access in future
        imgV.tag=i+1;
        // add to scrollView
        [scrMain addSubview:imgV];
    }
    // set the content size to 10 image width
    [scrMain setContentSize:CGSizeMake(scrMain.frame.size.width*iOSbackdropPostersCount, scrMain.frame.size.height)];
    // enable timer after each animationDuration seconds for scrolling.
    CGFloat animationDuration = (0.5f / UIScrollViewDefaultScrollPointsPerSecond);
    posterScrollTimer = [NSTimer scheduledTimerWithTimeInterval:animationDuration target:self selector:@selector(scrollingTimer:) userInfo:nil repeats:YES];
}

- (void)scrollingTimer:(NSTimer *)timer {
    
    // access the scroll view with the tag
    //UIView *backgroundView = (UIView *)[self.view viewWithTag:1];
    UIScrollView *scrMain = (UIScrollView*) [self viewWithTag:2];
    
    CGFloat animationDuration = timer.timeInterval;
    
    CGFloat pointChange = UIScrollViewDefaultScrollPointsPerSecond * animationDuration;
    CGPoint newOffset = scrMain.contentOffset;
    newOffset.x = newOffset.x + pointChange;
    
    if (newOffset.x > (scrMain.contentSize.width - scrMain.bounds.size.width))
    {
        newOffset.x = newOffset.x - newOffset.x;
        scrMain.contentOffset = newOffset;
        [scrMain scrollRectToVisible:CGRectMake(0, 0, scrMain.frame.size.width, scrMain.frame.size.height) animated:NO];
    }
    else
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        scrMain.contentOffset = newOffset;
        [UIView commitAnimations];
    }
}

-(void)invalidateTimer {
    if (posterScrollTimer) {
        [posterScrollTimer invalidate];
        posterScrollTimer = nil;
    }
}


@end
