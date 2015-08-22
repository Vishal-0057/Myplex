//
//  ToastMessageView.h
//  Myplex
//
//  Created by shiva on 11/13/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToastMessageView : UIView

- (void)showToastMessage:(NSString *)message;
-(void)showForegroundNotificationBanner:(NSString*)message;

@end
