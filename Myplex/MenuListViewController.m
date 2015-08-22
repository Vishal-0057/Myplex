//
//  K4ListViewController.m
//  StalkDocs
//
//  Created by Igor Ostriz on 4/8/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MenuListViewController.h"
#import "MenuSelectorCell.h"
#import "UIView+ImageSnapshot.h"
#import "UIImage+Additional.h"
#import "UIImage+Utils.h"

#define kCellHeight 44.0

@interface MenuListViewController () <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, copy)void (^onCompletion)(MenuListViewController *, NSInteger);

@end

@implementation MenuListViewController
{
    NSArray *_items;
    NSInteger _selectedIndex;
    UITableView *_tableViewList;    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _selectedIndex = -1;
    _topMargin = 0;
    _leftMargin = 0;
}

- (UITableView *)menuTableView
{
    return _tableViewList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isIPhone
        [self makeView];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_selectedIndex >= 0)
        [_tableViewList selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] animated:animated scrollPosition:UITableViewScrollPositionNone];
    [UIView animateWithDuration:0.2f animations:^{
        [self layoutTableViewOnShow:YES onOrientation:self.interfaceOrientation];
    }];
}

-(void)setFrame:(CGRect)frame {
    self.view.frame = frame;
    [self makeView];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self layoutTableViewOnShow:YES onOrientation:toInterfaceOrientation];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation == self.interfaceOrientation;
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Inherited

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [UIView animateWithDuration:0.2f animations:^{
        [self layoutTableViewOnShow:NO onOrientation:self.interfaceOrientation];
    } completion:^(BOOL finished){
        [super dismissViewControllerAnimated:flag completion:completion];
    }];
}

#pragma mark - Interface

- (void)closeAnimated:(BOOL)animated{
    [self dismissViewControllerAnimated:animated completion:NULL];
}

- (void)setOnSelection:(void (^)(MenuListViewController *, NSInteger))selectionHanler{
    self.onCompletion = selectionHanler;
}

#pragma mark - Make

- (void)makeView
{
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3f];
    CGRect r = self.view.bounds;
    r.origin.y = self.topMargin;
    r.size.height -= self.topMargin;
    
    isIPhone {
        UIView *blur = [[UIView alloc] initWithFrame:r];
        UIImage *background = [[UIApplication sharedApplication].keyWindow snapshotImage];
        background = [background cropToRectangle:r];
        UIColor *blurColor = [UIColor colorWithWhite:1.0 alpha:0.1];//[UIColor colorWithWhite:0.11 alpha:0.73];
        background = [background blurredImageWithRadius:5 tintColor:blurColor saturationDeltaFactor:1.8 maskImage:nil];
        blur.layer.contents = (__bridge id)([background CGImage]);
        [self.view addSubview:blur];
    }
    CGSize screenSize;
    isIPhone
        screenSize = UIScreen.mainScreen.applicationFrame.size;
    else
        screenSize = self.view.bounds.size;
    
    
    UIView *closeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    closeView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:closeView];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionClose)];
    [closeView addGestureRecognizer:tapRecognizer];
    
    _tableViewList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableViewList.backgroundColor = [UIColor clearColor];
    _tableViewList.separatorColor = [UIColor grayColor];
    _tableViewList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewList.delegate = self;
    _tableViewList.dataSource = self;
    [self layoutTableViewOnShow:NO onOrientation:self.interfaceOrientation];
      
    [self.view addSubview:_tableViewList];
}

- (void)layoutTableViewOnShow:(BOOL)onShow onOrientation:(UIInterfaceOrientation)orientation{
    CGSize screenSize = CGSizeZero;
    isIPhone
        screenSize = UIScreen.mainScreen.applicationFrame.size;
    else
        screenSize = self.view.bounds.size;
    
//    CGFloat contentHeight = [self contentHeight] + _tableViewList.tableFooterView.frame.size.height;
//    if (contentHeight + _tableViewList.frame.origin.y > self.view.bounds.size.height) {
//        CGFloat diff = contentHeight + _tableViewList.frame.origin.y - self.view.bounds.size.height;
//        NSUInteger n = diff / kCellHeight;
//        contentHeight -= kCellHeight * (n/*+1*/);
//    }
    
    CGFloat contentHeight = self.view.bounds.size.height - _tableViewList.frame.origin.y;
    
    if (onShow) {
        _tableViewList.frame = CGRectMake(_leftMargin, _topMargin, screenSize.width - 2*_leftMargin, contentHeight);
    }else{
        _tableViewList.frame = CGRectMake(_leftMargin, _topMargin, screenSize.width - 2*_leftMargin, 0);
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell1";
    MenuSelectorCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MenuSelectorCell" owner:self options:nil] objectAtIndex:0];
        cell.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
    }

    NSString *txt = [_items objectAtIndex:indexPath.row];
//    cell.labelName.text = txt.length ? [txt lowercaseString] : @"[unnamed]";
    cell.labelName.text = txt.length ? txt : @"[unnamed]";
    if (_selectedIndex == indexPath.row)
        [cell check];
    else
        [cell uncheck];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.onCompletion) {
        self.onCompletion(self, indexPath.row);
    }
}

#pragma mark - Private

- (CGFloat)contentHeight
{
    CGFloat height = [_items count]*kCellHeight;
    
    if (height < kCellHeight) {
        height = kCellHeight;
    }
    
    return height-1.0;
}

#pragma mark - Action

- (void)actionClose
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
