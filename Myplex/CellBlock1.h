//
//  CellBlock1.h
//  Myplex
//
//  Created by Igor Ostriz on 9/19/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>


static NSString *kNotificationCellLayoutChanged = @"myplex.layoutChanged";

@class Content;
@interface CellBlock1 : UICollectionViewCell <UITableViewDataSource, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pgLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;
@property (weak, nonatomic) IBOutlet UIButton *priceButton;
@property (weak, nonatomic) IBOutlet UITableView *creditsTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *extrasCollectionView;


@property (nonatomic) NSString *briefDescription;
@property (nonatomic) NSString *description;
@property (nonatomic) NSArray *casts;


+ (CGSize)size;
- (CGSize)size;
- (void)setLayoutWithAnimation:(BOOL)animate;
- (void)setViewWithContent:(Content *)content;

@end
