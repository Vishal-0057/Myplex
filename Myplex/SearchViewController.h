//
//  ViewController.h
//  Search
//
//  Created by shiva on 8/27/13.
//  Copyright (c) 2013 Apalya Technlologies Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterTableViewController.h"
#import "TITokenField.h"

@interface SearchViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    CGFloat rowHeight;
    FilterTableViewController *filterTable;
    UIButton *navTitleViewBtn;
    IBOutlet UITableView *searchTable;
    IBOutlet UISearchBar *searchBar;
    NSMutableArray *sectionTitleArray;
    NSArray *categories;
    UIProgressView *downloadProgressView;
    UIActivityIndicatorView *uiactivityIndicatorView;
}

-(void)selectedFilterItem:(NSString *)filterItem;
-(void)setDelegateWithViewController:(id)delegate;



@end
