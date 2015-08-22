//
//  CardView.h
//  Myplex
//
//  Created by Igor Ostriz on 8/20/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ScrollingImageView.h"



typedef enum
{
    ContentTypeNone,
    ContentTypeMovie,
    ContentTypeTVShow,
    ContentTypeLiveTV
} ContentType;


@protocol CardViewDelegate;

@interface CardView : UIView

@property (weak, nonatomic) IBOutlet UILabel *movieTitle;
@property (weak, nonatomic) IBOutlet UIImageView *movieImage;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *peopleLabel;
@property (weak, nonatomic) IBOutlet UIView *hidablesView;
@property (weak, nonatomic) IBOutlet UIButton *priceButton;

//@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) Content *content;
@property (nonatomic) ContentType contentType;
@property (weak, nonatomic) id<CardViewDelegate> delegate;


+ (CardView *)card;
- (void)setActivity:(BOOL)start animated:(BOOL)animated;
- (void)refresh;


@end


@protocol CardViewDelegate <NSObject>
@optional
- (void)play:(CardView *)cardView;
- (void)moreInfoOn:(CardView *)cardView;
- (void)purchase:(CardView *)cardView;
- (void)cardTapped:(CardView *)cardView;
- (void)deleteCard:(CardView *)cardView;
- (void)favoriteCard:(CardView *)cardView favorite:(BOOL)favorite;

@end