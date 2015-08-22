//
//  Notifications.h
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

//Device Registration
__unused static NSString* kNotificationDeviceRegistered = @"deviceRegistered";
__unused static NSString* kNotificationDeviceRegisterError = @"deviceRegistrationRequestFailure";

//User Registration
__unused static NSString* kNotificationUserCreated = @"userCreated";
__unused static NSString* kNotificationUserCreateError = @"userCreateRequestFailure";

//GuestUser Registration
__unused static NSString* kNotificationGuestUserCreated = @"guestUserCreated";
__unused static NSString* kNotificationGuestUserCreateError = @"guestUserCreateRequestFailure";

//User Authentication
__unused static NSString* kNotificationUserAuthenticated = @"userAuthenticated";
__unused static NSString* kNotificationLoginError = @"userAuthenticationRequestFailure";

//User RetrievePassword
__unused static NSString* kNotificationRetrievePassword = @"passwordSent";
__unused static NSString* kNotificationRetrievePasswordError = @"RetrievePasswordRequestFailure";

//User SignOut
__unused static NSString* kNotificationSignedOut = @"loggedOut";
__unused static NSString* kNotificationSignOutError = @"logOutRequestFailure";

//Get Profile
__unused static NSString* kNotificationGetProfile = @"getProfile";
__unused static NSString* kNotificationGetProfileError = @"getProfileError";

//Search Tags
__unused static NSString* kNotificationSearchTagsFetched = @"searchTagsFetch";
__unused static NSString* kNotificationSearchTagsFetchingError = @"searchTagsFetchingFailure";

//Search Query
__unused static NSString* kNotificationSearchQueryFetched = @"searchQueryFetch";
__unused static NSString* kNotificationSearchQueryFetchingError = @"searchQueryFetchingFailure";

//Download
__unused static NSString* kNotificationDownloadStarted = @"DownloadStarted";
__unused static NSString* kNotificationDownloadPaused = @"DownloadPaused";
__unused static NSString* kNotificationDownloadResumed = @"DownloadResumed";
__unused static NSString* kNotificationDownloadFinished = @"DownloadFinished";
__unused static NSString* kNotificationDownloadFailed = @"DownloadFailed";

__unused static NSString* kNotificationRefreshSomething = @"refreshSomething";

__unused static NSString* kNotificationShowActivityIndicator = @"activityindicator";

__unused static NSString* kNotificationPurchaseSuccess = @"purchasesuccess";

__unused static NSString* kNotificationNetworkReachble = @"networkreachable";

__unused static NSString* kNotificationPlayerStatusUpdated = @"playerstatusupdated";

__unused static NSString* kNotificationFailedUpdatingPlayerStatus = @"playerstatusupdatefailed";

__unused static NSString* kNotificationPlayerStatusReceived = @"playerstatusreceived";

__unused static NSString* kNotificationFailedRetrievingPlayerStatus = @"failedretrievingplayerstatus";

// ... and so on


