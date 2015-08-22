//
//  RelatedSectionTitleReusableView.m
//  Transitions
//
//  Created by Igor Ostriz on 10/17/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "TitleReusableView.h"

@implementation TitleReusableView
{
    UILabel *_titleLabel, *_subTitleLabel;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height/2.)];
//        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _titleLabel.textColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
        _titleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        _titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height/2., frame.size.width, frame.size.height/2.)];
//        _subTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _subTitleLabel.backgroundColor = [UIColor clearColor];
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
        _subTitleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _subTitleLabel.textColor = [UIColor colorWithWhite:.3f alpha:1.0f];
        _subTitleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        _subTitleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        [self addSubview:_titleLabel];
        [self addSubview:_subTitleLabel];
    }
    return self;
}


- (void)prepareForReuse
{
    [super prepareForReuse];
//    _titleLabel.text = nil;
//    _subTitleLabel.text = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect f = self.bounds;
    f.size.height /= 2;
    _titleLabel.frame = f;
    
    f.origin.y = f.size.height;
    _subTitleLabel.frame = f;
    
}

- (void)setTitleString:(NSString *)titleString
{
    _titleString = titleString;
    _titleLabel.text = _titleString;
    [self setNeedsDisplay];
}

- (void)setSubtitleString:(NSString *)subTitleString
{
    if ([_subTitleString isEqualToString:subTitleString]) {
        return;
    }
    _subTitleString = subTitleString;
    _subTitleLabel.text = _subTitleString;
    [self setNeedsDisplay];
}


//- (void)alignCenter:(BOOL)align
//{
//    _titleLabel.textAlignment = align ? NSTextAlignmentCenter : NSTextAlignmentLeft;
//    _subTitleLabel.textAlignment = align ? NSTextAlignmentCenter : NSTextAlignmentLeft;
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
