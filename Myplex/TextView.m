//
//  TextView.m
//  Myplex
//
//  Created by Igor Ostriz on 5/25/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TextView.h"



@implementation TextView
{
	BOOL _shouldDrawPlaceholder;
}


#pragma mark - Accessors

- (void)setText:(NSString *)string
{
	[super setText:string];
	[self _updateShouldDrawPlaceholder];
}


- (void)setPlaceholder:(NSString *)string
{
	if ([string isEqual:_placeholder]) {
		return;
	}
	
	_placeholder = string;
	[self _updateShouldDrawPlaceholder];
}


#pragma mark - NSObject

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}


#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		[self _initialize];
	}
	return self;
}


- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		[self _initialize];
	}
	return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self _initialize];
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	
	if (_shouldDrawPlaceholder) {
		[_placeholderTextColor set];
        // TODO: fiddle with attributes
		[_placeholder drawInRect:CGRectMake(8.0f, 8.0f, self.frame.size.width - 16.0f, self.frame.size.height - 16.0f) withFont:self.font];
	}
}

- (BOOL)canBecomeFirstResponder
{
    return _enabled;
}


- (void)setFrame:(CGRect)frame
{
    static CGFloat initialWidth = 0;
    
    if (initialWidth == 0 || !self.fixedWidth)
        initialWidth = frame.size.width;
    
    frame.size.width = initialWidth;
    [super setFrame:frame];
}


#pragma mark - Private

- (void)_initialize
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textChanged:) name:UITextViewTextDidChangeNotification object:self];
	
	self.placeholderTextColor = [UIColor colorWithWhite:0.702f alpha:1.0f];
	_shouldDrawPlaceholder = NO;
    
    self.layer.cornerRadius = 5;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1;

}


- (void)_updateShouldDrawPlaceholder
{
	BOOL prev = _shouldDrawPlaceholder;
	_shouldDrawPlaceholder = self.placeholder && self.placeholderTextColor && self.text.length == 0;
	
	if (prev != _shouldDrawPlaceholder) {
		[self setNeedsDisplay];
	}
}


- (void)_textChanged:(NSNotification *)notification
{
	[self _updateShouldDrawPlaceholder];
}

@end