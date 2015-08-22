//
//  GetContentDetails.h
//  Myplex
//
//  Created by shiva on 10/4/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RequestContentDetailsWithCompletionHandler)(BOOL success, NSDictionary *response, NSError *error);

@interface GetContentDetails : NSObject

-(id)initWithManagedObjectContext: (NSManagedObjectContext*)moc;

-(void)getContentDetailsWith:(NSString *)contentId fields:(NSString *)fields withCompletionHandler:(RequestContentDetailsWithCompletionHandler)completionHandler;

@end
