//
//  ServerFileUploadRequest.h
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerDataUploadRequest : NSObject

- (id)initWithPath: (NSString*)path contentType: (NSString*)contentType data: (NSData*)data uploadProgressHandler: (void (^)(CGFloat))progress completionHandler: (void (^)(id, NSError*))completion;

@end
