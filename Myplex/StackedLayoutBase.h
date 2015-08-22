//
//  StackedLayout.h
//  Transitions
//
//  Created by Igor Ostriz on 10/9/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>


UIKIT_EXTERN NSString * const SectionLayoutTitleKind;
UIKIT_EXTERN NSString * const SectionLayoutTitleDetailedKind;


@interface StackedLayoutBase : UICollectionViewLayout

// each section holds array of contained extras
@property (nonatomic) NSArray *sections;

@end


@interface StackedLayoutSingleRow : StackedLayoutBase

@end


@interface StackedLayoutSingleColumn : StackedLayoutBase

@end



