//
//  ExtrasCell.m
//  Transitions
//
//  Created by Igor Ostriz on 10/9/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "ExtrasCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ExtrasCell ()

@property (nonatomic, readwrite) UIImageView *imageView;

@end

@implementation ExtrasCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
        
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 3.0f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 5.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.5f;
        
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        [self.contentView addSubview:self.imageView];

    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
}

@end
