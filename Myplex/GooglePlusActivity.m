//
// Created by sbeyers on 4/1/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "GooglePlusActivity.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "AppDelegate.h"

@interface GooglePlusActivity ()

@property(nonatomic, strong) NSString *text;
@property(nonatomic, strong) NSURL *url;

@end

@implementation GooglePlusActivity

// Create a client ID using google's api. For instructions view https://developers.google.com/+/mobile/ios/getting-started
static NSString *const kClientId = @"409663879192.apps.googleusercontent.com";

// Return the name that should be displayed below the icon in the sharing menu
- (NSString *)activityTitle {
    return @"Google+";
}

// Return the string that uniquely identifies this activity type
- (NSString *)activityType {
    return @"com.captech.googlePlusSharing";
}

// Return the image that will be displayed  as an icon in the sharing menu
- (UIImage *)activityImage {
    UIImage *googleShareIcon = [UIImage imageNamed:@"Google-icon"];
    return googleShareIcon;
}

// allow this activity to be performed with any activity items
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    // Loop through all activity items and pull out the two we are looking for
    for (NSObject *item in activityItems) {
        if ([item isKindOfClass:[NSString class]]) {
            self.text = (NSString *) item;
        } else if ([item isKindOfClass:[NSURL class]]) {
            self.url = (NSURL *) item;
        }
    }
}

// initiate the sharing process. First we will need to login
- (void)performActivity {
    // Get the sign in instance
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGoogleUserEmail = YES;
    // set the client id to my client id
    signIn.clientID = kClientId;
    // From google docs: // Know your name, basic info, and list of people you're connected to on Google+
    signIn.scopes = [NSArray arrayWithObjects:
            kGTLAuthScopePlusLogin, // defined in GTLPlusConstants.h
            nil];
    // set myself as the delegate
    signIn.delegate = self;

    // begin authentication
    [signIn authenticate];
}

// Handle response from authenticate call
- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error {
    [AppDelegate removeActivityIndicator];
    if (error != nil) {
        // if there is an error, notify the user and end the activity
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:kGPlusLoginErrorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        
        [GPPShare sharedInstance].delegate = self;

        // share
        id <GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];

        // you're sharing based on the URL you included.
        [shareBuilder setURLToShare:self.url];
        // filling in the comment text
        [shareBuilder setPrefillText:self.text];

        [shareBuilder setPreselectedPeopleIDs:@[auth.parameters[@"email"]]];
        
        // This method creates a call-to-action button with the label "RSVP".
        // - URL specifies where people will go if they click the button on a platform
        // that doesn't support deep linking.
        // - deepLinkID specifies the deep-link identifier that is passed to your native
        // application on platforms that do support deep linking
        [shareBuilder setCallToActionButtonWithLabel:@"OPEN"
                                                 URL:[NSURL URLWithString:@"http://www.myplex.tv"]
                                          deepLinkID:@"rsvp=4815162342"];
        
        // open the sharing screen
        [shareBuilder open];
    }

    [self activityDidFinish:YES];
}

// handles results from sharing activity.
- (void)finishedSharingWithError:(NSError *)error {
    NSString *text;
    
    if (!error) {
        text = @"Success sharing to google+";
    } else if (error.code == kGPPErrorShareboxCanceled) {
        text = @"Canceled";
    } else {
        text = [NSString stringWithFormat:@"Error while sharing to google+ (%@)", [error localizedDescription]];
    }
    
    NSLog(@"Status: %@", text);
}

@end