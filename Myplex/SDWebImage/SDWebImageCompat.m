//
//  SDWebImageCompat.m
//  SDWebImage
//
//  Created by Olivier Poitrey on 11/12/12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import "SDWebImageCompat.h"

#if !__has_feature(objc_arc)
#error SDWebImage is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

inline UIImage *SDScaledImageForKey(NSString *key, UIImage *image)
{
    if ([image.images count] > 0)
    {
        NSMutableArray *scaledImages = [NSMutableArray array];
        
        for (UIImage *tempImage in image.images)
        {
            [scaledImages addObject:SDScaledImageForKey(key, tempImage)];
        }
        
        return [UIImage animatedImageWithImages:scaledImages duration:image.duration];
    }
    else
    {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        {
            //Commented by Shiva, as there will not any @2x. image in the url (key).
            CGFloat scale = [[UIScreen mainScreen] scale];
            if (key.length >= 8)
            {
                // Search @2x. at the end of the string, before a 3 to 4 extension length (only if key len is 8 or more @2x. + 4 len ext)
                NSRange range = [key rangeOfString:@"@2x." options:0 range:NSMakeRange(key.length - 8, 5)];
                if (range.location != NSNotFound)
                {
                    scale = 2.0;
                }
            }
//#if DEBUG
//            NSLog(@"SourceImageWidth %f, SourceImageHeight %f",image.size.width,image.size.height);
//#endif
            UIImage *scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:1 orientation:image.imageOrientation];
//#if DEBUG
//            NSLog(@"scaledImageWidth %f, scaledImageHeight %f",scaledImage.size.width,scaledImage.size.height);
//#endif
            image = scaledImage;
        }
        return image;
    }
}
