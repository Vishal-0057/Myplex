//
//  CardsViewController.h
//  Myplex
//
//  Created by Igor Ostriz on 9/9/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    CardsNone = -1,
    CardsAll,
    CardsRecommendations,
    CardsFavorites,
    CardsMovies,
    CardsTVShows,
    CardsLiveTV,
    CardsFIFA,
    CardsSearch,
    CardsSelected,
    CardsPurchased,
} CardBrowseType;

@class CardView;
@interface CardsViewController : UIViewController

@property (nonatomic, weak) id delegate;

- (void)refresh:(CardBrowseType)browseType;
- (void)refreshWithCards:(NSArray *)cards;
- (void)refreshWithSearchQuery:(NSString *)query;

- (NSArray *)visibleCards;
- (CardView *)getTopCardForCurrentOffset;
- (void)updateCardsPosition:(BOOL)forceContentUpdate;
- (void)showDeletedCards;
-(UIView *)getMenuView;
-(void)setTappedCard:(CardView *)cardView;
@end
