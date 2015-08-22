//
//  MenuButton.m
//  Myplex
//
//  Created by Igor Ostriz on 11/12/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "MenuButton.h"
#import "MenuListViewController.h"
#import "UIView+Utils.h"


static CGFloat triangleWidth = 8;
static CGFloat triangleOffsetY = 3;
static CGFloat triangleOffsetX = 2;

@implementation MenuButton
{
    CGRect _maxFrame;
    UILabel *_label, *_subLabel;
}


- (id)initWithMaxFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}


- (void)initialize
{
    _maxFrame = self.frame;
    self.backgroundColor = [UIColor clearColor];
    
    CGRect f = self.frame;
    //f.size.height = self.frame.size.height - 20;
    _label = [[UILabel alloc] initWithFrame:f];
    [_label setFont:[UIFont fontWithName:@"Roboto-Regular" size:20]];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = [UIColor whiteColor];
    _label.backgroundColor = [UIColor clearColor];
    _label.minimumScaleFactor = 0.5;
    [self addSubview:_label];
    
    //f = _label.frame;
    //f.origin.y = CGRectGetMaxY(_label.frame);
    
    _subLabel = [[UILabel alloc] initWithFrame:f];
    [_subLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:11]];
    _subLabel.textAlignment = NSTextAlignmentCenter;
    _subLabel.textColor = [UIColor colorWithWhite:0.95 alpha:95];
    _subLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_subLabel];
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
}


- (void)setSizing
{
    //[_label sizeToFit];
    //[_subLabel sizeToFit];
    
    CGFloat maxW = MAX(_label.bounds.size.width+triangleWidth, _subLabel.bounds.size.width+triangleWidth);
    
    _subLabel.center = CGPointMake((int)(maxW/2)-triangleWidth, [_subLabel.text length] ? (int)(_label.bounds.size.height/2) + 3 : (int)(self.bounds.size.height/2) + 3);
    _label.center = CGPointMake((int)(maxW/2)-triangleWidth, [_subLabel.text length] ? self.bounds.size.height - (int)(_subLabel.bounds.size.height/2) - 13: (int)(_label.bounds.size.height/2 - 3));
    
    CGRect frame = self.frame;
    CGPoint c = self.center;
    frame.size.width = maxW;
    self.frame = frame;
    self.center = c;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    _label.text = title;
    [self setSizing];
//    [_label sizeToFit];
//    CGRect f = _label.frame;
//    
//    f.size.height = self.bounds.size.height;
//    if (f.size.width > _maxFrame.size.width - triangleOffsetX) {
//        f.size.width = _maxFrame.size.width - triangleOffsetX;
//    }
//    _label.frame = f;
//    
//    CGPoint c = self.center;
//    f = self.frame;
//    f.size.width = _label.bounds.size.width + triangleOffsetX;
//    self.frame = f;
//    self.center = c;
    
    [self setNeedsDisplay];
}


- (void)setSubTitle:(NSString *)subTitle
{
    _subTitle = subTitle;
    _subLabel.text = subTitle;
    [self setSizing];
    
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath* polygonPath = [UIBezierPath bezierPath];
    
    CGFloat minX = (CGRectGetMaxX(_subLabel.frame)/2) - triangleOffsetX;
    CGFloat maxX = (CGRectGetMaxX(_subLabel.frame)/2) + triangleWidth - triangleOffsetX;
    CGFloat minY = CGRectGetMaxY(_subLabel.frame) - triangleWidth ;//- triangleOffsetY;
    CGFloat maxY = CGRectGetMaxY(_subLabel.frame) - triangleOffsetY;
    CGFloat midY = (minY + maxY)/2 + 1;
    CGFloat midX = (minX + maxX)/2;
    
    [polygonPath moveToPoint: CGPointMake(minX, minY)];
    [polygonPath addLineToPoint: CGPointMake(maxX, minY)];
    [polygonPath addLineToPoint: CGPointMake(midX, midY)];
    [polygonPath addLineToPoint: CGPointMake(minX, minY)];
    [polygonPath closePath];
    [[UIColor whiteColor] setFill];
    [polygonPath fill];
    [[UIColor colorWithWhite:0 alpha:0.1] setStroke];
    polygonPath.lineWidth = 1;
    [polygonPath stroke];
}


- (void)tap:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(loadItems)]) {
      self.items =  [self.delegate loadItems];
    }
    
    MenuListViewController *ml = [MenuListViewController new];
    ml.items = self.items;
    ml.topMargin = [self convertPoint:CGPointMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame)) toView:[UIApplication sharedApplication].keyWindow].y;
    ml.leftMargin = 0;
    [ml setOnSelection:^(MenuListViewController *menuListControl, NSInteger index) {
        if ([self.delegate respondsToSelector:@selector(menuButton:didSelectItem:onIndex:)]) {
            [self.delegate menuButton:self didSelectItem:self.items[index] onIndex:index];
        }
        [menuListControl closeAnimated:YES];
    }];
    
    ml.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.window.rootViewController presentViewController:ml animated:YES completion:nil];
    
    isIPhone {} else {
        CGRect superViewFrame = [self.delegate getFrame];
        superViewFrame.size.height = 768;
        ml.topMargin = CGRectGetMaxY(self.frame) + 20;
        [ml setFrame:superViewFrame];
    }
}

@end
