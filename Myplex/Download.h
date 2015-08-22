//
//  Download.h
//  Myplex
//
//  Created by shiva on 11/26/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Download : NSManagedObject

@property (nonatomic, retain) NSString * destinationPath;
@property (nonatomic, retain) NSNumber * downloaded;
@property (nonatomic, retain) NSNumber * downloadedToTempDir;
@property (nonatomic, retain) NSNumber * drmRightsAcquired;
@property (nonatomic, retain) NSNumber * downloading;
@property (nonatomic, retain) NSNumber * downlodPercentage;
@property (nonatomic, retain) NSNumber * drmEnabled;
@property (nonatomic, retain) NSNumber * paused;
@property (nonatomic, retain) NSString * profile;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSData * resumeData;
@property (nonatomic, retain) NSString * sourcePath;
@property (nonatomic, retain) NSString * videoName;
@property (nonatomic, retain) NSNumber * waiting;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * temporaryDestinationFilePath;

@end
