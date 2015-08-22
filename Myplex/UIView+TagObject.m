//
//  UIView+tagObject.m
//  MyPlex
//
//  Created by Igor Ostriz on 4/19/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+TagObject.h"

@implementation UIView (TagObject)

static const char* _key = "taggedObject";


- (id)tagObject
{
    return objc_getAssociatedObject(self, _key);
}

- (void)setTagObject:(id)tagObject
{
    objc_setAssociatedObject(self, _key, tagObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

@end
