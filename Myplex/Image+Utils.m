//
//  Image+Utils.m
//  Myplex
//
//  Created by Igor Ostriz on 9/30/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <objc/runtime.h>
#import "GetImage.h"
#import "Image+Utils.h"
#import "NSError+Utils.h"
#import "NSManagedObjectContext+Utils.h"
#import "NSNotificationCenter+Utils.h"
#import "StandardKeySanitizer.h"
#import "UIImage+Utils.h"
#import "GetImage.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"

@implementation Image (Utils)

static const NSString *croppedImageKey = @"croppedImage"; //The image is cropped to 306x179 for cardView image.

+ (id <RemoteKeySanitizer>)keySanitizer
{
    static StandardKeySanitizer *_sanitizer;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sanitizer = [[StandardKeySanitizer alloc] initWithKeys:@{
                                                                  @"link" : @"url",
                                                                  }];
    });
    
	return _sanitizer;
}

static const char* _key = "imageObject";
- (void)setImage:(UIImage *)image
{
    objc_setAssociatedObject(self, _key, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)image
{
    id img = objc_getAssociatedObject(self, _key);
    if (img == nil && self.content) {
        //dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            img = [UIImage imageWithData:self.content];
            [self setImage:img];
        //});
    }
    return img;
}

//static const char* _key2 = "browseImageObject";
- (UIImage *)browseImage
{
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    
    id img = [imageCache imageFromMemoryCacheForKey:[NSString stringWithFormat:@"%@%@",self.url,croppedImageKey]];
    
    //id img = objc_getAssociatedObject(self, _key2);
    if (img == nil && self.content) {
        //dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        img = [UIImage imageWithData:self.content];/*imageByScalingDownAndCroppingForSize:CGSizeMake(306,179)];
            */
        [self setBrowseImage:img];
        //});
    }
    return img;
}
- (void)setBrowseImage:(UIImage *)browseImage
{    
    [[SDImageCache sharedImageCache] storeImage:browseImage forKey:[NSString stringWithFormat:@"%@%@",self.url,croppedImageKey] toDisk:NO];
    //objc_setAssociatedObject(self, _key2, browseImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

-(void)getBrowseImageWithCompletionHandler:(void (^)(UIImage *browseImage))completionBlock {
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImage *browseImage = [self browseImage];
        dispatch_sync(dispatch_get_main_queue(), ^{
            completionBlock(browseImage);
        });
    });
}

static const char* _key2a = "browseImageObject2";
- (UIImage *)browseImage2
{
    id img = objc_getAssociatedObject(self, _key2a);
    if (img == nil && self.content) {
        //dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            img = [[UIImage imageWithData:self.content] imageByScalingDownAndCroppingForSize:CGSizeMake(320,180)];
            [self setBrowseImage2:img];
        //});
    }
    return img;
}

- (void)setBrowseImage2:(UIImage *)browseImage
{
    objc_setAssociatedObject(self, _key2a, browseImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}




static const char* _key3 = "downloading";
- (BOOL)downloading
{
    id dnld = objc_getAssociatedObject(self, _key3);
    if (dnld == nil) {
        dnld = [NSNumber numberWithBool:NO];
        [self setDownloading:NO];
    }
    return [dnld boolValue];
}
- (void)setDownloading:(BOOL)downloading
{
    objc_setAssociatedObject(self, _key3, [NSNumber numberWithBool:downloading], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)didTurnIntoFault
{
    objc_removeAssociatedObjects(self);
}


- (BOOL)isContainedIn:(NSSet *)setOfImages
{
    for (id obj in setOfImages) {
        if (![obj isKindOfClass:[Image class]]) {
            continue;
        }
        Image *other = (Image *)obj;
        if ([self.url isEqualToString:other.url]) {
            return YES;
        }
    }
    return NO;
}


static id _lock;
static NSMutableDictionary *_downloadingImages;
+ (NSDictionary *)downloadingImages
{
    return _downloadingImages;
}

+ (void)clearCacheIfPossible
{
    @synchronized(_lock) {
        NSMutableArray *removeKeys = [NSMutableArray array];
        [_downloadingImages enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSDictionary *d = obj;
            if ([d[@"downloaded"] floatValue] == [d[@"expected"] floatValue]) {
                [removeKeys addObject:key];
            }
        }];
        [_downloadingImages removeObjectsForKeys:removeKeys];
    }
}

+ (void)postImageDownloadProgress
{
    __block float rv = 0;
    @synchronized(_lock) {
        [_downloadingImages enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSDictionary *d = obj;
            rv = rv + [d[@"downloaded"] floatValue] / [d[@"expected"] floatValue];
            rv /= 2;
        }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardImageProgressBar
                                                                    object:nil
                                                                  userInfo: @{
                                                                              @"progress":[NSNumber numberWithFloat:rv]
                                                                              }
     ];
}




- (void)fetchImage
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadingImages = [NSMutableDictionary new];
    });
    
    if (self.content || self.downloading) {
        return;
    }
    
    __block NSString *key = self.url;
    @synchronized(_lock) {
        if ([[_downloadingImages allKeys] containsObject:self.url] || !key)
            return;
        
        _downloadingImages[key] = @{@"downloaded":@0, @"expected":@40000}; // estimated size
        self.downloading = YES;
    }
    
#ifdef DEBUG
    NSLog(@"***** Downloading image:%p, owner:%p, url:%@\n", self, self.owner, self.url);
#endif

    __block NSManagedObjectContext *tmp = [NSManagedObjectContext childUIManagedObjectContext];
    
    SDWebImageManager *imageManager = [SDWebImageManager sharedManager];
    [imageManager downloadWithURL:[NSURL URLWithString:key] options:SDWebImageRefreshCached progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
        
        if (error) {
            if (self.content)
                return;
            
            [_downloadingImages removeObjectForKey:key];
        }
        
#ifdef DEBUG
        NSLog(@"///// Downloaded image:%p, owner:%p\n      %@", self, self.owner, self.url);
#endif
        
        if (!error) {
            //dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                //NSData *data = UIImagePNGRepresentation(image);
                //UIImage *ui = [UIImage imageWithData:data];
                UIImage *uiSized = [image imageByScalingDownAndCroppingForSize:[GetImage getBrowseSize]];
                self.browseImage = uiSized;

                self.content = UIImagePNGRepresentation(uiSized);
                [tmp savePropagateWait];
                
                
                
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardImageDownloaded object:self userInfo:@{@"url":key}
                 ];
            });
        }
        self.downloading = NO;
    }];
    
//    GetImage *getter = [[GetImage alloc] initWithManagedObjectContext:tmp];
//    [getter getImageWithURL:key withPartialData:^(int received, int expected) {
//
//        @synchronized(_lock) {
//            _downloadingImages[key] = @{@"downloaded":[NSNumber numberWithInt:received], @"expected":[NSNumber numberWithInt:expected]};
//        }
//        //[Image postImageDownloadProgress];
//        
//    } andCompletionHandler:^(NSData *data, NSError *error) {
//        
//        // completed download
//        if (error) {
//            // do something with error here
//            if (self.content)
//                return;
//            
//            [_downloadingImages removeObjectForKey:key];
//            // do something with error here
////            data = UIImagePNGRepresentation([UIImage imageNamed:@"logowhite"]);
////            [self.managedObjectContext performBlockAndWait:^{
////                self.content = data;
////                [self.managedObjectContext savePropagate];
////            }];
//        }
//        
//#ifdef DEBUG
//        NSLog(@"///// Downloaded image:%p, owner:%p\n      %@", self, self.owner, self.url);
//#endif
//        
//        [tmp savePropagateWait];
//        
//        if (!error) {
//
//            UIImage *ui = [UIImage imageWithData:data];
//            UIImage *uiSized = [ui imageByScalingDownAndCroppingForSize:[GetImage getBrowseSize]];
//            //UIImage *uiSized2 = [ui imageByScalingDownAndCroppingForSize:[GetImage getBrowseSize2]];
//            //self.image = ui;
//           // isIPhone
//                self.browseImage = uiSized;
////            else
////                self.browseImage = ui;
//            //self.browseImage2 = uiSized2;
//            
//            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardImageDownloaded object:self userInfo:@{@"url":key}
//             ];
//        }
//        
//        self.downloading = NO;
//        //[Image postImageDownloadProgress];
//    }];
}


- (UIImage *)cropImage:(UIImage *)image fromRect:(CGRect)rect {
    // NSLog(@"cropImage start");
    CGFloat scale = [[UIScreen mainScreen] scale];
    rect.origin.x = 7.0f;//leaves 7px from left and 7px from right.
    rect.origin.y = 1.0f;//leaves 1px from top and 1px from bottom
    if (scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * scale,
                          rect.origin.y * scale,
                          rect.size.width * scale,
                          rect.size.height * scale);
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage],rect);
    image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    //NSLog(@"cropImage end");
    return image;
}



@end
