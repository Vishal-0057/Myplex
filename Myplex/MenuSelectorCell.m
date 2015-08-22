//
//  K4SelectorCell.m
//  Konnect4

#import "MenuSelectorCell.h"

@implementation MenuSelectorCell

- (void)awakeFromNib
{
    self.labelName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
}

- (void)check
{
    self.imgOk.hidden = NO;
}

- (void)uncheck
{
    self.imgOk.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected) {
        [self check];
    } else {
        [self uncheck];
    }
}

@end
