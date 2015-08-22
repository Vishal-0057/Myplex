//
//  AppDelegate.h
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^RequestGenerateKeyWithCompletionHandler)(BOOL success, NSDictionary *response, NSError *error);

@interface AppDelegate : UIResponder <UIApplicationDelegate>
    

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readwrite) BOOL networkReachable;
@property (nonatomic, readwrite) BOOL synchronizeOnWIFI;
@property (nonatomic, readwrite) BOOL systemWifiEnabled;

@property (copy) void (^sessionCompletionHandler)();

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(BOOL)isClientKeyValid;
-(void)requestForClientKeyGenerationWithCompletionHandler:(RequestGenerateKeyWithCompletionHandler)completionHandler;
+(void)showActivityIndicatorWithText:(NSString*)text;
+(void)removeActivityIndicator;
-(void)showAlert:(NSString *)title withMessage:(NSString *)message;
- (NSString *)formatDateToString:(NSDate *)date;
-(void)checkAndStartDownloading;

-(void)cardSelectedWithStatus:(BOOL)subscribed drmEnabled:(BOOL)drmEnabled contentId:(NSString *)contentId title:(NSString *)title image:(NSString *)imagePath packageId:(NSString *)pacakgeId delegate:(id)delgate;
+(void)writeLog:(NSString *)logString;
-(void)initPlayerWithUrl:(NSString *)url contentId:(NSString *)contentId title:(NSString *)title profile:(NSString *)profile drmEnabled:(BOOL)drmEnabled streaming:(BOOL)streaming delegate:(id)delegate elapsedTime:(NSInteger)elapsedTime;
-(BOOL)isUserAuthenticated;
-(void)showAuthenticationMessage;
+(void)copyMovieAtURL:(NSURL *)sourceUrl toURL:(NSURL *)destUrl withCompletionHandler:(void (^) (BOOL success, NSError *error))completionBlock;

@end
