//
//  CardViewPool.m
//  Myplex
//
//  Created by Igor Ostriz on 6.9.2013..
//  Copyright (c) 2013. Igor Ostriz. All rights reserved.
//

#import "CardViewReusePool.h"

@interface CardViewReusePool ()

@property (nonatomic) NSMutableDictionary* viewsFromLastUpdate;
@property (nonatomic) NSMutableDictionary* viewsFromThisUpdate;
@property (nonatomic) NSMutableArray* viewsToReuse;

@end


@implementation CardViewReusePool

- (id)init {
    self = [super init];
    if (self) {
        self.viewsFromLastUpdate = [[NSMutableDictionary alloc] init];
        self.viewsFromThisUpdate = [[NSMutableDictionary alloc] init];
        self.viewsToReuse = [[NSMutableArray alloc] init];
    }
    return self;
}

- (UIView *)findView:(int)i {
    NSNumber *key = [NSNumber numberWithInt:i];
    UIView* view = [self.viewsFromLastUpdate objectForKey:key];
    if (view) {
        [self.viewsFromLastUpdate removeObjectForKey:key];
        [self.viewsFromThisUpdate setObject:view forKey:key];
        return view;
    }
    return nil;
}

- (void)removeView:(UIView *)view
{
    NSArray *ar = [self.viewsFromLastUpdate allKeysForObject:view];
    if (![ar count])
        return;
    int i = [ar[0] intValue];

    NSMutableDictionary *temp = [NSMutableDictionary new];
    
    [self.viewsFromLastUpdate enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        int j = [key intValue];
        if (j < i) {
            temp[key] = obj;
        }
        else if (j == i) {
            // set frame off screen and hide
            CGRect f = [obj frame];
            f.origin.y = 1024;
            [obj setFrame:f];
            [obj setHidden:YES];
            [self.viewsToReuse addObject:obj];
        }
        else {
            temp[@(j - 1)] = obj;
        }
    }];
    
    self.viewsFromLastUpdate = temp;
}

- (UIView *)reuseView:(int)i
{
    UIView *view = [self.viewsToReuse lastObject];
    if (view) {
        [self.viewsToReuse removeLastObject];
        self.viewsFromThisUpdate[@(i)] = view;
        view.hidden = NO;
    }
    return view;
}

- (void)addView:(int)i view:(UIView *)view
{
    self.viewsFromThisUpdate[@(i)] = view;
}

- (void)finishUpdate {
    // put unused views to viewsToReuse array and hide them from the screen
    [self.viewsToReuse addObjectsFromArray:[self.viewsFromLastUpdate allValues]];
    [self.viewsFromLastUpdate removeAllObjects];
    for (int i = 0; i < self.viewsToReuse.count; ++i) {
        UIView *view = [self.viewsToReuse objectAtIndex:i];
        view.hidden = YES;
    }

    NSMutableDictionary* temp = self.viewsFromLastUpdate;
    self.viewsFromLastUpdate = self.viewsFromThisUpdate;
    self.viewsFromThisUpdate = temp;

    //NSLog(@"%d %d", [self.viewsFromLastUpdate count], [self.viewsToReuse count]);
}

@end
