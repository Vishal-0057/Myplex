//
//  UIImage+File.h
//  Myplex
//
//  Created by Igor Ostriz on 10/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (File)

- (BOOL)saveToPath:(NSString *)name;

@end


@interface UIImageView (File)

- (BOOL)saveToPath:(NSString *)name;

@end

