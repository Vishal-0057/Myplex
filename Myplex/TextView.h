//
//  TextView.h
//  Myplex
//
//  Created by Igor Ostriz on 5/25/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 UITextView subclass that adds placeholder support like UITextField has.
 */
@interface TextView : UITextView

/**
 The string that is displayed when there is no other text in the text view.
 The default value is `nil`.
 */
@property (nonatomic) NSString *placeholder;

/**
 The color of the placeholder.
 The default is `[UIColor lightGrayColor]`.
 */
@property (nonatomic) UIColor *placeholderTextColor;



@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL fixedWidth;

@end

