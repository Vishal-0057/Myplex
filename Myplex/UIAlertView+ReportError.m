//
//  UIAlertView+ReportError.h
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "UIAlertView+ReportError.h"

@implementation UIAlertView (ReportError)

+ (void)showAlertWithError:(NSError *)error
{
	NSDictionary *userInfoDictionary = [error userInfo];
	NSString *errorMessage = [userInfoDictionary objectForKey: NSLocalizedDescriptionKey];
    
    if (errorMessage == nil) {
        errorMessage = userInfoDictionary[@"error"];
        if (errorMessage) {
            errorMessage = [errorMessage stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[errorMessage  substringToIndex:1] capitalizedString]];
        }
    }
	
	dispatch_async(dispatch_get_main_queue(), ^{
		UIAlertView *alertView = [[self alloc] initWithTitle: NSLocalizedString(@"There was a problem.", @"There was a problem.") message: NSLocalizedString(errorMessage, errorMessage) delegate: nil cancelButtonTitle: NSLocalizedString(@"Ok", @"Ok") otherButtonTitles: nil];
		
		[alertView show];
	});
}

@end
