//
//  Subscribe.m
//  Myplex
//
//  Created by shiva on 10/4/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "Subscribe.h"
#import "ServerStandardRequest.h"
#import "AppData.h"
#import "NSManagedObject+Utils.h"

@implementation Subscribe

- (id)initWithManagedObjectContext: (NSManagedObjectContext*)moc
{
	self = [super init];
	if (self) {
		_managedObjectContext = moc;
	}
	
	return self;
}

-(void)subscribe:(NSString *)packageId reiept:(NSString *)reciept withCompletionHandler:(RequestSubscriptionWithCompletionHandler)completionHandler;
{
    
    //http://api.beta.myplex.in/user/v2/billing/subscribe/?clientKey=dcb11454ccdafdd4706c7186d37abd2ff96cd02dc998d1111d16d4778a797f85&paymentChannel=INAPP&packageId=P001&receiptData=ABCD
    
    NSString *path = @"user/billing/subscribe/";
    
    NSDictionary *params = @{@"clientKey":[AppData shared].clientKey,@"paymentChannel":@"INAPP",@"packageId":packageId, @"receiptData":reciept};
    
    //When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:path jsonData:params requestType:ServerStandardRequestTypeCreate completionHandler:^(id jsonResponse,NSError* error) {
        
        if (error) {
            completionHandler(NO, nil,error);
        } else {
            
            if ([jsonResponse[@"status"] isEqualToString:@"SUCCESS"]) {
                completionHandler(YES,jsonResponse,nil);
#if DEBUG
                NSLog(@"Purchase JsonResponse from server: %@",jsonResponse);
#endif
                //Content *content = (Content *)[Content fetchByRemoteId:package.contentId context:_managedObjectContext];
                //content addPurchases:,
            } else {
                completionHandler(NO,nil,error);
            }
        }
    }];
}

@end
