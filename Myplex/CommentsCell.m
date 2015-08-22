//
//  CommentsCell.m
//  Myplex
//
//  Created by Igor Ostriz on 25/10/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "Comment.h"
#import "CommentsCell.h"
#import "NSDate+ServerDateFormat.h"
#import "UIColor+Hex.h"
#import "UserReview.h"



@interface CommentsCell()

@property (weak, nonatomic) IBOutlet UIView *placeholderView;


@end


@implementation CommentsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIView *v = [self viewWithTag:101];
        v.layer.borderColor = UIColorFromRGB(0x767676).CGColor;
        v.layer.borderWidth = 0.5;
        v.layer.cornerRadius = 5;
        //self.placeholderView = v;
        self.placeholderView.backgroundColor = [UIColor redColor];
//        v.layer.shouldRasterize = YES;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    self.timeLabel.text = nil;
    self.nameLabel.text = nil;
    self.textView.text = nil;
}

- (void)setCommentOrReview:(id)commentOrReview
{
    NSString *s = @"";
    NSDate *d;
    NSString *name = @"";
    if ([commentOrReview isKindOfClass:[Comment class]]) {
        s = [commentOrReview comment];
        d = ((Comment *)commentOrReview).timestamp;
        name = [commentOrReview userName];
    }
    else if ([commentOrReview isKindOfClass:[UserReview class]]) {
        s = [commentOrReview review];
        d = ((UserReview *)commentOrReview).timestamp;
        name = [commentOrReview userName];
    }
    else if ([commentOrReview isKindOfClass:[NSDictionary class]]) {
        s = commentOrReview[@"comment"]?:commentOrReview[@"review"];
        d = [NSDate formatStringToDate:commentOrReview[@"timestamp"]];
        name = commentOrReview[@"username"]?:commentOrReview[@"name"];
    }
    if ([self isNotNull:s]) {
        self.textView.text = s;
    }
    CGRect f = self.textView.frame;
    f.size.height = [CommentsCell heightForTextView:s];
    self.textView.frame = f;
//    CGFloat pVHeight = f.size.height + 24 + 8;  // 24 is textView y, 8 is bottom padding
//    f = self.placeholderView.frame;
//    f.size.height = pVHeight;
//    self.placeholderView.frame = CGRectIntegral(f);
    
    self.nameLabel.text = name;
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    self.timeLabel.text = [formatter stringFromDate:d];
    
//    [self.placeholderView setFrame:CGRectIntegral(self.placeholderView.frame)];
//    [self.textView setFrame:CGRectIntegral(self.textView.frame)];
//    [self.nameLabel setFrame:CGRectIntegral(self.nameLabel.frame)];
//    [self.timeLabel setFrame:CGRectIntegral(self.timeLabel.frame)];

}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    //// Color Declarations
    UIColor* color3 = [UIColor colorWithRed: 0.706 green: 0.706 blue: 0.71 alpha: 1];
    
    //// Abstracted Attributes
    CGRect ovalRect = CGRectMake(1, 0.5, 12, 12);
    CGRect rectangleRect = CGRectMake(6.5, 12.5, 1, rect.size.height - ovalRect.size.height);
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
    [[UIColor clearColor] setFill];
    [ovalPath fill];
    [color3 setStroke];
    ovalPath.lineWidth = 1.5;
    [ovalPath stroke];
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect:rectangleRect];
    [color3 setFill];
    [rectanglePath fill];
    [color3 setStroke];
    rectanglePath.lineWidth = 1;
    [rectanglePath stroke];
}



+ (CGFloat)heightForTextView:(NSString *)s
{
    CGRect r;
    if ([self isNotNull:s]) {
        r = [s boundingRectWithSize:CGSizeMake(222, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Roboto-Light" size:13]} context:nil];
    }
    return MAX(ceilf(r.size.height), 18);
}


+ (CGFloat)totalHeightForData:(id)commentOrReview;
{
    CGFloat y = 24;

    NSString *s = @"";
    if ([commentOrReview isKindOfClass:[Comment class]]) {
        s = [commentOrReview comment];
    }
    else if ([commentOrReview isKindOfClass:[UserReview class]]) {
        s = [commentOrReview review];
    }
    else if ([commentOrReview isKindOfClass:[NSDictionary class]]) {
        s = commentOrReview[@"comment"]?:commentOrReview[@"review"];
    }
    CGFloat textViewHeight = [self heightForTextView:s];
    y += textViewHeight + 8 + 8; // 8 offsets for placeholderView and contentView bottom each
    
    return y;
}

@end
