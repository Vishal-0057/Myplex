//
//  CardDetailsData.h
//  Myplex
//
//  Created by Igor Ostriz on 9/19/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardDetailsData : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *pg;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSString *description;

- (NSString *)durationFormattedString;
- (NSString *)dateFormattedString;

@end
