//
//  TitleDetailedReusableView.h
//  Myplex
//
//  Created by Igor Ostriz on 24/10/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleDetailedReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@end
