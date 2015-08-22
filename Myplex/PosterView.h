//
//  PosterView.h
//  Myplex
//
//  Created by shiva on 10/28/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PosterView : UIView {
    NSTimer *posterScrollTimer;
}

-(void)invalidateTimer ;

@end
