//
//  SplineEval.h
//  SplineExperiment
//
//  Created by Igor Ostriz on 3.9.2013..
//  Copyright (c) 2013. Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SplineEval : NSObject

-(id)initWithPoints:(double *)points numPoints:(size_t)numPoints;

-(double) eval:(double)x;
-(double) evalInverse:(double)y;    // experimental - does not produce true inverse result)

@end
