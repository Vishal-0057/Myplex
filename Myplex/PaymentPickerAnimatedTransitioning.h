//
//  PaymentPickerAnimatedTransitioning.h
//  Myplex
//
//  Created by Igor Ostriz on 19/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentPickerAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL reverse;
@property (nonatomic) CGRect sinkRect;

@end
