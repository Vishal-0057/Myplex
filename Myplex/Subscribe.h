//
//  Subscribe.h
//  Myplex
//
//  Created by shiva on 10/4/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RequestSubscriptionWithCompletionHandler)(BOOL success, NSDictionary *response, NSError *error);

@interface Subscribe : NSObject {
    NSManagedObjectContext* _managedObjectContext;
}

-(id)initWithManagedObjectContext: (NSManagedObjectContext*)moc;

-(void)subscribe:(NSString *)package reiept:(NSString *)reciept withCompletionHandler:(RequestSubscriptionWithCompletionHandler)completionHandler;

@end
