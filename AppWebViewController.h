//
//  AppWebViewController.h
//  Myplex
//
//  Created by shiva on 12/16/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WebViewDelegate;
@interface AppWebViewController : UIViewController<UIWebViewDelegate> {

    IBOutlet UIWebView *webView;
    IBOutlet UIActivityIndicatorView *activityIndicatorView;
}

@property (nonatomic,retain) NSString *webLink;

@property (nonatomic, weak) id<WebViewDelegate> delegate;

-(void)setNavigationbar;

@end

@protocol WebViewDelegate <NSObject>

- (void)pressedDoneWithAppWebViewController:(AppWebViewController *)appWebViewController;
@optional
- (IBAction)done:(UIButton *)sender;
- (IBAction)cancel:(UIButton *)sender;

@end