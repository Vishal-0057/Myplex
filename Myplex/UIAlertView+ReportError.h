//
//  UIAlertView+ReportError.h
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorCodes.h"
#import "NSError+Utils.h"

@interface UIAlertView (ReportError)

+ (void)showAlertWithError:(NSError *)error;

@end
