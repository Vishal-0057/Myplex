//
//  MenuButton.h
//  Myplex
//
//  Created by Igor Ostriz on 11/12/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuButtonDelegate;
@interface MenuButton : UIControl

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subTitle;
@property (nonatomic) NSArray *items;
@property (nonatomic, weak) id<MenuButtonDelegate> delegate;

- (id)initWithMaxFrame:(CGRect)frame;

@end


@protocol MenuButtonDelegate <NSObject>

- (void)menuButton:(MenuButton *)menuButton didSelectItem:(NSString *)string onIndex:(NSUInteger)index;
-(NSArray *)loadItems;
-(CGRect)getFrame;

@end