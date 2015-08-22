//
//  UIAlertView+Blocks.m
//  Myplex
//
//  Created by Igor Ostriz on 1/29/12.
//  Copyright (c) 2012 igor.ostriz@gmail.com. All rights reserved.
//

#import "UIAlertView+Blocks.h"



static CancelBlock __cancel;
static DismissBlock __dismiss;

@implementation UIAlertView (Block)




+ (void) alertViewWithTitle:(NSString *)title message:(NSString *)message
                cancelBlock:(CancelBlock)cancelBlock
               dismissBlock:(DismissBlock)dismissBlock
          cancelButtonTitle:(NSString *)cancelButtonTitle
         otherButtonsTitles:(NSString *)otherButtonsTitles,...
{
    __cancel = cancelBlock;
    __dismiss = dismissBlock;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:[self class]
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil
                          ];
    NSString *eachObject;
    va_list argumentList;
    if (otherButtonsTitles)
    {
        
        [alert addButtonWithTitle:otherButtonsTitles];
        va_start(argumentList, otherButtonsTitles);             // Start scanning for arguments after firstObject.
        while ((eachObject = va_arg(argumentList, NSString*)))  // As many times as we can get an argument of type "id"
            [alert addButtonWithTitle:eachObject];              // that isn't nil, add it to self's contents.
        va_end(argumentList);
    }
   
    [alert show];
}

+ (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView cancelButtonIndex] == buttonIndex) {
        if (__cancel) 
            __cancel();
    } else {
        if (__dismiss)
            __dismiss(buttonIndex-1);
    }
}


+ (void) alertViewWithTitle:(NSString *)title message:(NSString *)message
{
    [self alertViewWithTitle:title message:message onExit:nil];
}

+ (void)alertViewWithTitle:(NSString *)title message:(NSString *)message onExit:(void (^)())block
{
    [self alertViewWithTitle:title message:message cancelBlock:^{
        if (block) {
            block();
        }
    } dismissBlock:^(int buttonIndex) {
        if (block) {
            block();
        }
    } cancelButtonTitle:@"OK" otherButtonsTitles: nil];
}
@end
