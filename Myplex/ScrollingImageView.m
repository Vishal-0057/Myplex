//
//  ScrollingImageView.m
//  pager
//
//  Created by Igor Ostriz on 05/12/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "ScrollingImageView.h"
#import "UIImageView+WebCache.h"
#import "UIColor+Hex.h"

void (^_completionBlock)(UIImage *, NSError*);

@interface ScrollingImageView () <UIScrollViewDelegate>

@property (nonatomic, assign, readwrite) NSInteger currentPageIndex;

@end


@implementation ScrollingImageView
{
    UIImageView *_iv1, *_iv2, *_iv3;
    int _currentPageIndex;
}


- (void)initialize
{
    self.delegate = self;
    self.clipsToBounds = YES;
    
    CGRect r = self.bounds;
    r.origin.x = -1;
    _iv1 = [[UIImageView alloc] initWithFrame:r];
    _iv2 = [[UIImageView alloc] initWithFrame:r];
    _iv3 = [[UIImageView alloc] initWithFrame:r];
    self.contentSize = CGSizeMake(self.bounds.size.width * _numPages, self.bounds.size.height);
    [self addSubview:_iv1];
    [self addSubview:_iv2];
    [self addSubview:_iv3];
    
//    _iv1.contentMode = UIViewContentModeCenter;
//    _iv2.contentMode = UIViewContentModeCenter;
//    _iv3.contentMode = UIViewContentModeCenter;
    
    _iv1.contentMode = UIViewContentModeScaleAspectFill;
    _iv2.contentMode = UIViewContentModeScaleAspectFill;
    _iv3.contentMode = UIViewContentModeScaleAspectFill;
    
    _currentPageIndex = 0;
    _numPages = 0;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex
{
    if (_currentPageIndex == currentPageIndex) {
        return;
    }
    _currentPageIndex = currentPageIndex;
    [self.dataDelegate scrollingImageView:self currentPageIndexDidChange:currentPageIndex];
}

- (void)setNumPages:(NSUInteger)numPages
{
    if (numPages != _numPages) {
        _numPages = numPages;
        self.contentSize = CGSizeMake(self.bounds.size.width * _numPages, self.bounds.size.height);
        [self setCurrentPage:0];
    }
}

- (BOOL)isPageVisible:(NSUInteger)index
{
    return (self.contentOffset.x >= index * self.bounds.size.width) && (self.contentOffset.x < (index+1) * self.bounds.size.width);
}

- (void)setCurrentPage:(NSUInteger)currentPage
{
    [self setUIImageView:_iv1 toPageIndex:currentPage -1];
    [self setUIImageView:_iv2 toPageIndex:currentPage];
    [self setUIImageView:_iv3 toPageIndex:currentPage +1];
    if (self.contentOffset.x != currentPage * self.bounds.size.width) {
        self.contentOffset = CGPointMake(currentPage * self.bounds.size.width,0);
    }
    self.currentPageIndex = currentPage;
}

- (void)reloadData
{
    id<ScrollingImageViewDataDelegate> dataDelegate_ = self.dataDelegate;
    
    if (_iv1.tag >= 0 && _iv1.tag < self.numPages) {
        NSInteger pageIndex = _iv1.tag;
        [_iv1 setImageWithURL:[self.dataDelegate imageURLForPageIndex:_iv1.tag] completed:^(UIImage *image, NSError *error, SDImageCacheType imageCacheType) {
            [dataDelegate_ updateColorFromImage:image forPage:pageIndex];
        }];
        _iv1.backgroundColor = [ScrollingImageView getbackgroundColor];

//        [self.dataDelegate updateColorFromImage:_iv1.image];
//        [self.dataDelegate scrollingImageView:self imageForPageIndex:_iv1.tag withCompletionBlock:^(UIImage *image, NSError *error){
//            if (image) {
//                _iv1.image = image;
//            }
//        }];
    }
    if (_iv2.tag >= 0 && _iv2.tag < self.numPages) {
        NSInteger pageIndex = _iv2.tag;
        [_iv2 setImageWithURL:[self.dataDelegate imageURLForPageIndex:_iv2.tag] completed:^(UIImage *image, NSError *error, SDImageCacheType imageCacheType){
            [dataDelegate_ updateColorFromImage:image forPage:pageIndex];
        }];
        _iv2.backgroundColor = [ScrollingImageView getbackgroundColor];

//        [self.dataDelegate updateColorFromImage:_iv1.image];

        //_iv2.image = [self.dataDelegate scrollingImageView:self imageForPageIndex:_iv2.tag withCompletionBlock:_completionBlock];
//        [self.dataDelegate scrollingImageView:self imageForPageIndex:_iv2.tag withCompletionBlock:^(UIImage *image, NSError *error){
//            if (image) {
//                _iv2.image = image;
//            }
//        }];
    }
    if (_iv3.tag >= 0 && _iv3.tag < self.numPages) {
        NSInteger pageIndex = _iv3.tag;
        [_iv3 setImageWithURL:[self.dataDelegate imageURLForPageIndex:_iv3.tag] completed:^(UIImage *image, NSError *error, SDImageCacheType imageCacheType){
            [dataDelegate_ updateColorFromImage:image forPage:pageIndex];
        }];
        _iv3.backgroundColor = [ScrollingImageView getbackgroundColor];

//        [self.dataDelegate updateColorFromImage:_iv1.image];

        //_iv3.image = [self.dataDelegate scrollingImageView:self imageForPageIndex:_iv3.tag withCompletionBlock:_completionBlock];
//        [self.dataDelegate scrollingImageView:self imageForPageIndex:_iv3.tag withCompletionBlock:^(UIImage *image, NSError *error){
//            if (image) {
//                _iv3.image = image;
//            }
//        }];
    }
}

static UIImage *_defaultPreviewImage;

- (void)setUIImageView:(UIImageView *)imageView toPageIndex:(int)pageIndex
{
    CGFloat x = pageIndex * self.bounds.size.width;
    CGRect r = CGRectMake(x, 0, self.bounds.size.width, self.bounds.size.height);
    imageView.tag = pageIndex;
    if (imageView.frame.origin.x != r.origin.x) {
        imageView.frame = r;
        //imageView.image = (pageIndex < 0 || pageIndex >= self.numPages) ? nil : [self.dataDelegate scrollingImageView:self imageForPageIndex:pageIndex];
        if (pageIndex < 0 || pageIndex >= self.numPages) {
            imageView.image = nil;
        } else {
            [imageView setImageWithURL:[self.dataDelegate imageURLForPageIndex:pageIndex] completed:^(UIImage *image, NSError *error, SDImageCacheType imageCacheType){
                [self.dataDelegate updateColorFromImage:image forPage:pageIndex];
            }];
            imageView.backgroundColor = [ScrollingImageView getbackgroundColor];

//            [self.dataDelegate scrollingImageView:self imageForPageIndex:pageIndex withCompletionBlock:^(UIImage *image, NSError *error) {
//                if (image) {
//                    imageView.image = image;
//                }
//            }];
        }
    }
}


- (UIImageView *)freeUIImageView
{
    if (!CGRectIntersectsRect(_iv1.frame, self.bounds))
        return _iv1;
    if (!CGRectIntersectsRect(_iv2.frame, self.bounds))
        return _iv2;
    return _iv3;
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat pgW = self.bounds.size.width;
    if (targetContentOffset->x > self.numPages * pgW) {
        targetContentOffset->x = self.numPages * pgW;
    }
    else {
        CGFloat dx = targetContentOffset->x / pgW;
        targetContentOffset->x = (int)dx * pgW;
        
        if ((int)(dx + .5) > (int)dx)
            targetContentOffset->x += pgW;
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static CGFloat lastContentOffsetX = 0;
    
    BOOL right = scrollView.contentOffset.x > lastContentOffsetX;
    lastContentOffsetX = scrollView.contentOffset.x;
    
    int currentPage = floorf(self.contentOffset.x / self.bounds.size.width);
    self.currentPageIndex = currentPage;

    if (lastContentOffsetX == currentPage * self.bounds.size.width) {
        [self setCurrentPage:currentPage];
        return;
    }
    
    int pageIndex = currentPage + (right ? 2 : -1);
    [self setUIImageView:[self freeUIImageView] toPageIndex:pageIndex];
}

- (UIImageView *)getUIImageViewHoldingPageIndex:(NSUInteger)index
{
    if (_iv1.tag == index) return _iv1;
    if (_iv2.tag == index) return _iv2;
    if (_iv3.tag == index) return _iv3;
    
    return nil;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    UIImageView *iv = [self getUIImageViewHoldingPageIndex:_currentPageIndex];
    if (iv) {
        //iv.image = (_currentPageIndex < 0 || _currentPageIndex >= self.numPages) ? nil : [self.dataDelegate scrollingImageView:self imageForPageIndex:_currentPageIndex withCompletionBlock:_completionBlock];
        if (_currentPageIndex < 0 || _currentPageIndex >= self.numPages) {
            iv.image = nil;
        } else {
            
            [iv setImageWithURL:[self.dataDelegate imageURLForPageIndex:_currentPageIndex] completed:^(UIImage *image, NSError *error, SDImageCacheType imageCacheType){
                [self.dataDelegate updateColorFromImage:image forPage:_currentPageIndex];
            }];
            
            iv.backgroundColor = [ScrollingImageView getbackgroundColor];
//            [self.dataDelegate scrollingImageView:self imageForPageIndex:_currentPageIndex withCompletionBlock:^(UIImage *image, NSError *error){
//                if (image) {
//                    iv.image = image;
//                }
//            }];
        }
    }
}

+(UIColor *)getbackgroundColor {
    
//    CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
//    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
//    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
//    
//    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
    return [UIColor getPlaceHolderColor];
}

@end
