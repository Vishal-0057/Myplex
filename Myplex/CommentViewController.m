//
//  CommentViewController.m
//  Myplex
//
//  Created by Igor Ostriz on 15/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "CommentViewController.h"
#import "MZFormSheetController.h"
#import "TextView.h"
#import "StarsView.h"

static CGFloat spaceAfterView = 12;
static CGFloat initialViewSpace = 8;

@interface CommentViewController () <UITextViewDelegate>

@end

@implementation CommentViewController
{
    UINavigationBar *_navBar;
    TextView *_textView;
    StarsView *_starsView;
    IBOutlet UIButton *doneButton;
    IBOutlet UIButton *cancelButton;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        ;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _navBar = (UINavigationBar *)[self.view viewWithTag:100];
    
    _textView = (TextView *)[self.view viewWithTag:101];
    _textView.delegate = self;
    _textView.fixedWidth = YES;
    _textView.enabled = YES;
    
    _starsView = (StarsView *)[self.view viewWithTag:102];
    _starsView.userRating = self.userRating;
    _starsView.allowEdit = YES;
    _starsView.animated = NO;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self setLayoutWithAnimation:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [doneButton setEnabled:NO];

    [_textView becomeFirstResponder];
}

- (void)setLayoutWithAnimation:(BOOL)animate
{

    CGFloat origin = 0;
    
    if (self.commentType == CommentTypeComment) {
        [_starsView setHidden:YES];
        origin = CGRectGetMaxY(_navBar.frame);
    } else {
        [_starsView setHidden:NO];
        origin = CGRectGetMaxY(_starsView.frame);
    }
    
    CGRect f = _textView.frame;
    f.origin.y = origin + spaceAfterView + initialViewSpace;
    _textView.frame = f;
    
    f = doneButton.frame;
    f.origin.y = CGRectGetMaxY(_textView.frame) + spaceAfterView;
    doneButton.frame = f;
    
    f = cancelButton.frame;
    f.origin.y = doneButton.frame.origin.y;
    cancelButton.frame = f;
    
    f = self.view.frame;
    f.size.height = CGRectGetMaxY(cancelButton.frame) + spaceAfterView + 4;
    self.view.frame = f;
    
}

- (void)setText:(NSString *)text
{
    _text = text;
    _textView.text = text;
    
}

- (void)setTitleText:(NSString *)titleText
{
    [_navBar topItem].title = titleText;
}

- (IBAction)done:(UIButton *)sender
{
    self.text = _textView.text;
    self.userRating = _starsView.userRating;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pressedDoneWithCommentController:)]) {
        [self.delegate pressedDoneWithCommentController:self];
    }
}

- (IBAction)cancel:(UIButton *)sender
{
    [self dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    if (!(textView.text.length > 0) && self.commentType == CommentTypeComment) {
        [doneButton setEnabled:NO];
    } else {
        [doneButton setEnabled:YES];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (!(textView.text.length > 0) && self.commentType == CommentTypeComment) {
        [doneButton setEnabled:NO];
    } else {
        [doneButton setEnabled:YES];
    }
//    [_textView sizeToFit];
//    [self.view setNeedsLayout];
}


#pragma mark - autoraotation support

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    isIPhone
        return UIInterfaceOrientationMaskPortrait;
    return UIInterfaceOrientationMaskLandscape;
    
}

@end
