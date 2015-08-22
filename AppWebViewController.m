//
//  AppWebViewController.m
//  Myplex
//
//  Created by shiva on 12/16/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "AppWebViewController.h"
#import "UIAlertView+ReportError.h"
#import "MZFormSheetController.h"

@interface AppWebViewController ()

@end

@implementation AppWebViewController


@synthesize webLink;

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
    
    isIPhone {} else {
        
        [self setNavigationbar];
    }
    
    if (webLink && webView) {
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:webLink]]];
    }
}

-(void)setNavigationbar {
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:200.0f/255.0f green:16.0f/255.0f blue:26.0f/255.0f alpha:1.0f];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;   // iOS 7(x)
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"cancel" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonClicked:)];
    [leftBarButton setTitle:@"Back"];
    leftBarButton.tintColor = [UIColor whiteColor];
    [self.navigationItem setLeftBarButtonItem:leftBarButton];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.navigationController.navigationBar.hidden = NO;
    
    
}

-(void)leftBarButtonClicked:(id)sender {
    
    isIPhone {
        [self dismissFormSheetControllerAnimated:YES completionHandler:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    [activityIndicatorView startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [activityIndicatorView stopAnimating];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [activityIndicatorView stopAnimating];
    [UIAlertView showAlertWithError:error];
}

-(void)showCloseButton {
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(-15, -15, 30, 30);
    [closeButton setTitle:@"close" forState:UIControlStateNormal];
    [closeButton setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:closeButton];
    [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
