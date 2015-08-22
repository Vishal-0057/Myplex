//
//  K4SelectorCell.h
//  Konnect4

#import <UIKit/UIKit.h>

@interface MenuSelectorCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *imgOk;
@property (retain, nonatomic) IBOutlet UILabel *labelName;

- (void)check;
- (void)uncheck;

@end
