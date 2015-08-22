//
//  UIImage+File.m
//  Myplex
//
//  Created by Igor Ostriz on 10/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "UIImage+File.h"

@implementation UIImage (File)

- (BOOL)saveToPath:(NSString *)name
{
    NSString *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:name];
    BOOL rv = [UIImagePNGRepresentation(self) writeToFile:pngPath atomically:YES];
    if (rv) {
        NSLog(@"Error saving picture:%@", pngPath);
    }
    return rv;
}

@end


@implementation UIImageView (File)

- (BOOL)saveToPath:(NSString *)name
{
    UIGraphicsBeginImageContext(self.frame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image saveToPath:name];
}

@end
