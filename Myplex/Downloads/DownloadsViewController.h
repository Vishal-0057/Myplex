//
//  DownloadsViewController.h
//  Myplex
//
//  Created by shiva on 10/3/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {

    IBOutlet UITableView *downloadsTableView;
}

@property(nonatomic, strong)NSMutableArray *downloadedVideos;
@property (nonatomic, strong)id playerDelegate;

-(void)showMenu:(id)sender;
-(void) closePageSheetWithViewController;

@end
