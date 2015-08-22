//
//  FeedbackViewController.h
//  Myplex
//
//  Created by shiva on 10/9/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackViewController : UIViewController {
    IBOutlet UISlider       *rateSlider;
    IBOutlet UILabel        *rateLbl;
    IBOutlet UITextView     *reviewTextView;
    IBOutlet UILabel        *reviewCharCount;
}

-(IBAction)rateSliderUpdated:(id)sender;

@end
