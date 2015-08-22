//
//  UIFont+Replacement.m
//  MyPlex
//
//  Created by Igor Ostriz on 8/30/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <objc/runtime.h>

@interface UIFont (Replacement)
@end

@implementation UIFont (Replacement)

static NSDictionary *iBCustomFontsDict = nil;

+(void)load {
    iBCustomFontsDict = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"IBCustomFonts"];
    NSArray *methods = @[@"fontWithName:size:", @"fontWithName:size:traits:", @"fontWithDescriptor:size:"];
    for (NSString* methodName in methods) {
        Method from = class_getClassMethod([UIFont class], NSSelectorFromString(methodName)), to = class_getClassMethod([UIFont class], NSSelectorFromString([NSString stringWithFormat:@"new_%@",methodName]));
        if (from && to && strcmp(method_getTypeEncoding(from), method_getTypeEncoding(to)) == 0) method_exchangeImplementations(from, to);
    }
}
+(UIFont*)new_fontWithName:(NSString*)fontName size:(CGFloat)fontSize {
	return [self new_fontWithName:[iBCustomFontsDict objectForKey:fontName] ?: fontName size:fontSize];
}
+(UIFont*)new_fontWithName:(NSString*)fontName size:(CGFloat)fontSize traits:(int)traits {
	return [self new_fontWithName:[iBCustomFontsDict objectForKey:fontName] ?: fontName size:fontSize traits:traits];
}
+(UIFont*)new_fontWithDescriptor:(UIFontDescriptor*)descriptor size:(CGFloat)fontSize {
    
    return [self new_fontWithDescriptor:[UIFontDescriptor fontDescriptorWithName:[iBCustomFontsDict objectForKey:[descriptor.fontAttributes objectForKey:UIFontDescriptorNameAttribute]] ?: [descriptor.fontAttributes objectForKey:UIFontDescriptorNameAttribute] size:fontSize] size:fontSize];
}


@end
