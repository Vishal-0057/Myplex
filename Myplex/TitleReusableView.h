//
//  RelatedSectionTitleReusableView.h
//  Transitions
//
//  Created by Igor Ostriz on 10/17/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleReusableView : UICollectionReusableView

@property (nonatomic) BOOL titleOnly;

@property (nonatomic) NSString *titleString;
@property (nonatomic) NSString *subTitleString;


//- (void)alignCenter:(BOOL)align;

@end
