//
//  RateViewController.m
//  Myplex
//
//  Created by Igor Ostriz on 14/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "MZFormSheetController.h"
#import "RateViewController.h"



@implementation RateViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.starsView.userRating = self.userRating;
    self.starsView.allowEdit = YES;
    self.starsView.animated = NO;
}

- (IBAction)done:(UIButton *)sender
{
    self.userRating = self.starsView.userRating;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pressedDoneWithRateController:)]) {
        [self.delegate pressedDoneWithRateController:self];
    }
}

- (IBAction)cancel:(UIButton *)sender
{
    [self dismissFormSheetControllerAnimated:YES completionHandler:nil];
}


#pragma mark - autoraotation support

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
    
}


@end
