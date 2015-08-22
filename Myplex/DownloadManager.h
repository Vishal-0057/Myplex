//
//  DownloadManager.h
//  Myplex
//
//  Created by shiva on 11/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Download.h"    

@interface DownloadManager : NSObject <NSURLSessionDownloadDelegate>

typedef void (^DownloadTaskStartedHandler) (BOOL success, NSError *error);
typedef void (^DownloadTaskProgressHandler) (CGFloat progress, NSError *error);
typedef void (^DownloadTaskResumeHandler) (int64_t fileOffset, int64_t expectedTotalBytes);

typedef void (^DownloadTaskCompletionHandler) (CGFloat progress, NSString *identifier, NSURL *location,NSURLResponse *response, NSError *error);

@property (nonatomic, strong) Download *download;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) DownloadTaskCompletionHandler completionHandler;
@property (nonatomic, strong) DownloadTaskStartedHandler startedHandlerBlock;
@property (nonatomic, strong) DownloadTaskProgressHandler progressHandlerBlock;
@property (nonatomic, strong) DownloadTaskResumeHandler resumeHandlerBlock;

//@property (nonatomic, strong) NSDictionary *downloadParms;

-(void)startDownload:(NSDictionary * )downloadParams withCompletionHandler:(DownloadTaskCompletionHandler)completionHandler;
-(id)initWithManagedObjectContect:(NSManagedObjectContext *)managedObjectContex;
-(void)loadSession:(NSString *)identifier;

-(void)setStartedHandler:(DownloadTaskStartedHandler)startedHandler;
-(void)setProgressHandler:(DownloadTaskProgressHandler)progressHandler;
-(void)setResumeHandler:(DownloadTaskResumeHandler)resumeHandler;
@end
