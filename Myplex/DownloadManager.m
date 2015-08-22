//
//  DownloadManager.m
//  Myplex
//
//  Created by shiva on 11/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "DownloadManager.h"
#import "NSManagedObject+Utils.h"
#import "Notifications.h"
#import "AppDelegate.h"
#import "NSNotificationCenter+Utils.h"
#import "VideoPlayerViewController.h"
#import "ToastMessageView.h"

#if TARGET_CPU_ARM
#import "WViPhoneAPI.h"
#endif

static CFTimeInterval started;

@implementation DownloadManager {
    NSManagedObjectContext *_managedObjectContext;
    //NSMutableDictionary *_downloadsDict;
    AppDelegate *_appDelegate;
    UIBackgroundTaskIdentifier _saveBacgroundTaskIdentifier;
}

-(id)initWithManagedObjectContect:(NSManagedObjectContext *)managedObjectContext {
    TCSTART
    static DownloadManager *downloadManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager = [super init];
        if (self) {
            _appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            _managedObjectContext = managedObjectContext;
           // _downloadsDict = [[NSMutableDictionary alloc]init];
        }
    });
    
    return downloadManager;
    TCEND
}

-(void)setStartedHandler:(DownloadTaskStartedHandler)startedHandler {
    self.startedHandlerBlock = startedHandler;
}

-(void)setProgressHandler:(DownloadTaskProgressHandler)progressHandler {
    self.progressHandlerBlock = [progressHandler copy];
}

-(void)setResumeHandler:(DownloadTaskResumeHandler)resumeHandler {
    self.resumeHandlerBlock = [resumeHandler copy];
}

-(void)startDownload:(NSDictionary * )downloadParams withCompletionHandler:(DownloadTaskCompletionHandler)completionHandler {
    TCSTART
    self.completionHandler = [completionHandler copy];
    //self.downloadParms = [downloadParams copy];
    
    [self loadSession:downloadParams[@"contentId"]];
    
    self.download = (Download *)[Download fetchByRemoteId:downloadParams[@"contentId"] context:_managedObjectContext];

    if (self.download && self.download.downloading.boolValue) {
        return;
    }
    
    NSURLSessionDownloadTask *getDownloadTask = nil;

    if (self.download && self.download.paused.boolValue && self.download.resumeData) {
    [AppDelegate writeLog:@"Download Resumed.......\n"];
        getDownloadTask = [self.session downloadTaskWithResumeData:self.download.resumeData];
    } else {
        [AppDelegate writeLog:@"Download Initiated.......\n"];
        getDownloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:downloadParams[@"urlString"]]];
    }
    
    if (getDownloadTask) {
        [getDownloadTask resume];
        //[[NSUserDefaults standardUserDefaults]setObject:downloadParams[@"contentId"] forKey:[NSString stringWithFormat:@"%d",getDownloadTask.taskIdentifier]];
        started = CFAbsoluteTimeGetCurrent();
        //dispatch_async(dispatch_get_main_queue(), ^{
            //self.startedHandlerBlock(YES,nil);
        [self performSelectorOnMainThread:@selector(didDownloadStart:) withObject:downloadParams waitUntilDone:NO];
       // });
    }
    TCEND
}

-(void)didDownloadStart:(id)downloadParams {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
#if DEBUG
    NSLog(@"Started Downloading....");
#endif
    ToastMessageView *toastMessageView = [[ToastMessageView alloc]initWithFrame:CGRectMake(0, 0, appDelegate.window.frame.size.width, 50)];
    [appDelegate.window addSubview:toastMessageView];
    [toastMessageView showForegroundNotificationBanner:[NSString stringWithFormat:@"Downloading %@",downloadParams[@"name"]]];
    
    id downloadData = @{@"waiting":[NSNumber numberWithBool:NO],@"downloading":[NSNumber numberWithBool:YES],@"paused":[NSNumber numberWithBool:NO],@"remoteId":downloadParams[@"contentId"],@"videoName":downloadParams[@"name"],@"image":downloadParams[@"image"]?:@"",@"sourcePath":downloadParams[@"urlString"],@"destinationPath":downloadParams[@"destinationpath"]?:@""};
    [Download updateOrCreateFromJSONData:downloadData inContext:_managedObjectContext uniqueSanitizedKey:@"remoteId" save:YES];
    
    NSLog(@"Updating download status....");
    
    [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationDownloadStarted object:nil];
}

-(void)loadSession:(NSString *)identifier {
    TCSTART
    self.session = [self backgroundSessionWithIdentifier:identifier];
    if (self.session) {
        [AppDelegate writeLog:@"Session initiated......\n"];
    }
    TCEND
}

- (NSURLSession *)backgroundSessionWithIdentifier:(NSString *)identifier
{
    TCSTART
    /*
     Using disptach_once here ensures that multiple background sessions with the same identifier are not created in this instance of the application. If you want to support multiple background sessions within a single process, you should create each session with its own identifier.
     */
    
    static NSURLSession *session_ = nil;
	//static dispatch_once_t onceToken;
	//dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:identifier];
        configuration.allowsCellularAccess = NO;
        //configuration.timeoutIntervalForRequest = 45.0f;
        //configuration.timeoutIntervalForResource = 120.0f;
		session_ = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	//});
	return session_;
    TCEND
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    TCSTART
   // NSLog(@"wrote an additional %lld bytes (total %lld bytes) out of an expected %lld bytes.\n",bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    
    //NSString *uniqueIdentifier = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%d",downloadTask.taskIdentifier]];
    
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
#if DEBUG
    NSThread *currentThread = [NSThread currentThread];
    if (currentThread == [NSThread mainThread]) {
        NSLog(@"mainthread");
    }
    //NSLog(@"Progress: %.2f%% for content: %@",progress ,session.configuration.identifier);
#endif
    dispatch_async(dispatch_get_main_queue(), ^{
                
        [AppDelegate writeLog:[NSString stringWithFormat:@"Download Progress %f.......\n",progress]];
        [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationRefreshSomething object:[NSNumber numberWithFloat:progress]];
        //self.progressHandlerBlock(progress,nil);
    });
    TCEND
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    TCSTART
#if DEBUG
    NSLog(@"Session %@ download task %@ resumed at offset %lld bytes out of an expected %lld bytes.\n",
          session, downloadTask, fileOffset, expectedTotalBytes);
#endif
    dispatch_async(dispatch_get_main_queue(), ^{

        [AppDelegate writeLog:[NSString stringWithFormat:@"Download Resumed at offset %lld.......\n",fileOffset]];

        self.resumeHandlerBlock(fileOffset,expectedTotalBytes);
    });
    TCEND
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    TCSTART
    [AppDelegate writeLog:[NSString stringWithFormat:@"Download didCompleteWithError %@.......\n",error]];
    if (error == nil)
    {
#if DEBUG
        NSLog(@"Task: %@ completed successfully", task);
#endif
    }
    else
    {
#if DEBUG
        NSLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
#endif
        
        [self performSelectorOnMainThread:@selector(downloadDidCompleteWithError:) withObject:@{@"session": session,@"task":task,@"error":error} waitUntilDone:YES];
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            //self.completionHandler(progress,session.configuration.identifier,nil,nil,error);
//        });
    }
    TCEND
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    TCSTART
#if DEBUG
    NSLog(@"Session %@ download task %@ finished downloading to URL %@\n",
          session, downloadTask, location);
#endif
    
    //double progress = (double)downloadTask.countOfBytesReceived / (double)downloadTask.countOfBytesExpectedToReceive;
    //[self performSelectorOnMainThread:@selector(didFinishDownloading:) withObject:@{@"session": session,@"downloadTask":downloadTask,@"location":location} waitUntilDone:YES];
    //NSThread *myThreadTemp = [[NSThread alloc] init];
    //[myThreadTemp start];
    //[self performSelectorInBackground:@selector(didFinishDownloading:) withObject:@{@"session": session,@"downloadTask":downloadTask,@"location":location}];
    //[self performSelector:@selector(didFinishDownloading:) onThread:myThreadTemp withObject:@{@"session": session,@"downloadTask":downloadTask,@"location":location} waitUntilDone:YES];
    
    [self didFinishDownloading:@{@"session": session,@"downloadTask":downloadTask,@"location":location}];
    
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        
//        //self.completionHandler(progress,session.configuration.identifier, location, nil, nil);
//    });
    
//    NSError *err = nil;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *cacheDir = [[NSHomeDirectory()
//                           stringByAppendingPathComponent:@"Library"]
//                          stringByAppendingPathComponent:@"Caches"];
//    NSURL *cacheDirURL = [NSURL fileURLWithPath:cacheDir];
//    if ([fileManager moveItemAtURL:location
//                             toURL:cacheDirURL
//                             error: &err]) {
//        NSLog(@"moved downloaded file to location %@",cacheDirURL);
//        /* Store some reference to the new URL */
//    } else {
//        NSLog(@"failed to move downloaded file to location %@ error:%@",cacheDirURL,err);
//        /* Handle the error. */
//    }
    TCEND
}

-(void)downloadDidCompleteWithError:(id)errorInfo {
    
    NSURLSession *session = errorInfo[@"session"];
    NSURLSessionTask *task = errorInfo[@"task"];
    NSError *error = errorInfo[@"error"];
    
    [AppDelegate writeLog:[NSString stringWithFormat:@"Update database when downloadDidCompleteWithError.......\n"]];

    double progress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
    
   // NSString *uniqueIdentifier = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%d",task.taskIdentifier]];
    [AppDelegate writeLog:[NSString stringWithFormat:@"UniqueIdentifier %@.......\n",session.configuration.identifier]];

    id downloadData = @{@"resumeData":[error userInfo][@"NSURLSessionDownloadTaskResumeData"]?:[NSNull null],@"paused":[NSNumber numberWithBool:YES],@"downloading":[NSNumber numberWithBool:NO],@"downloaded":[NSNumber numberWithBool:NO],@"downlodPercentage":[NSNumber numberWithFloat:progress],@"remoteId":session.configuration.identifier};
    
    //dispatch_sync(dispatch_get_main_queue(), ^{
        self.download = (Download *)[Download updateOrCreateFromJSONData:downloadData inContext:_appDelegate.managedObjectContext uniqueSanitizedKey:@"remoteId" save:YES];
    //});
   
    [AppDelegate writeLog:[NSString stringWithFormat:@"success updating database: downloading status %d, downloaded status %d, paused status %d for movie: %@.......\n",self.download.downloading.boolValue,self.download.downloaded.boolValue,self.download.paused.boolValue,session.configuration.identifier]];
    
    [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationDownloadPaused object:nil];
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        [_appDelegate checkAndStartDownloading];
    //});
}

-(void)didFinishDownloading:(id)downloadInfo {
    
        NSURLSession *session = downloadInfo[@"session"];
        //NSURLSessionDownloadTask *downloadTask = downloadInfo[@"downloadTask"];
        NSURL *location = downloadInfo[@"location"];
        
        [AppDelegate writeLog:[NSString stringWithFormat:@"Download didFinishDownloadingToURL %@.......\n",location]];
        if ([[UIApplication sharedApplication]applicationState] == UIApplicationStateBackground || [[UIApplication sharedApplication]applicationState] == UIApplicationStateInactive) {
            [self getMoreCPUTimeToFinishDownloadedDataSaving];
        }
        
        
        
        //NSString *uniqueIdentifier = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%d",downloadTask.taskIdentifier]];
        [AppDelegate writeLog:[NSString stringWithFormat:@"UniqueIdentifier %@.......\n",session.configuration.identifier]];
    
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.download = (Download *)[Download fetchByRemoteId:session.configuration.identifier context:_appDelegate.managedObjectContext];
            
            //Save the tempararyfile path, it will be useful incase background session is not able complete the copying file.
            id updateData = @{@"temporaryDestinationFilePath":location.path,@"remoteId":session.configuration.identifier,@"downloadedToTempDir":@YES};
            self.download = (Download *)[Download updateOrCreateFromJSONData:updateData inContext:_appDelegate.managedObjectContext uniqueSanitizedKey:@"remoteId" save:YES];
            
            [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationDownloadFinished object:nil];
        });
    
        [self callCompletionHandler];
    
//        [AppDelegate writeLog:[NSString stringWithFormat:@"Before Sleep.......\n"]];
//        sleep(10);
//        [AppDelegate writeLog:[NSString stringWithFormat:@"After Sleep about 60 Sec.......\n"]];
    
        [AppDelegate writeLog:[NSString stringWithFormat:@"Writing downloaded data to %@.......\n",self.download.destinationPath]];
        

        __block NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL success = [fileManager copyItemAtURL:location toURL:[NSURL fileURLWithPath:self.download.destinationPath] error:&error];
            if (success)
            {
                [AppDelegate writeLog:[NSString stringWithFormat:@"success writing downloaded data to %@ updating database.......\n",self.download.destinationPath]];
                TCSTART
                NSLog(@"updating database with complete status");
                id downloadData = @{@"temporaryDestinationFilePath":[NSNull null],@"paused":[NSNumber numberWithBool:NO],@"downloading":[NSNumber numberWithBool:NO],@"remoteId":session.configuration.identifier,@"downlodPercentage":[NSNumber numberWithFloat:100],@"downloaded":[NSNumber numberWithBool:YES],@"destinationPath":self.download.destinationPath};
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.download = (Download *)[Download updateOrCreateFromJSONData:downloadData inContext:_appDelegate.managedObjectContext uniqueSanitizedKey:@"remoteId" save:YES];
                    [AppDelegate writeLog:[NSString stringWithFormat:@"success updating database: downloading status %d, downloaded status %d.......\n",self.download.downloading.boolValue,self.download.downloaded.boolValue]];
                    
                    [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationDownloadFinished object:nil];
                    
                    VideoPlayerViewController *videoPlayerVC = [[VideoPlayerViewController alloc]init];
                    WViOsApiStatus initiazlizationStatus = [videoPlayerVC initializeWideVineWithProfile:self.download.profile streaming:NO contentId:self.download.remoteId];
                    if (initiazlizationStatus == WViOsApiStatus_OK) {
                        NSString *videoName = [self.download.videoName stringByReplacingOccurrencesOfString:@" " withString:@""];
                        [videoPlayerVC registerAsset:[NSString stringWithFormat:@"%@%@.wvm",videoName,self.download.remoteId]];
                        id updateData = @{@"drmRightsAcquired":@YES, @"remoteId":session.configuration.identifier};
                        self.download = (Download *)[Download updateOrCreateFromJSONData:updateData inContext:_appDelegate.managedObjectContext uniqueSanitizedKey:@"remoteId" save:YES];
                        [AppDelegate writeLog:[NSString stringWithFormat:@"success acuiring rights: downloading status %d, downloaded status %d drmRightAcqire status %d.......\n",self.download.downloading.boolValue,self.download.downloaded.boolValue,self.download.drmRightsAcquired.boolValue]];
                    }
                    
                    [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationDownloadFinished object:nil];
                    
                    //check for other waiting/paused downloads and start them.
                    [_appDelegate checkAndStartDownloading];
                });
                
                TCEND
            }
            else
            {
                TCSTART
                [AppDelegate writeLog:[NSString stringWithFormat:@"Failed writing downloaded data to %@. Error: %@.......\n",self.download.destinationPath,error]];
                /*
                 In the general case, what you might do in the event of failure depends on the error and the specifics of your application.
                 */
                dispatch_sync(dispatch_get_main_queue(), ^{

                    Download *download = (Download *)[Download fetchByRemoteId:session.configuration.identifier context:_appDelegate.managedObjectContext];
                    if (download) {
                        [_appDelegate.managedObjectContext deleteObject:download];
                    }
                
                    [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationDownloadFailed object:nil];
                });
                TCEND
            }
       // }];
        
        if ([[UIApplication sharedApplication]applicationState] == UIApplicationStateBackground || [[UIApplication sharedApplication]applicationState] == UIApplicationStateInactive) {
            [self endSaveBackgroundTask];
        }
        //    });
}

-(void)getMoreCPUTimeToFinishDownloadedDataSaving {
    UIApplication *app = [UIApplication sharedApplication];
    _saveBacgroundTaskIdentifier = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:_saveBacgroundTaskIdentifier];
        _saveBacgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }];
    [AppDelegate writeLog:@"Started background task execution.......\n"];
}

-(void)endSaveBackgroundTask {
    if (_saveBacgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        
        [AppDelegate writeLog:@"Ended background task execution.......\n"];

        UIApplication *app = [UIApplication sharedApplication];
        [app endBackgroundTask:_saveBacgroundTaskIdentifier];
        _saveBacgroundTaskIdentifier = UIBackgroundTaskInvalid;
        
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
    TCSTART
    [AppDelegate writeLog:@"URLSessionDidFinishEventsForBackgroundURLSession.........\n"];

    [self callCompletionHandler];
    
    TCEND
}

-(void)callCompletionHandler {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.sessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.sessionCompletionHandler;
        appDelegate.sessionCompletionHandler = nil;
        [AppDelegate writeLog:@"URLSessionDidFinishEventsForBackgroundURLSession CompletionHandler called...... \n"];
        completionHandler();
    }
#if DEBUG
    NSLog(@"Task complete");
#endif
}

@end
