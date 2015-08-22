//
// Created by sbeyers on 3/25/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SharingActivityProvider.h"

@interface SharingActivityProvider () {
    NSString *_message;
}

@end
@implementation SharingActivityProvider


-(id)initWithMessage:(NSString *)message {
    
    self = [super init];
    if (self) {
        _message = message;
    }
    return self;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    // Log out the activity type that we are sharing with
    NSLog(@"activityType:%@", activityType);

    // Create the default sharing string
//    NSString *shareString = kShareMessage;
//
//    // customize the sharing string for facebook, twitter, weibo, and google+
//    if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
//        shareString = kFacebookShareMessage;
//    } else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
//        shareString = kTwitterShareMessage;
//    } else if ([activityType isEqualToString:@"com.captech.googlePlusSharing"]) {
//        shareString = kGPlusShareMessage;
//    }

    return _message;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return @"";
}

@end