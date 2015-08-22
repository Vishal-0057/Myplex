//
//  CardDetailsTransitioning.m
//  Myplex
//
//  Created by Igor Ostriz on 9/12/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//



#import "CardDetailsAnimatedTransitioning.h"

#import "CardDetailsViewController.h"
#import "CardView.h"
#import "CardsViewController.h"
#import "ReflectionView.h"

@implementation CardDetailsAnimatedTransitioning
{
    UIDynamicAnimator *_animator;
}



- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 1.8;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *inView = [transitionContext containerView];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *from = [fromVC view];
    UIView *to = [[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] view];
    
    __block CardView *card;
    if ([fromVC isKindOfClass:[CardsViewController class]] && [toVC isKindOfClass:[CardDetailsViewController class]]) {
        __block CardsViewController *cvc = (CardsViewController *)fromVC;
        CardDetailsViewController *cdvc = (CardDetailsViewController *)toVC;
        
        to.alpha = 0;
        [inView insertSubview:to aboveSubview:from];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0
             usingSpringWithDamping:0.9 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            NSArray *cards = [cvc visibleCards];
                            if (cards.count == 0) {
                                return;
                            }
                            
                            CardView *topCard = [cvc getTopCardForCurrentOffset];
                            for (CardView *c in cards) {
                                if (![c isEqual:topCard]) {
                                    [c setCenter:CGPointMake(640, 0)];
                                }
                            }
                            
                            card = topCard;
                            card.clipsToBounds = NO;

                            CGRect fStartCard = card.movieImage.frame;
                            CGRect fEndCard = cdvc.reflectionView.frame; // CGRectMake(0,0,320,174);
                            CGFloat dw = fEndCard.size.width / fStartCard.size.width;
                            CGFloat dh = fEndCard.size.height / fStartCard.size.height;
                            
                            CGPoint pt = [cdvc.reflectionView convertPoint:cdvc.reflectionView.frame.origin toView:nil];
                            pt = [card convertPoint:pt fromView:nil];
                            
                            // move image to top...
                            CGRect f = card.movieImage.frame;
                            f.origin = pt;
                            
                            // and enlarge it a bit to cover screen
                            f.size.width *= dw;
                            f.size.height *= dh;
                            card.movieImage.frame = f;

                            // hide all controlls from source, except play button and movie images
                            card.hidablesView.alpha = 0;
                            
//                            // resize a bit play button, and reposition it
//                            f = card.playButton.frame;
//                            f.size.width *= dw;
//                            f.size.height *= dh;
//                            card.playButton.frame = f;
//                            card.playButton.center = card.movieImage.center;

                            // introduce to
                            to.alpha = 1;
                            
//                            card.movieImage.transform = CGAffineTransformMakeScale(dw, dh);
//                            card.transform = CGAffineTransformConcat(
//                                                                     CGAffineTransformMakeScale(1.1, 1.1),
//                                                                     CGAffineTransformMakeTranslation(-5, -10)
//                                                                     );
//                            
                            
                        } completion:^(BOOL finished) {
                            card.alpha = 1;
                            card.clipsToBounds = YES;
                            card.movieImage.alpha = 0;
//                            [cvc updateCardsPosition];
                            [from removeFromSuperview];
                            [transitionContext completeTransition:YES];
                        }
         ];

        
    } else {
        // reverse
    }

}

@end
