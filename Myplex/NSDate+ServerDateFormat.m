//
//  NSDate+ServerDateFormat.m
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "NSDate+ServerDateFormat.h"

@implementation NSDate (ServerDateFormat)

- (NSString*)serverDateFormat
{
	return [NSString stringWithFormat: @"%d000", (NSUInteger)([self timeIntervalSince1970])];
}

+ (NSDate *)dateFromServerFormattedDateString: (NSString*)serverFormattedDateString
{
	NSTimeInterval dateInSeconds = [serverFormattedDateString doubleValue] / 1000;
	
	return [NSDate dateWithTimeIntervalSince1970: dateInSeconds];
}

+ (NSDate *)formatStringToDate:(NSString *)dateString_
{
	if(!dateString_||dateString_.length==0)
		return nil;
	
	NSString * dateString = [dateString_ copy];
	
    NSLocale* usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];

	NSDate *date = nil;
	NSDateFormatter *_internetDateTimeFormatter = [[NSDateFormatter alloc] init];
	[_internetDateTimeFormatter setLocale:usLocale];
    
	NSMutableString *RFC3339String = [NSMutableString stringWithString:[dateString uppercaseString]];
	
	if (RFC3339String.length > 20)
	{
        RFC3339String = [NSMutableString stringWithString:[RFC3339String stringByReplacingOccurrencesOfString:@"Z" withString:@""]];
        
		RFC3339String = [NSMutableString stringWithString:[RFC3339String stringByReplacingOccurrencesOfString:@":"withString:@""options:0 range:NSMakeRange(20, RFC3339String.length-20)]];
	} else {
        	RFC3339String = [NSMutableString stringWithString:[RFC3339String stringByReplacingOccurrencesOfString:@"Z" withString:@"-0000"]];
    }
	
    
    if (!date) {
        [_internetDateTimeFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS"];
        date = [_internetDateTimeFormatter dateFromString:RFC3339String];
    }
    if (!date) {
        [_internetDateTimeFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        date = [_internetDateTimeFormatter dateFromString:RFC3339String];
    }
	if (!date) {
        [_internetDateTimeFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZ"];
        date = [_internetDateTimeFormatter dateFromString:RFC3339String];
    }
	if (!date)
	{
		[_internetDateTimeFormatter setDateFormat:@"yyyy-MM-ddTHH:mm:ssZZZ"];
		date = [_internetDateTimeFormatter dateFromString:RFC3339String];
	}
	if (!date)
	{
		[_internetDateTimeFormatter setDateFormat:@"yyyy-MM-ddTHH:mm:ss.SSSZZZ"];
		date = [_internetDateTimeFormatter dateFromString:RFC3339String];
	}
	if (!date)
	{
		[_internetDateTimeFormatter setDateFormat:@"yyyy-MM-ddTHH:mm:ss"];
		date = [_internetDateTimeFormatter dateFromString:RFC3339String];
	}
	if (!date)
	{
		[_internetDateTimeFormatter setDateFormat:@"yyyy-MM-dd-0000"];
		date = [_internetDateTimeFormatter dateFromString:RFC3339String];
	}
	
	return date;
}

+ (NSDate *)GMTDate {
    return [[NSDate date] dateByAddingTimeInterval:-[[NSTimeZone systemTimeZone] secondsFromGMTForDate:[NSDate date]]];
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
	return [date stringWithFormat:format];
}

- (NSString *)stringWithFormat:(NSString *)format {
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:format];
	NSString *timestamp_str = [outputFormatter stringFromDate:self];
	return timestamp_str;
}

@end
