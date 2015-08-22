//
//  Analytics.h
//  Myplex
//
//  Created by shiva on 12/13/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef   enum   {Myplex} SIGNUP_TYPES;
#define SIGNUP_TYPES_STRING(enum) [@[@"myplex"] objectAtIndex:enum]
typedef   enum  {SignUpSuccess,SignUpFailure,clicked} SIGNUP_STATUS_TYPES;
#define SIGNUP_STATUS_TYPES_STRING(enum) [@[@"Success",@"Failure",@"Clicked"] objectAtIndex:enum]

typedef   enum   {FaceBook,Twitter,Google,myplex,Guest,ForgotPassword} LOGIN_TYPES;
#define LOGIN_TYPES_STRING(enum) [@[@"FaceBook",@"Twitter",@"Google",@"myplex",@"Guest",@"ForgotPassword"] objectAtIndex:enum]
typedef   enum  {Clicked,Success,Failure,Cancel} LOGIN_STATUS_TYPES;
#define LOGIN_STATUS_TYPES_STRING(enum) [@[@"Clicked",@"Success",@"Failure",@"Cancel"] objectAtIndex:enum]

typedef   enum  {SignOutSuccess,SignOutFailure,SignOutClicked,SignOutCancelled} SIGNOUT_STATUS_TYPES;
#define SIGNOUT_STATUS_TYPES_STRING(enum) [@[@"Success",@"Failure",@"Clicked",@"Cancel"] objectAtIndex:enum]

typedef   enum  {Cards,navigation,Filter} BROWSE_TYPES;
#define BROWSE_TYPES_STRING(enum) [@[@"Cards",@"navigation",@"Filter"] objectAtIndex:enum]
typedef   enum  {Delete,Swipe} BROWSE_CARDACTION_TYPES;
#define BROWSE_CARDACTION_TYPES_STRING(enum) [@[@"Delete",@"Swipe"] objectAtIndex:enum]
typedef   enum  {Profile,Favourites,Purchases,Downloads,Discover,Settings,Logout,Home,Movies,LiveTv,InviteFriends} BROWSE_NAVIGATION_TYPES;
#define BROWSE_NAVIGATION_TYPES_STRING(enum) [@[@"Profile",@"Favourites",@"Purchases",@"Downloads",@"Discover",@"Settings",@"Logout",@"Home",@"Movies",@"LiveTv",@"InviteFriends"] objectAtIndex:enum]

typedef   enum  {Favourite,Detailed,PlayTrailer,Share,movie} CONTENT_ACTION_TYPES;
#define CONTENT_ACTION_TYPES_STRING(enum) [@[@"Favourite",@"Detailed",@"PlayTrailer",@"Share",@"movie"] objectAtIndex:enum]
typedef   enum  {ShareFacebook,ShareGoogle,ShareMail,ShareMessage} CONTENT_SHARE_TYPES;
#define CONTENT_SHARE_TYPES_STRING(enum) [@[@"ShareFacebook",@"ShareGoogle",@"ShareMail",@"ShareMessage"] objectAtIndex:enum]

typedef   enum  {SearchDropDown,SearchDiscover,SearchFilter} SEARCH_TYPES;
#define SEARCH_TYPES_STRING(enum) [@[@"DropDown",@"Discover",@"Filter"] objectAtIndex:enum]
typedef   enum  {SearchSuccess,SearchFailure,SearchClicked} SEARCH_STATUS_TYPES;
#define SEARCH_STATUS_TYPES_STRING(enum) [@[@"Success",@"Failure",@"Clicked"] objectAtIndex:enum]

typedef   enum  {DropdownSuccess,DropdownFailure} DROPDOWN_STATUS_TYPES;
#define DROPDOWN_STATUS_TYPES_STRING(enum) [@[@"Success",@"Failure"] objectAtIndex:enum]

typedef   enum  {Start,End,Pause,Resume,Seek,Playing,SeekComplete,PlayerRightsAcquisition,Error} PLAY_CONTENT_STATUS_TYPES;
#define PLAY_CONTENT_STATUS_TYPES_STRING(enum) [@[@"Start",@"End",@"Pause",@"Resume",@"Seek",@"Playing",@"SeekComplete",@"PlayerRightsAcquisition",@"Error"] objectAtIndex:enum]

typedef   enum  {CreditCard,DebitCard,InternetBanking,OperatorBilling,InAppPurchase} PAY_MODEL_TYPES;
#define PAY_MODEL_TYPES_STRING(enum) [@[@"CreditCard",@"DebitCard",@"InternetBanking",@"OperatorBilling",@"InAppPurchase"] objectAtIndex:enum]
typedef   enum  {Rental,Buy} PAY_COMMERCIAL_TYPES;
#define PAY_COMMERCIAL_TYPES_STRING(enum) [@[@"Rental",@"Buy"] objectAtIndex:enum]
typedef   enum  {SD,HD} PAY_CONTENT_TYPES;
#define PAY_CONTENT_TYPES_STRING(enum) [@[@"SD",@"HD"] objectAtIndex:enum]
typedef   enum  {PayContentSuccessAtAppStore,PayContentFailureAtAppStore,PayContentSuccess,PayContentFailure,PayContentClicked} PAY_CONTENT_STATUS_TYPES;
#define PAY_CONTENT_STATUS_TYPES_STRING(enum) [@[@"SuccessAtAppStore",@"FailureAtAppStore",@"Success",@"Failure",@"Clicked"] objectAtIndex:enum]
typedef enum {InProgress,PayPackageScuccess,PayPackageFailure} PAY_PACKAGE_PURCHASE_STATUS;
#define PAY_PACKAGE_PURCHASE_STATUS_STRING(enum) [@[@"InProgress",@"Success",@"Failure"] objectAtIndex:enum]

typedef   enum  {tag} DISCOVER_STATUS_TYPES;
#define DISCOVER_STATUS_TYPES_STRING(enum) [@[@"tag"] objectAtIndex:enum]

#define EVENT_TIMED @"$time"

#define EVENT_LOGIN  @"Login"
#define EVENT_LOGIN_SOCIAL  @"LoginSocial"
#define EVENT_SIGNUP  @"Signup"
#define EVENT_SIGNOUT @"SignOut"
#define EVENT_BROWSE  @"Browse"
#define EVENT_SEARCH  @"Search"
#define EVENT_CONTENT  @"Content"
#define EVENT_PLAY  @"Play"
#define EVENT_PAY  @"Pay"
#define EVENT_SHARE  @"Share"
#define EVENT_CLICK  @"Click"

#define LOGIN_TYPE_PROPERTY  @"LoginType"
#define LOGIN_DATE_PROPERTY  @"LoginDate"
#define LOGIN_EMAIL_PROPERTY  @"LoginEmail"
#define LOGIN_STATUS_PROPERTY  @"LoginStatus"
#define LOGIN_STATUS_MESSAGE_PROPERTY  @"LoginMessage"
#define LOGIN_FORGOT_PASSWORD_PROPERTY  @"ForgotPassword"

#define LOGIN_SOCIAL_STATUS_PROPERTY @"LoginSocialStatus"

#define LOGIN_AS_GUEST  @"Guest"
#define LOGIN_FACEBOOK  @"FacebookLogin"
#define LOGIN_TWITTER  @"TwitterLogin"
#define LOGIN_GOOGLE  @"GoogleLogin"
#define LOGIN_CLICK  @"Click"

#define SIGNUP_TYPE_PROPERTY  @"SignupType"
#define SIGNUP_DATE_PROPERTY  @"SignupDate"
#define SIGNUP_EMAIL_PROPERTY  @"SignEmail"
#define SIGNUP_STATUS_PROPERTY  @"SignupStatus"
#define SIGNUP_STATUS_MESSAGE_PROPERTY  @"SignupMessage"

#define SIGNOUT_STATUS_PROPERTY @"SingoutStatus"

#define BROWSE_TYPE_PROPERTY  @"BrowseType"

#define SEARCH_TYPE_PROPERTY  @"SearchType"
#define SEARCH_FILTER_TYPE_PROPERTY  @"SearchFilterLabel"
#define SEARCH_NUMBER_FOUND_PROPERTY  @"NumberOfCardsFound"
#define SEARCH_QUERY_PROPERTY  @"SearchQuery"
#define SEARCH_SCREEN_PROPERTY  @"SearchScreen"
#define SEARCH_STATUS_PROPERTY  @"SearchStatus"

#define PLAY_CONTENT_ID_PROPERTY  @"ContentId Playing"
#define PLAY_CONTENT_NAME_PROPERTY  @"ContentName Playing"
#define PLAY_CONTENT_STATUS_PROPERTY  @"Content Play Status"
#define PLAY_CONTENT_START_TIME_PROPERTY  @"Content Start Time"
#define PLAY_CONTENT_END_TIME_PROPERTY  @"Content End Time"
#define PLAY_CONTENT_PAUSE_TIME_PROPERTY  @"Content Pause Time"
#define PLAY_CONTENT_RESUME_TIME_PROPERTY  @"Content Resume Time"
#define PLAY_CONTENT_SEEK_TIME_PROPERTY  @"Content Seek Time"
#define PLAY_CONTENT_ERROR_PROPERTY  @"ErrorMessage"
#define PLAY_CONTENT_WIDEVINE_ERROR  @"Widevine Authorization Failed"

#define PAY_STATUS_PROPERTY  @"PayStatus"
#define PAY_COMMERCIAL_TYPE_PROPERTY   @"PayCommercialType"
#define PAY_PACKAGE_ID  @"PackageId"
#define PAY_PACKAGE_NAME  @"PackageName"
#define PAY_PACKAGE_CHANNEL  @"PackageChannel"
#define PAY_PACKAGE_PURCHASE_STATUS  @"Status"

#define CONTENT_ID_PROPERTY  @"ContentId"
#define CONTENT_NAME_PROPERTY  @"ContentName"
#define CONTENT_TYPE_PROPERTY  @"ContentType"
#define CONTENT_CATEGORY_PROPERTY  @"ContentCategory"
#define CONTENT_DETAILS_PROPERTY  @"ContentDetails"
#define CONTENT_CARD_STATUS  @"ContentCardStatus"
#define CONTENT_CARD_OPENED  @"ContentCardExpanded"
#define CONTENT_CARD_FAVORITED  @"ContentCardFavorited"
#define CONTENT_CARD_DELETED  @"ContentCardDeleted"
#define CONTENT_CARD_DETAILS  @"ContentCardExpanded"
#define CONTENT_CARD_DETAILS_PROPERTY  @"ContentCardDescriptionExpanded"

@interface Analytics : NSObject

+(void)logEvent:(NSString *)event parameters:(NSDictionary *)params timed:(BOOL)timed;
+(void)endEvent:(NSString *)event parameters:(NSDictionary *)params;
+(void)setSuperProperties:(NSDictionary *)properties;

@end

