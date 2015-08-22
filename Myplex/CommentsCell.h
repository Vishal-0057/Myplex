//
//  CommentsCell.h
//  Myplex
//
//  Created by Igor Ostriz on 25/10/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic) id commentOrReview;

+ (CGFloat)totalHeightForData:(id)commentOrReview;

@end
