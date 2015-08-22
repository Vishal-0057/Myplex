//
//  PaymentPickerViewController.m
//  Myplex
//
//  Created by Igor Ostriz on 19/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CertifiedRating.h"
#import "PaymentPickerViewController.h"
#import "PaymentPickerAnimatedTransitioning.h"
#import "StarsView.h"
#import "PriceDetail.h"
#import "CustomButton.h"
#import "RageIAPHelper.h"
#import "Subscribe.h"
#import "AppDelegate.h"
#import "UIAlertView+ReportError.h"
#import "UIAlertView+Blocks.h"
#import "NSNotificationCenter+Utils.h"

#import <CoreText/CoreText.h>
#import "NSManagedObject+Utils.h"
#import "Notifications.h"

@interface PaymentPickerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet StarsView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *paymentView;
@end

@implementation PaymentPickerViewController {
    AppDelegate *appDelegate;
}


- (void)initialize
{
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.paymentView.layer.cornerRadius = 5.0f;
    
    UIView *button = [self.view viewWithTag:101];
    button.layer.cornerRadius = 5;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = 2;
}


- (void)setContent:(Content *)content
{
    
    _content = content;
//    self.titleLabel.text = [_content.title lowercaseString];
    self.titleLabel.text = _content.title;
    self.ratingLabel.text = @"";
    if ([_content.certifiedRatings count]) {
//        self.ratingLabel.text = [[[_content.certifiedRatings anyObject] rating]lowercaseString];
        self.ratingLabel.text = [[_content.certifiedRatings anyObject] rating];
    }
    self.durationLabel.text = _content.duration;
    self.dateLabel.text = _content.releaseDate;
    self.ratingView.userRating = [_content.averageRating floatValue];

    NSArray *packages = [_content.packages allObjects];
    for (int i = 0; i < packages.count; i++) {
        
        Package *package = [packages objectAtIndex:i];
        NSLog(@"PriceDetails %@",package.priceDetails);
        NSSet *inappPrice = [package.priceDetails filteredSetUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"paymentChannel == 'INAPP'"]]];
        if (inappPrice.count > 0) {
            [self showPackage:package withPrice:[inappPrice anyObject] forIndex:i];
        }
    }
    
    self.descriptionTextView.text = _content.baseDescription;
}

-(void)showPackage:(Package *)package withPrice:(PriceDetail *)price forIndex:(int)index {
    
    CGFloat packageButtonHeight = 30;

    CGRect frame = CGRectMake(self.ratingLabel.frame.origin.x, CGRectGetMaxY(self.ratingLabel.frame) + (index * (packageButtonHeight + 5)) + 10, 150,packageButtonHeight);
    
//    NSString *packageInfo = [NSString stringWithFormat:@"%@ %@ ₹ %@",[package.commercialModel lowercaseString],[package.contentType lowercaseString], price.price];
     NSString *packageInfo = [NSString stringWithFormat:@"%@ %@ ₹ %@",package.commercialModel,package.contentType, price.price];
    /**(1)** Build the NSAttributedString *******/
    
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:packageInfo];
    NSInteger _stringLength = [packageInfo length];
    
    UIColor *_red = [UIColor redColor];
    UIColor *_white = [UIColor whiteColor];
    UIFont *font=[UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
    [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, _stringLength)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    if (/*[self isNotNull:[package.commercialModel lowercaseString]]*/[self isNotNull:package.commercialModel]) {
//        [attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:[packageInfo rangeOfString:[package.commercialModel lowercaseString]]];
        [attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:[packageInfo rangeOfString:package.commercialModel]];
    }
    
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    if (/*[self isNotNull:[package.contentType lowercaseString]]*/[self isNotNull:package.contentType]) {
//        [attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:[packageInfo rangeOfString:[package.contentType lowercaseString]]];
        [attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:[packageInfo rangeOfString:package.contentType]];
    }
    
    [paragraphStyle setAlignment:NSTextAlignmentRight];
    if ([self isNotNull:[NSString stringWithFormat:@"₹ %@",price.price]]) {
        [attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:[packageInfo rangeOfString:[NSString stringWithFormat:@"₹ %@",price.price]]];
    }

    [attString addAttribute:NSForegroundColorAttributeName value:_white range:NSMakeRange(0, _stringLength)];
    
//    [attString addAttribute:NSForegroundColorAttributeName value:_red range:[packageInfo rangeOfString:[package.contentType lowercaseString]]];
    [attString addAttribute:NSForegroundColorAttributeName value:_red range:[packageInfo rangeOfString:package.contentType]];
    
    CustomButton *button = [CustomButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.layer.cornerRadius = 5;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = 2;
    [button setAttributedTitle:attString forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buy:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = index;
    button.buttonId = package.packageId;
    //button.cotentId = package.contentId;
    button.titleLabel.numberOfLines = 2;
    [self.paymentView addSubview:button];
}

-(void)buy:(CustomButton *)sender {
    
//    if (![appDelegate checkAuthentication]) {
//        
//    }
    
    NSString *packageId = sender.buttonId;
    
    Package *package = (Package *)[Package fetchFirstObjectHaving:packageId forKey:@"packageId" inManagedObjectContext:appDelegate.managedObjectContext];
    
#if DEBUG
    NSLog(@"buying %@ and package info: %@",packageId,package);
#endif
    
    {
        PAY_COMMERCIAL_TYPES payComericaltypes;
        if ([package.commercialModel isEqualToString:@"rental"]) {
            payComericaltypes = Rental;
        } else {
            payComericaltypes = Buy;
        }
        [Analytics logEvent:EVENT_PAY parameters:@{PAY_STATUS_PROPERTY: PAY_CONTENT_STATUS_TYPES_STRING(PayContentClicked),PAY_PACKAGE_PURCHASE_STATUS:PAY_PACKAGE_PURCHASE_STATUS_STRING(InProgress),PAY_PACKAGE_ID:packageId,PAY_PACKAGE_NAME:package.packageName?:@"",PAY_PACKAGE_CHANNEL:PAY_COMMERCIAL_TYPES_STRING(payComericaltypes)} timed:YES];
        
        [AppDelegate showActivityIndicatorWithText:@"loading... \nplease wait."];
        //start buying a package.
        [[RageIAPHelper sharedInstance]buyPackage:packageId withCompletionHandler:^(BOOL success, SKPaymentTransaction *transaction,NSError *error) {
            [AppDelegate removeActivityIndicator];
            if (success) {
                
                [self close:nil];
                
                if ([appDelegate isUserAuthenticated]) {
                    [UIAlertView alertViewWithTitle:kAppTitle message:[NSString stringWithFormat:kPurchaseSuccessfulMessage,package.packageName]];
                } else if (![appDelegate isUserAuthenticated]) {
                    [UIAlertView alertViewWithTitle:@"authentication" message:[NSString stringWithFormat:kPurchaseSuccessMessageWhenNotLoggedIn,package.packageName] cancelBlock:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSignedOut object:nil];
                    } dismissBlock:^(int buttonIndex) {
                        
                    } cancelButtonTitle:@"login" otherButtonsTitles:@"continue", nil];
                }
                
                [Analytics logEvent:EVENT_PAY parameters:@{PAY_STATUS_PROPERTY: PAY_CONTENT_STATUS_TYPES_STRING(PayContentSuccessAtAppStore),PAY_PACKAGE_PURCHASE_STATUS:PAY_PACKAGE_PURCHASE_STATUS_STRING(InProgress),PAY_PACKAGE_ID:packageId,PAY_PACKAGE_NAME:package.packageName?:@"",PAY_PACKAGE_CHANNEL:PAY_COMMERCIAL_TYPES_STRING(payComericaltypes)} timed:YES];
                
            } else {
                [Analytics logEvent:EVENT_PAY parameters:@{PAY_STATUS_PROPERTY: PAY_CONTENT_STATUS_TYPES_STRING(PayContentFailureAtAppStore),PAY_PACKAGE_PURCHASE_STATUS:PAY_PACKAGE_PURCHASE_STATUS_STRING(InProgress),PAY_PACKAGE_ID:packageId,PAY_PACKAGE_NAME:package.packageName?:@"",PAY_PACKAGE_CHANNEL:PAY_COMMERCIAL_TYPES_STRING(payComericaltypes)} timed:YES];
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAppTitle message:[[error userInfo] objectForKey:NSLocalizedDescriptionKey]?:[error userInfo][@"error"] delegate: nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    
                    [alertView show];
                    //[UIAlertView showAlertWithError:error];
                }
            }
        }];
    }
}

- (IBAction)close:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        // do some savings if needed here
//        [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationPurchaseSuccess object:nil];
    }];
}

#pragma mark - autoraotation support

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    isIPhone
        return UIInterfaceOrientationMaskPortrait;
    
    return UIInterfaceOrientationMaskLandscape;
}

-(UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    isIPhone
        return UIInterfaceOrientationPortrait;
    
    return UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
    
}

@end



@implementation PaymentPickerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    PaymentPickerAnimatedTransitioning *ret = [PaymentPickerAnimatedTransitioning new];
    ret.sinkRect = self.sinkRect;
    return ret;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    PaymentPickerAnimatedTransitioning *ret = [PaymentPickerAnimatedTransitioning new];
    ret.sinkRect = self.sinkRect;
    ret.reverse = YES;
    return ret;
}
@end