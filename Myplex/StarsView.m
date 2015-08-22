//
//  StarsView.m
//  Myplex
//
//  Created by Igor Ostriz on 9/2/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "StarsView.h"


static CGFloat starW = 1/6.;
static CGFloat spcW = 1/24.;

@interface StarsView ()

@property (nonatomic) CALayer *tintLayer;

@end

@implementation StarsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    
    CALayer *background = [CALayer layer];
    background.contents = (__bridge id)([UIImage imageNamed:@"stars-bg"].CGImage);
    background.frame = self.bounds;
    [self.layer addSublayer:background];
    
    _tintLayer = [CALayer layer];
    _tintLayer.frame = CGRectMake(0, 0, 0, self.bounds.size.height);
    _tintLayer.backgroundColor = [UIColor colorWithRed:200.0/255. green:16.0/255. blue:26.0/255. alpha:1].CGColor;
    [self.layer addSublayer:_tintLayer];
    
    CALayer* starMask = [CALayer layer];
    starMask.contents = (__bridge id)([UIImage imageNamed:@"stars-mask"].CGImage);
    starMask.frame = self.bounds;
    
    self.tintLayer.mask = starMask;
    
    [self drawRating];
}

- (id)initWithFrame:(CGRect)frame andRating:(int)rating animated:(BOOL)animated
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _userRating = rating;
        _animated = animated;
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


- (void)setUserRating:(CGFloat)userRating
{
    if (userRating == _userRating) {
        return;
    }
    _userRating = userRating;
    [self drawRating];
}

- (void)drawRating
{
    void(^blk)() = ^{
        
        CGFloat correction = floor(self.userRating) * spcW;
        CGFloat w = (self.userRating * starW + correction) * self.bounds.size.width;
        self.tintLayer.frame = CGRectMake(0, 0, w, self.frame.size.height);
    };
    
    if (self.animated) {
        [UIView animateWithDuration:0.5 animations:^{
            blk();
        }];
    }
    else {
        blk();
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.allowEdit)// && CGRectContainsPoint(self.bounds, [[[touches allObjects]lastObject] locationInView:self]))
    {
        CGFloat x = [[[touches allObjects] lastObject] locationInView:self].x;
        x = MAX(x, 0);
        x = MIN(self.bounds.size.width, x);
        
        CGFloat c = floor(x / ((starW + spcW) * self.bounds.size.width));
        CGFloat cx = c * (starW+spcW)*self.bounds.size.width;
        self.userRating = c + (x-cx) / (starW * self.bounds.size.width);
    }
}




@end
