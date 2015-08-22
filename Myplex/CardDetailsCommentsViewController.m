//
//  CardDetailsCommentsViewController.m
//  Myplex
//
//  Created by Igor Ostriz on 25/10/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "CardDetailsCommentsViewController.h"
#import "CommentsCell.h"
#import "CommentViewController.h"
#import "MZFormSheetController.h"
#import "RateViewController.h"
#import "UIColor+Hex.h"
#import "User+Utils.h"
#import "AppDelegate.h"

//const NSInteger tintNormal = 0x4c4c4c;
//const NSInteger tintHighlight = 0x56b4e5;

const NSInteger tintNormal = 0x000000;
const NSInteger tintHighlight = 0xffffff;

static NSString *kAddComment = @"Add comment...";
static NSString *kAddUserReview = @"Add review...";



@interface CardDetailsCommentsViewController () <UITableViewDataSource, UITableViewDelegate, RateDelegate, CommentDelegate>

//@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
//@property (weak, nonatomic) IBOutlet UIButton *reviewButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *commentReviewSegment;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;
@property (weak, nonatomic) IBOutlet UIButton *addTextButton;

@end

@implementation CardDetailsCommentsViewController
{
    NSMutableArray *_commentsReviewes;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.layer.cornerRadius = 5;
    self.view.clipsToBounds = YES;
    
    self.view.opaque = NO;
    self.view.backgroundColor = [UIColor clearColor];

    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
    [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor clearColor]];
    
    UIImage *img = [self.rateButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.rateButton setImage:img forState:UIControlStateNormal];
    //self.commentsButton.highlighted = YES;
    [self commentsPressed:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kNotificationCommentsRefreshed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kNotificationReviewsRefreshed object:nil];
    
    self.rateButton.layer.cornerRadius = 4;
    self.rateButton.layer.masksToBounds = NO;
    self.rateButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.rateButton.layer.shouldRasterize = YES;
    
    
    self.addTextButton.layer.cornerRadius = 4;
    self.addTextButton.layer.masksToBounds = NO;
    self.addTextButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.addTextButton.layer.shouldRasterize = YES;
    
    
    self.commentReviewSegment.layer.cornerRadius = 4;
    self.commentReviewSegment.layer.masksToBounds = NO;
    self.commentReviewSegment.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.commentReviewSegment.layer.shouldRasterize = YES;
    
    
    self.addTextButton.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:16.0/255.0 blue:26.0/225.0 alpha:1.0].CGColor;
    self.addTextButton.layer.borderWidth = 1.0f;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    //Called again because we are setting the view frame as per the commentstable content size and after calling viewDidLayoutSubviews view frame is resetting to its initial position.
    [self viewDidLayoutSubviews];
    [self addBackgroundViewBelowSegmentedControl:self.commentReviewSegment];
}

- (void)setContent:(Content *)content
{
    if (_content == content) {
        return;
    }
    _content = content;
    [self reload:[_content.comments allObjects]];
    
    isIPhone {} else {
        
        [self commentsPressed:nil];
    }
    
//    [content refreshCard];
}

- (UIView *)addBackgroundViewBelowSegmentedControl:(UISegmentedControl *)segmentedControl {
    CGFloat autosizedWidth = CGRectGetWidth(segmentedControl.bounds);
    autosizedWidth -= (segmentedControl.numberOfSegments - 1); // ignore the 1pt. borders between segments
    
    NSInteger numberOfAutosizedSegmentes = 0;
    NSMutableArray *segmentWidths = [NSMutableArray arrayWithCapacity:segmentedControl.numberOfSegments];
    for (NSInteger i = 0; i < segmentedControl.numberOfSegments; i++) {
        CGFloat width = [segmentedControl widthForSegmentAtIndex:i];
        if (width == 0.0f) {
            // auto sized
            numberOfAutosizedSegmentes++;
            [segmentWidths addObject:[NSNull null]];
        }
        else {
            // manually sized
            autosizedWidth -= width;
            [segmentWidths addObject:@(width)];
        }
    }
    
    CGFloat autoWidth = floorf(autosizedWidth/(float)numberOfAutosizedSegmentes);
    CGFloat realWidth = (segmentedControl.numberOfSegments-1);      // add all the 1pt. borders between the segments
    for (NSInteger i = 0; i < [segmentWidths count]; i++) {
        id width = segmentWidths[i];
        if (width == [NSNull null]) {
            realWidth += autoWidth;
        }
        else {
            realWidth += [width floatValue];
        }
    }
    
    CGRect whiteViewFrame = segmentedControl.frame;
    whiteViewFrame.size.width = realWidth;
    
    UIView *whiteView = [[UIView alloc] initWithFrame:whiteViewFrame];
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.layer.cornerRadius = 5.0f;
    whiteView.layer.masksToBounds = NO;
    whiteView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    whiteView.layer.shouldRasterize = YES;
    
    
    [self.view insertSubview:whiteView belowSubview:segmentedControl];
    return whiteView;
}

- (void) reload:(NSArray *)ar
{
    _commentsReviewes = [NSMutableArray array];
    [_commentsReviewes addObjectsFromArray:ar];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:FALSE];
    [_commentsReviewes sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [self.commentsTableView reloadData];
    [self.commentsTableView layoutIfNeeded];
    [self.view setNeedsLayout];
}

- (void)viewDidLayoutSubviews
{
    isIPhone
    {
        // tableView should have good contentSize here
        CGSize sz = self.commentsTableView.contentSize;
    
        CGRect f = self.commentsTableView.frame;
        f.size.height = sz.height;
        self.commentsTableView.frame = f;

        f = self.view.frame;
        f.size.height = self.commentsTableView.frame.origin.y + self.commentsTableView.frame.size.height + 8;
        self.view.frame = f;
        [self.view layoutSubviews];
    }
    
}

- (void)setButtonImagesTint
{
    //self.commentReviewSegment.selectedSegmentIndex = !self.commentReviewSegment.selectedSegmentIndex;
//    UIImage * image = [self.commentsButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [self.commentsButton setImage:image forState:UIControlStateNormal];
//    image = [self.reviewButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [self.reviewButton setImage:image forState:UIControlStateNormal];
}

-(IBAction)segmentedValueChanged:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        [self commentsPressed:nil];
    }
    else {
        [self reviewPressed:nil];
    }
}

- (IBAction)commentsPressed:(UIButton *)sender
{
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        //self.commentsButton.highlighted = YES;
////        self.commentsButton.tintColor = UIColorFromRGB(tintHighlight);
////        [self.commentsButton setTitleColor:UIColorFromRGB(tintHighlight) forState:UIControlStateNormal];
////        self.reviewButton.highlighted = NO;
////        self.reviewButton.tintColor = UIColorFromRGB(tintNormal);
////        [self.reviewButton setTitleColor:UIColorFromRGB(tintNormal) forState:UIControlStateNormal];
//        //[self setButtonImagesTint];
//    }];
    
    [self.addTextButton setTitle:kAddComment forState:UIControlStateNormal];
    [self reload:[_content.comments allObjects]];
    [self.content getCommentsRemotely];
}

- (IBAction)reviewPressed:(UIButton *)sender
{
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        //self.reviewButton.highlighted = YES;
////        self.reviewButton.tintColor = UIColorFromRGB(tintHighlight);
////        [self.reviewButton setTitleColor:UIColorFromRGB(tintHighlight) forState:UIControlStateNormal];
////        self.commentsButton.highlighted = NO;
////        self.commentsButton.tintColor = UIColorFromRGB(tintNormal);
////        [self.commentsButton setTitleColor:UIColorFromRGB(tintNormal) forState:UIControlStateNormal];
//        [self setButtonImagesTint];
//    }];
    
    [self.addTextButton setTitle:kAddUserReview forState:UIControlStateNormal];
    [self reload:[_content.userReviews allObjects]];
    [self.content getReviewsRemotely];
}

- (IBAction)addText:(UIButton *)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (![appDelegate isUserAuthenticated]) {
        [appDelegate showAuthenticationMessage];
        return;
    }

    CommentViewController *cv = [[CommentViewController alloc] initWithNibName:@"CommentViewController" bundle:nil];
    cv.userRating = [_content.averageRating floatValue];

    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithSize:cv.view.bounds.size viewController:cv];
    formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.shouldCenterVertically = NO;
    formSheet.shouldMoveToTopWhenKeyboardAppears = YES;

    if ([sender.titleLabel.text isEqualToString:kAddComment]) {
        cv.titleText = @"enter your comment";
        cv.commentType = CommentTypeComment;
    }
    else {
        cv.titleText = @"enter your review";
        cv.commentType = CommentTypeReview;
    }
    cv.delegate = self;

    [self presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];

}

- (void)pressedDoneWithCommentController:(CommentViewController *)commentViewController
{
    NSString *comment = commentViewController.text;
    [commentViewController dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        if (commentViewController.commentType == CommentTypeComment) {
            [self.content setComment:comment];
        } else if(commentViewController.commentType == CommentTypeReview) {
            CGFloat rate = commentViewController.userRating;
            [self.content setReview:comment andRate:rate];
            self.content.currentUserRating = @(rate);
        }
    }];
}

- (IBAction)ratePressed:(UIButton *)sender
{
    RateViewController *rv = [[RateViewController alloc] initWithNibName:@"RateViewController" bundle:nil];
    rv.userRating = [_content.currentUserRating floatValue];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithSize:rv.view.bounds.size viewController:rv];
    formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.shouldCenterVertically = YES;
    formSheet.shouldCenterVerticallyWhenKeyboardAppears = NO;
    formSheet.shouldMoveToTopWhenKeyboardAppears = YES;
    rv.delegate = self;
    [self presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        ;
    }];
}

- (void)pressedDoneWithRateController:(RateViewController *)rateViewController
{
    [rateViewController dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        CGFloat rate = rateViewController.userRating;
        [self.content setReview:nil andRate:rate];
        self.content.currentUserRating = @(rate);
    }];
}

#pragma mark - UITableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _commentsReviewes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCellID" forIndexPath:indexPath];
    
    cell.commentOrReview = _commentsReviewes[indexPath.row];

    isIPhone {} else cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CommentsCell totalHeightForData:_commentsReviewes[indexPath.row]];
}

#pragma mark Notification Received
-(void)notificationReceived:(NSNotification *)notification
{

    NSArray *values = nil;
    NSArray *results = notification.object[@"results"];
    
    if ([results count]) {
        values = [results lastObject][@"comments"][@"values"]?:[results lastObject][@"userReviews"][@"values"];
    } else {
//        values = self.commentsButton.highlighted?[self.content.comments allObjects]:[self.content.userReviews allObjects];
        values = self.commentReviewSegment.selectedSegmentIndex?[self.content.comments allObjects]:[self.content.userReviews allObjects];
    }
    
    if ([values count]) {
        if (notification.name == kNotificationCommentsRefreshed && self.commentReviewSegment.selectedSegmentIndex == 0) { //should reload only if we comments is highlighted, not the reviews.
            
            if ([values count]) {
                [self reload:values];
            }
        } else if(notification.name == kNotificationReviewsRefreshed && self.commentReviewSegment.selectedSegmentIndex == 1) {
            if ([values count]) {
                [self reload:values];
            }
        }
    }
}

@end
