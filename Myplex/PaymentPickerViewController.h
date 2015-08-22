//
//  PaymentPickerViewController.h
//  Myplex
//
//  Created by Igor Ostriz on 19/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Content.h"

@interface PaymentPickerViewController : UIViewController

@property (nonatomic) Content *content;

@end


@interface PaymentPickerTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic) CGRect sinkRect;


@end