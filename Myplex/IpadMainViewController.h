//
//  IpadMainViewController.h
//  Myplex
//
//  Created by apalya technologies on 2/12/14.
//  Copyright (c) 2014 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IpadMainViewController : UIViewController

@property (assign, nonatomic) BOOL searchClicked;
@property (strong, nonatomic) IBOutlet UIView *searchContainerView;

-(void)toggleColorForButton:(UIButton *)btn;
-(void) searchViewTransition;
-(id)getDelegate;

@end
