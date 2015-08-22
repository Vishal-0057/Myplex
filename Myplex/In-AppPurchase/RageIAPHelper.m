//
//  RageIAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "RageIAPHelper.h"
#import "AppDelegate.h"

@implementation RageIAPHelper

+ (RageIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static RageIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        //NSSet * productIdentifiers = [AppDelegate getProductIdentifiers];

        //For testing.
        NSSet * productIdentifiers = nil;//[NSSet setWithObjects:
                                      //@"com.apalya.myplextest.P012",
                                      //@"com.apalya.myplextest.P012_month",
                                      //nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
