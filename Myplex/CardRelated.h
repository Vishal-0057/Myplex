//
//  CardRelated.h
//  Myplex
//
//  Created by Igor Ostriz on 9/24/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Content;
@interface CardRelated : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) Content *content;

+ (CGSize)size;
- (CGSize)size;



@end
