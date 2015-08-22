//
//  TimelineView.m
//  Transitions
//
//  Created by Igor Ostriz on 10/18/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "TimelineView.h"

@implementation TimelineView


+ (CGFloat)defaultWidth
{
    return 14.;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
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
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: ovalRect];
    [[UIColor clearColor] setFill];
    [ovalPath fill];
    [color3 setStroke];
    ovalPath.lineWidth = 1.5;
    [ovalPath stroke];
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: rectangleRect];
    [color3 setFill];
    [rectanglePath fill];
    [color3 setStroke];
    rectanglePath.lineWidth = 1;
    [rectanglePath stroke];
}


@end
