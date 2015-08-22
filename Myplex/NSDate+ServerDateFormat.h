//
//  NSDate+ServerDateFormat.h
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ServerDateFormat)

- (NSString *)serverDateFormat;
+ (NSDate *)dateFromServerFormattedDateString: (NSString*)serverFormattedDateString;
+ (NSDate *)formatStringToDate:(NSString *)dateString_;
+ (NSDate *)GMTDate;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format;

@end
