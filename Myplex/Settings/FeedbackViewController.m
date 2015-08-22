//
//  FeedbackViewController.m
//  Myplex
//
//  Created by shiva on 10/9/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "FeedbackViewController.h"
#import "CommentReview.h"
#import "UIAlertView+ReportError.h"
#import "AppDelegate.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

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
    
    self.title = @"feedback";
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:200.0f/255.0f green:16.0f/255.0f blue:26.0f/255.0f alpha:1.0f];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;   // iOS 7(x)
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"cancel" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonClicked:)];
    [leftBarButton setTitle:@"cancel"];
    leftBarButton.tintColor = [UIColor whiteColor];
    [self.navigationItem setLeftBarButtonItem:leftBarButton];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"send" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClicked:)];
    [rightBarButton setTitle:@"send"];
    rightBarButton.tintColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    
    reviewTextView.layer.cornerRadius = 3.0f;
    [reviewTextView becomeFirstResponder];
    
    rateSlider.value = 5.0f;
    
    isIPhone
    {
        [rateLbl setFont:[UIFont fontWithName:@"MuseoSansRounded-700" size:12.0f]];
        [reviewCharCount setFont:[UIFont fontWithName:@"MuseoSansRounded-700" size:12.0f]];
    }
    else
    {
        [rateLbl setFont:[UIFont fontWithName:@"MuseoSansRounded-700" size:16.0f]];
        [reviewCharCount setFont:[UIFont fontWithName:@"MuseoSansRounded-700" size:16.0f]];
    }
}

-(void)leftBarButtonClicked:(id)sender {
    isIPhone {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)rightBarButtonClicked:(id)sender {
    
    if (reviewTextView.text.length == 0 && rateSlider.value == 0.0) {
        return;
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    NSLog(@"rate: %.f, review %@",rateSlider.value,reviewTextView.text);
    CommentReview *cr = [[CommentReview alloc] initWithManagedObjectContext:appDelegate.managedObjectContext];
    
    [cr addReview:reviewTextView.text andRating:rateSlider.value toContent:@"0" andCompletionHandler:^(id response, NSError *error) {
        if (error) {
            [UIAlertView showAlertWithError:error];
            return;
        } else {
            rateSlider.value = 5;
            reviewTextView.text = @"";
        }
    }];
}

-(IBAction)rateSliderUpdated:(UISlider *)sender {
    sender.value = round(sender.value);
    rateLbl.text = [NSString stringWithFormat:@"rate: %.f",sender.value];
}

#pragma mark - textView Delegate

-(void)textViewDidBeginEditing:(UITextView *)textView {
    @try {
        [self touchesBegan:nil withEvent:nil];
        int len = 140 - textView.text.length;
        reviewCharCount.text= [NSString stringWithFormat:@"%d | %d remaining", textView.text.length,len];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}
- (void)textViewDidChange:(UITextView *) textView  {
    
    @try {
#if DEBUG
        NSLog(@"entered text is:%@",textView.text);
#endif
        int len = 140 - textView.text.length;
        // textViewNetworkStr = textView.text;
        reviewCharCount.text= [NSString stringWithFormat:@"%d | %d remaining", textView.text.length,len];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    @try {
        // Don't allow input beyond the char limit, other then backspace and cut
        int len = 140 - textView.text.length;
        if (len <= 0 && ![text isEqualToString:@""])
            return NO;
        
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}

//For iOS 6
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    } else {
        return NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
