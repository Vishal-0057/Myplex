//
//  AppData.m
//  slide2me
//
//  Created by Igor Ostriz on 7/27/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "AppData.h"

@implementation AppData

+ (AppData *)shared
{
    static AppData *_appdata;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _appdata = [[AppData alloc] init];
        [_appdata load];
    });
    
    return _appdata;
}

+ (NSString *)path
{
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"AppData.plist"];
    return destPath;
}

+ (void)load
{
    NSString *destPath = AppData.path;
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];

    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"AppData" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
}

- (void)load
{
    _data = [NSMutableDictionary dictionaryWithContentsOfFile:AppData.path];
}

- (void)save
{
    [_data writeToFile:AppData.path atomically:YES];
}


- (NSString *)clientKey
{
    NSString *clientKey = [[NSBundle mainBundle] infoDictionary][@"ClientKey"];
    if ([clientKey length]) {
        return clientKey;
    }
    return _data[@"clientKey"];
}

- (void)setClientKey:(NSString *)clientKey
{
    _data[@"clientKey"] = clientKey;
}





@end
