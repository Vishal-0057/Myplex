//
//  UIAlertView+Blocks.h
//  Myplex
//
//  Created by Igor Ostriz on 1/29/12.
//  Copyright (c) 2012 igor.ostriz@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^CancelBlock)();
typedef void (^DismissBlock)(int buttonIndex);

@interface UIAlertView (Block) <UIAlertViewDelegate>



+ (void) alertViewWithTitle:(NSString *)title message:(NSString *)message
                         cancelBlock:(CancelBlock)cancelBlock
                        dismissBlock:(DismissBlock)dismissBlock
                   cancelButtonTitle:(NSString *)cancelButtonTitle
                  otherButtonsTitles:(NSString *)otherButtonsTitles,... NS_REQUIRES_NIL_TERMINATION;

+ (void) alertViewWithTitle:(NSString *)title message:(NSString *)message;
+ (void) alertViewWithTitle:(NSString *)title message:(NSString *)message onExit:(void(^)())block;

@end
