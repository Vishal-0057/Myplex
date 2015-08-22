//
//  CardDetailsBlock1ViewController.h
//  Myplex
//
//  Created by Igor Ostriz on 10/22/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardDetailsBlock1ViewController : UIViewController

@property (nonatomic) Content *content;
@property (nonatomic) NSInteger cardBrowseType;
@property (nonatomic) id delegate;

-(void)verifyPurchaseAndPlay:(NSString *)title;

@end
