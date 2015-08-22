//
//  AppData.h
//  slide2me
//
//  Created by Igor Ostriz on 7/27/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppData : NSObject

@property (strong, nonatomic) NSMutableDictionary *data;
@property (strong, nonatomic) NSString *clientKey;


+ (AppData *)shared;



- (void)load;
- (void)save;

@end
