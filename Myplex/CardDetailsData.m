//
//  CardDetailsData.m
//  Myplex
//
//  Created by Igor Ostriz on 9/19/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "CardDetailsData.h"

@implementation CardDetailsData

- (NSString *)durationFormattedString {
    NSInteger ti = (NSInteger)self.duration;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%2i:%02i:%02i", hours, minutes, seconds];
}


- (NSString *)dateFormattedString
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    return [formatter stringFromDate:self.date];
}
@end
