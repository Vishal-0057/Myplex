//
//  ScrollingImageView.h
//  pager
//
//  Created by Igor Ostriz on 05/12/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScrollingImageViewDataDelegate;

@interface ScrollingImageView : UIScrollView

@property (weak, nonatomic) id<ScrollingImageViewDataDelegate> dataDelegate;
@property (nonatomic, assign) NSUInteger numPages;
@property (nonatomic, assign, readonly) NSInteger currentPageIndex;


- (BOOL)isPageVisible:(NSUInteger)index;
- (void)setCurrentPage:(NSUInteger)currentPage;
- (void)reloadData;

@end



@protocol ScrollingImageViewDataDelegate <NSObject>

//- (void)scrollingImageView:(ScrollingImageView *)scrollingImageView imageForPageIndex:(int)pageIndex withCompletionBlock:(void (^)(UIImage *image, NSError*))block;
-(void)updateColorFromImage:(UIImage *)image forPage:(NSInteger)pageIndex;
- (void)scrollingImageView:(ScrollingImageView *)scrollingImageView currentPageIndexDidChange:(int)pageIndex;
-(NSURL *)imageURLForPageIndex:(int)pageIndex;

@end