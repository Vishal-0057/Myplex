//
//  CommentViewController.h
//  Myplex
//
//  Created by Igor Ostriz on 15/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
   CommentTypeComment,
    CommentTypeReview
} CommentType;

@protocol CommentDelegate;
@interface CommentViewController : UIViewController

@property (nonatomic) NSString *titleText;
@property (nonatomic) NSString *text;
@property (nonatomic) CommentType commentType;
@property (nonatomic) CGFloat userRating;

@property (nonatomic, weak) id<CommentDelegate> delegate;

@end


@protocol CommentDelegate <NSObject>

- (void)pressedDoneWithCommentController:(CommentViewController *)commentViewController;
@optional
- (IBAction)done:(UIButton *)sender;
- (IBAction)cancel:(UIButton *)sender;

@end