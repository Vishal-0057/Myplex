//
//  ToastMessageView.m
//  Myplex
//
//  Created by shiva on 11/13/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "ToastMessageView.h"
#import "AppDelegate.h"

@implementation ToastMessageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)showToastMessage:(NSString *)message {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    self.backgroundColor = [UIColor clearColor];
    self.tag = -100000;
    
    UILabel *toastLabel;
    toastLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width - 20, self.frame.size.height)];
    [self addSubview:toastLabel];
    toastLabel.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
    toastLabel.textColor = [UIColor whiteColor];
    toastLabel.textAlignment = NSTextAlignmentCenter;
    toastLabel.text = message;
    toastLabel.numberOfLines = 0;
    toastLabel.layer.cornerRadius = 7.0f;
    toastLabel.layer.masksToBounds = YES;
    toastLabel.tag = 1;
    toastLabel.font = [UIFont fontWithName:@"MuseoSansRounded-700" size:14];
    
    [appDelegate.window bringSubviewToFront:self];
    
    [self performSelector:@selector(hideMessageView:) withObject:self afterDelay:5];
}

- (void)hideMessageView:(UIView *)view {
    [view removeFromSuperview];
    view = nil;
}


-(void)showForegroundNotificationBanner:(NSString*)message
{
//	CGSize sizeRequired = [message sizeWithFont:[UIFont fontWithName:@"MuseoSansRounded-700" size:14]
//							  constrainedToSize:CGSizeMake(320,480)];
	
	[self  setFrame:CGRectMake(0, -50, self.frame.size.width, self.frame.size.height)];
    [self setBackgroundColor:[UIColor blackColor]];

    UILabel *foreGroundNotificationBannerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
    [foreGroundNotificationBannerLabel setBackgroundColor:[UIColor clearColor]];
    [foreGroundNotificationBannerLabel setNumberOfLines:0];
    [self addSubview:foreGroundNotificationBannerLabel];
    foreGroundNotificationBannerLabel.textAlignment = NSTextAlignmentCenter;
    foreGroundNotificationBannerLabel.textColor = [UIColor whiteColor];
    [foreGroundNotificationBannerLabel setFont:[UIFont fontWithName:@"MuseoSansRounded-700" size:14]];
	[foreGroundNotificationBannerLabel setText:message];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:1.0f];
	
	[self setFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
	
	[NSTimer scheduledTimerWithTimeInterval:4.0f target:self selector:@selector(removeForegroundNotificationBanner:) userInfo:nil repeats:NO];
	[UIView commitAnimations];
	
}

-(void)removeForegroundNotificationBanner:(id)sender
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:1.0f];
	
	[self setFrame:CGRectMake(0, -50, self.frame.size.height, self.frame.size.height)];
	//[foreGroundNotificationBannerLabel setFrame:CGRectMake(0,0,320,foreGroundNotificationBannerLabel.frame.size.height)];
	
	[(NSTimer *)sender invalidate];
	[UIView commitAnimations];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
