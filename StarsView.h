//
//  StarsView.h
//  Myplex
//
//  Created by Igor Ostriz on 9/2/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarsView : UIControl

@property (nonatomic) CGFloat userRating;
@property (nonatomic) BOOL animated;

- (id)initWithFrame:(CGRect)frame andRating:(int)rating animated:(BOOL)animated;


@end
