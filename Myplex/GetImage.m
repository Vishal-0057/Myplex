//
//  GetImage.m
//  Myplex
//
//  Created by Igor Ostriz on 29/10/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "GetImage.h"
#import "Image+Utils.h"
#import "NSError+Utils.h"
#import "NSManagedObject+Utils.h"
#import "NSManagedObjectContext+Utils.h"
#import "ServerStreamingRequest.h"
#import "UIImage+Utils.h"

@implementation GetImage
{
    NSManagedObjectContext* _managedObjectContext;
}


+ (CGSize)getBrowseSize
{
    // TODO: return iPhone size, and iPad size respectively
    return CGSizeMake(612,358);//CGSizeMake(306,179);
}

+ (CGSize)getBrowseSize2
{
    // TODO: return iPhone size, and iPad size respectively
    return CGSizeMake(320,180);
}


- (id)initWithManagedObjectContext: (NSManagedObjectContext*)moc
{
	self = [super init];
	if (self) {
		_managedObjectContext = moc;
	}
	
	return self;
}

- (void)getImageWithURL:(NSString *)stringURL withPartialData:(void(^)(int received, int expected))partialBlock andCompletionHandler:(void (^)(NSData *, NSError *))completeBlock
{
    __block ServerStreamingRequest *request;
    request = [[ServerStreamingRequest alloc] initWithPath:stringURL jsonData:nil dataHandler:^(NSMutableData *data) {
        partialBlock([request.data length], request.expectedSize);
    } completionHandler:^(NSData *data, NSError *error) {
        if (error) {
            completeBlock(nil, error);
        } else {

            [_managedObjectContext performBlock:^{
                NSPredicate *p = [NSPredicate predicateWithFormat:@"url = %@", stringURL];
                NSArray *imgs = [_managedObjectContext fetchObjectsForEntityName:[Image entityName] withPredicate:p];
                
                UIImage *ui = [UIImage imageWithData:data];
                UIImage *uiSized = [ui imageByScalingDownAndCroppingForSize:[GetImage getBrowseSize]];
                //UIImage *uiSized2 = [ui imageByScalingDownAndCroppingForSize:[GetImage getBrowseSize2]];
                for (Image *img in imgs) {
                    img.content = UIImagePNGRepresentation(uiSized);//data;
                    //img.image = ui;
                    //img.browseImage = uiSized;
                    //img.browseImage2 = uiSized2;
                }
                
                
                NSError *error;
                [_managedObjectContext save:&error];
                [error logDetailedError];
                
                completeBlock(data, nil);
            }];
        }
    }];
}

@end
