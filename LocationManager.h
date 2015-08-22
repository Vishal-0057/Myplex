//
//  LocationManager.h
//  Myplex
//
//  Created by shiva on 3/4/14.
//  Copyright (c) 2014 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate>

+ (LocationManager *)shared;
-(void)updateLocation;

@end
