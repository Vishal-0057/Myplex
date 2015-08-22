//
//  FilterTableViewController.h
//  PKCollapsingTableViewSections
//
//  Created by shiva on 8/23/13.
//  Copyright (c) 2013 phil koulen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterTableViewController : UITableViewController {
    NSArray *filterItems;
    id delegate;
    
}

@property (nonatomic,retain) id delegate;
@property (nonatomic, retain) NSArray *filterItems;

- (id)initWithStyle:(UITableViewStyle)style filterItems:(NSArray *)filterItems_;

@end
