//
//  K4ListViewController.h
//  StalkDocs
//
//  Created by Igor Ostriz on 4/8/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuListViewController : UIViewController

@property(nonatomic, strong) NSArray *items;
@property(nonatomic, assign) NSInteger selectedIndex;
@property(nonatomic, assign) CGFloat topMargin;
@property(nonatomic, assign) CGFloat leftMargin;
@property(nonatomic, readonly) UITableView *menuTableView;
@property(nonatomic, assign) BOOL dropMenu;

- (void)setOnSelection:(void (^)(MenuListViewController *, NSInteger))selectionHandler;
- (void)closeAnimated:(BOOL)animated;
-(void)setFrame:(CGRect)frame;

@end
