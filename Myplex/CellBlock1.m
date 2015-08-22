//
//  CellBlock1.m
//  Myplex
//
//  Created by Igor Ostriz on 9/19/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "Cast.h"
#import "CellBlock1.h"
#import "Content+Utils.h"
#import "ExtrasCell.h"




//@interface CastCell : UITableViewCell
//
//@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
//@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
//
//@end
//
//@implementation CastCell
//
//
//@end
//
//
//



static CGFloat spaceAfterBlock = 16;
static CGFloat spaceAfterLabel = 4;
static NSInteger separatorStartIndex = 101;


@interface CellBlock1 () <UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIView *holderView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditsLabel;
@property (weak, nonatomic) IBOutlet UIButton *expander1Button;
@property (weak, nonatomic) IBOutlet UILabel *extrasLabel;

@end


@implementation CellBlock1
{
    BOOL _expanded;
    
    UICollectionViewFlowLayout *flow1, *flow2;
    NSInteger selectedItem;
}

+ (CGSize)size
{
    return CGSizeMake(308, 182);
}

- (CGSize)size
{
    return self.contentView.frame.size;
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
//        self.layer.shadowOffset = CGSizeMake(0, 0.5);
//        self.layer.shadowRadius = 3.0;
//        self.layer.shadowColor = [UIColor grayColor].CGColor;
//        self.layer.shadowOpacity = 0.5;
//        [self.layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.bounds] CGPath]];
        
        selectedItem = -1;
        flow1 = [[UICollectionViewFlowLayout alloc] init];
        flow1.itemSize = CGSizeMake(130, 130.*9/16);
        flow1.minimumInteritemSpacing = 12;
        flow1.sectionInset = UIEdgeInsetsMake(0, 0, 12, 0);
        
        flow2 = [[UICollectionViewFlowLayout alloc] init];
        flow2.itemSize = CGSizeMake(273, 273.*9/16);
        flow2.minimumInteritemSpacing = 12;
        flow2.sectionInset = UIEdgeInsetsMake(0, 0, 12, 0);
    }
    return self;
}


- (void)setViewWithContent:(Content *)content
{
    self.titleLabel.text = content.title;
    self.pgLabel.text = @"PG-13";
    self.durationLabel.text = content.duration;
    self.dateLabel.text = [content releaseDateAsString];
    
    self.briefDescription = content.baseDescription;
    self.description = content.studioDescription;
    
    NSArray *casts = [content.casts allObjects];
    self.casts = casts;
    [self setLayoutWithAnimation:NO];
}

- (void)setLayoutWithAnimation:(BOOL)animate
{
    if (!self.extrasCollectionView.delegate) {
        [self.extrasCollectionView setCollectionViewLayout:flow1 animated:NO];
        self.extrasCollectionView.delegate = self;
        self.extrasCollectionView.dataSource = self;
        self.creditsTableView.dataSource = self;
    }
    
    
    void (^blck)() = ^{
        self.descriptionLabel.alpha = _expanded ? 1 : 0;
        CGRect frame = self.descriptionText.frame;
        if (!_expanded) {
            frame.origin.y = self.descriptionLabel.frame.origin.y;
        }
        else {
            frame.origin.y = CGRectGetMaxY(self.descriptionLabel.frame) + spaceAfterLabel;
        }
        
        self.descriptionText.text = _expanded ? self.description : self.briefDescription;
//        [self.descriptionText sizeToFit];
        frame.size.height = self.descriptionText.contentSize.height;
        self.descriptionText.frame = frame;

#ifdef DEBUG
        NSLog(@"descriptionText:%@ \nheight:%3f", self.descriptionText.text, self.descriptionText.contentSize.height);
#endif
        
        
        UIView *sep = [self viewWithTag:separatorStartIndex];
        frame = sep.frame;
        frame.origin.y = CGRectGetMaxY(self.descriptionText.frame) + spaceAfterBlock;
        sep.frame = frame;
        
        frame = self.creditsLabel.frame;
        frame.origin.y = CGRectGetMaxY(sep.frame) + spaceAfterBlock;
        self.creditsLabel.frame = frame;
        
        frame = self.creditsTableView.frame;
        frame.origin.y = CGRectGetMaxY(self.creditsLabel.frame) + spaceAfterBlock;
        frame.size.height = self.creditsTableView.rowHeight * [self.casts count];
        self.creditsTableView.frame = frame;
        
        sep = [self viewWithTag:separatorStartIndex+1];
        frame = sep.frame;
        frame.origin.y = CGRectGetMaxY(self.creditsTableView.frame) + spaceAfterBlock;
        sep.frame = frame;
        
            frame = self.extrasLabel.frame;
            frame.origin.y = CGRectGetMaxY(sep.frame) + spaceAfterLabel;
        if ([self.extrasLabel isHidden]) frame.size.height = 0;
            self.extrasLabel.frame = frame;
            
            frame = self.extrasCollectionView.frame;
            frame.origin.y = CGRectGetMaxY(self.extrasLabel.frame) + spaceAfterLabel;
            frame.size.height = [self.extrasLabel isHidden] ? 0 : self.extrasCollectionView.contentSize.height;
            self.extrasCollectionView.frame = frame;
        
        frame = self.holderView.frame;
        frame.size.height = CGRectGetMaxY(_expanded ? self.extrasCollectionView.frame : self.descriptionText.frame) + spaceAfterBlock;
        self.holderView.frame = frame;
        
        frame = self.frame;
        frame.size.height = CGRectGetMaxY(self.holderView.frame) + spaceAfterBlock;
        self.frame = frame;
    };
    
    void (^compl)(BOOL) = ^(BOOL finished){
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCellLayoutChanged object:self];
    };
    
    if (animate) {
        [UIView animateWithDuration:0.3 animations:blck completion:compl];
    }
    else {
        blck();
    }
    
}

- (void)transitionAnimation
{
    [self setLayoutWithAnimation:YES];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setLayoutWithAnimation:NO];
    });
}

- (IBAction)expanderClicked:(UIButton *)sender
{
    _expanded = !_expanded;
    
    [self.expander1Button setImage:[UIImage imageNamed:_expanded ? @"collapse-triangle" : @"expand-triangle"] forState:UIControlStateNormal];
     
//    self.descriptionText.text = _expanded ? self.description : self.briefDescription;
    
    [self performSelector:@selector(transitionAnimation) withObject:nil afterDelay:0.05];
    
    
//    NSLog(@"self.frame::(%3f,%3f), contentView:(%3f,%3f,%3f,%3f)", self.frame.size.width, self.frame.size.height, self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    [self setNeedsLayout];
}


#pragma mark - UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.casts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CastCell *cell = (CastCell *)[tableView dequeueReusableCellWithIdentifier:@"castCellID" forIndexPath:indexPath];
//    
//    Cast *cast = (Cast *)self.casts[indexPath.row];
//    cell.roleLabel.text = cast.type;
//    cell.nameLabel.text = cast.name;
//    return cell;
    return nil;
}


#pragma mark - extras handling

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ExtrasCell *cell = (ExtrasCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellViewId" forIndexPath:indexPath];
    
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"img%i.jpeg", indexPath.item+1]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.item == selectedItem) ? flow2.itemSize : flow1.itemSize;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView != self.extrasCollectionView) {
        return;
    }
    if (selectedItem == indexPath.item) {
        selectedItem = -1;
    }
    else {
        selectedItem = indexPath.item;
    }
    
    CGSize sz1 = self.extrasCollectionView.collectionViewLayout.collectionViewContentSize;
    [collectionView setCollectionViewLayout:collectionView.collectionViewLayout == flow1 ? flow2 : flow1 animated:YES completion:^(BOOL finished) {
        CGFloat delta = self.extrasCollectionView.collectionViewLayout.collectionViewContentSize.height - sz1.height;
        NSLog(@"Delta: %3f", delta);
//        CGSize sz2 = self.extrasCollectionView.collectionViewLayout.collectionViewContentSize;
//        CGRect frame = self.frame;
//        frame.size.height += (sz2.height - sz1.height);
//        self.frame = frame;
//        NSLog(@"sz1.h:%3f, sz2.h:%3f", sz1.height, sz2.height);
        
        
    
//        [self performSelector:@selector(transitionAnimation) withObject:nil afterDelay:0.05];
//        frame = self.extrasCollectionView.frame;
//        frame.size = self.extrasCollectionView.contentSize;
//        self.extrasCollectionView.frame = frame;
        
        
        
    }];
    
}


@end
