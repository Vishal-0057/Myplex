//
//  RelatedItem.m
//  Transitions
//
//  Created by Igor Ostriz on 10/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "Image+Utils.h"
#import "RelatedItem.h"
#import "UIImage+File.h"

static CGFloat defaultSize = 64;

@implementation RelatedItem


- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
//        UIImage *image = [UIImage imageNamed:name];
//        _image = image;
    }
    return self;
}

- (UIImage *)uiImage
{
    if (!_image) {
        return nil;
    }
    
    if (_image.content) {
        return [_image image];
    }
    else {
        [_image fetchImage];
    }
    
    return nil;
}


- (CGSize)size
{
    return CGSizeMake(defaultSize,defaultSize);

    // smaller dimension should be defaultSize
//    CGFloat ratio = _image.size.width / _image.size.height;
//    if (ratio < 1) ratio = 1./ratio;
//    
//    return CGSizeMake(_image.size.width < _image.size.height ? defaultSize : defaultSize*ratio, _image.size.height < _image.size.width ? defaultSize : defaultSize*ratio);
}

@end
