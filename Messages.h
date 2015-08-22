//
//  Messages.h
//  Myplex
//
//  Created by shiva on 12/31/13.
//  Copyright (c) 2013 Apalya Technologies Pvt. Ltd. All rights reserved.
//

#ifndef Myplex_Messages_h
#define Myplex_Messages_h

#define kAppTitle @"Viva"

#define kVideoFeedNotAvailableMessage @"unable to contact Viva servers; please provide feedback in settings."

#define kWIFINotEnabledMessage @"wifi is required for downloading %@ movie; you may change this in settings"

#define kNetworkNotAvailableMessage @"no internet connection. showing cached data."

#define kDRMPlayMessage @"unable to play movie due to drm error %d; please provide feedback in settings"

#define kAuthenticationMessage @"must login to access this section"

#define kDeleteCardTitle @"removed %@ card temporarily from the view"

#define kDeleteCardMessage @"remove %@ from the view?"

#define kNoDownloadsMessage @"no downloads yet ... \n let's start one by renting or buying a movie"

#define kPurchaseSuccessfulMessage @"your payment for %@ is successful"

#define kGPlusLoginErrorMessage @"error logging in; please provide feedback in settings"

#define kUserIdEmptyMessage @"enter valid email address"

#define kInvalidEmailMessage @"email address is invalid. please try again"

#define kPasswordStrengthMessage @"password must be at least 6 characters long and should contain atleast 1 captial letter, 1 number and 1 special character."

#define kLogoutMessage @"confirm logging out of Viva"

#define kShareMessage @"watching %@ %@ on Viva and enjoying the experience!" // Mail/Message

//#define kFacebookShareMessage @"watch tv or movies on myplex"
//
//#define kTwitterShareMessage @"watch tv or movies on myplex"
//
//#define kGPlusShareMessage @"watch tv or movies on myplex"

#define kShareURL @"http://www.myplex.com"

#define kDownloadPrgoressMessage @"downloading %@"

#define kSearchQueryNotFound @"no matches for %@ at the moment"

#define kDownloadDRMRightsPending @"downloaded %@; acquiring license"

#define kDownloadCopyingToMyplexSpace @"making %@ available for playing"

#define kDownloadPlay @"ready to play %@ online or offline"

#define kLowDiskSpace @"need %.2f GB space to download %@; please free up space on your device"

//Auto Login Messages
#define kPurchaseSuccessMessageWhenNotLoggedIn @"your payment for %@ is successful. login to access your purchases in other devices"

#define kAutoLoginFailureMessage @""

#define kPurchaseValidation @"verifying purchase, please wait..."


#define BLog(formatString, ...) NSLog((@"%s " formatString), __PRETTY_FUNCTION__, ##__VA_ARGS__);

#ifndef UseTryCatch
#define UseTryCatch 1
#ifndef UsePTMName
#define UsePTMName 0  //USE 0 TO DISABLE AND 1 TO ENABLE PRINTING OF METHOD NAMES WHERE EVER TRY CATCH IS USED
#if UseTryCatch
#if UsePTMName
#define TCSTART @try{NSLog(@"\n%s\n",__PRETTY_FUNCTION__);
#else
#define TCSTART @try{
#endif
#define TCEND  }@catch(NSException *e){NSString *exceptionString = [NSString stringWithFormat:@"\n\n\n\n\n\n\
\n\n|EXCEPTION FOUND HERE...PLEASE DO NOT IGNORE\
\n\n|FILE NAME         %s\
\n\n|LINE NUMBER       %d\
\n\n|METHOD NAME       %s\
\n\n|EXCEPTION REASON  %@\
\n\n\n\n\n\n\n",strrchr(__FILE__,'/'),__LINE__, __PRETTY_FUNCTION__,e]; NSLog(@"%@",exceptionString);[AppDelegate writeLog:exceptionString];};
#else
#define TCSTART {
#define TCEND   }
#endif
#endif
#endif

#endif

#define isIPhone if ([[UIDevice currentDevice]  userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
