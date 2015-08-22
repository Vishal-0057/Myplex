//
//  LocationManager.m
//  Myplex
//
//  Created by shiva on 3/4/14.
//  Copyright (c) 2014 Igor Ostriz. All rights reserved.
//

#import "LocationManager.h"
#import "Mixpanel.h"

@interface LocationManager () {
    CLLocationManager *_locationManager;
}

@end
@implementation LocationManager

+ (LocationManager *)shared
{
    static LocationManager *_locationManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _locationManager = [[LocationManager alloc] init];
    });
    
    return _locationManager;
}

-(void)updateLocation {
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

/*
 *  locationManager:didFailWithError:
 *
 *  Discussion:
 *    Invoked when an error has occurred. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
#if DEBUG
    NSLog(@"didFailWithError: %@", error);
#endif
    
}

/*
 *  locationManager:didUpdateLocations:
 *
 *  Discussion:
 *    Invoked when new locations are available.  Required for delivery of
 *    deferred locations.  If implemented, updates will
 *    not be delivered to locationManager:didUpdateToLocation:fromLocation:
 *
 *    locations is an array of CLLocation objects in chronological order.
 */
- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_6_0) {

#if DEBUG
    NSLog(@"didUpdateToLocation: %@", [locations lastObject]);
#endif
    //lastObjet is the new location with old delegate.
    CLLocation *currentLocation = [locations lastObject];
    
    if ([self isNotNull:currentLocation]) {
        NSTimeInterval timeInterval = [[currentLocation timestamp] timeIntervalSinceNow];
        /*Because it can take several seconds to return an initial location, the location manager typically delivers the previously cached location data immediately and then delivers more up-to-date location data as it becomes available.
         */
        if (abs((NSInteger)timeInterval) < 15)
        {
            //Register location as mixpanel superproperty.
            [Analytics setSuperProperties:@{@"gps":[NSString stringWithFormat:@"%@,%@",[NSNumber numberWithDouble:currentLocation.coordinate.latitude],[NSNumber numberWithDouble:currentLocation.coordinate.longitude]]}];
            [manager stopUpdatingLocation];
        }
    }
}

@end
