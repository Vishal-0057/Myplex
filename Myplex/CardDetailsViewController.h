//
//  CardDetailsViewController.h
//  Myplex
//
//  Created by Igor Ostriz on 8/30/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardDetailsData.h"

@class Content;
@class ReflectionView;

@interface CardDetailsViewController : UIViewController

@property (weak,nonatomic) IBOutlet UIButton *playButton;
@property (weak,nonatomic) IBOutlet UIButton *trailerButton;
@property (weak,nonatomic) IBOutlet UIButton *backButton;
@property (weak,nonatomic) IBOutlet UIButton *shareButton;

//@property (weak, nonatomic) IBOutlet UIImageView *movieImage;
@property (weak, nonatomic) IBOutlet ReflectionView *reflectionView;
@property (nonatomic) Content *content;
@property (nonatomic) NSInteger cardBrowseType;
@property (nonatomic, weak) id delegate;

- (IBAction)play:(UIButton *)sender;
-(IBAction)share:(id)sender;
-(IBAction)back:(id)sender;

-(void) refreshContent:(Content *)content;

@end
