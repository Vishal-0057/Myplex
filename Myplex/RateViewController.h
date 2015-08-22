//
//  RateViewController.h
//  Myplex
//
//  Created by Igor Ostriz on 14/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarsView.h"

@protocol RateDelegate;
@interface RateViewController : UIViewController

@property (weak, nonatomic) IBOutlet StarsView *starsView;
@property (nonatomic) CGFloat userRating;

@property (nonatomic, weak) id<RateDelegate> delegate;

@end


@protocol RateDelegate <NSObject>

- (void)pressedDoneWithRateController:(RateViewController *)rateViewController;

@end