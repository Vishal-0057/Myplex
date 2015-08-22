//
//  ViewController.m
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
//    [super viewDidLoad];
    /* Simple Viewable red rectrangle */
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100,100,100,50)];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    /* Create simple animation */
    //Create context for animation
    NSValue *contextPoint = [NSValue valueWithCGPoint:view.center];
    [UIView beginAnimations:nil context:(__bridge void *)(contextPoint)];
    //Animation duration in float
    [UIView setAnimationDuration:5];
    //Animation process curve
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //Animation repeate
    [UIView setAnimationRepeatCount:1];
    //Animation start after delay
    [UIView setAnimationDelay:1];
    //Apply transformations in combination to the view
    view.transform =  CGAffineTransformConcat(
                        CGAffineTransformConcat(
                            CGAffineTransformConcat(
                                CGAffineTransformMakeTranslation(-12,0),
                                CGAffineTransformMakeScale(3,3)
                            ),
                            CGAffineTransformMakeRotation(3.14)
                        ),
                        CGAffineTransformMake(1,2,3,4,5,6)
                      );
    
    [UIView commitAnimations];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
