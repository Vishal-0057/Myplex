//
//  GetContentDetails.m
//  Myplex
//
//  Created by shiva on 10/4/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "GetContentDetails.h"
#import "ServerStandardRequest.h"
#import "AppData.h"

@implementation GetContentDetails {
    NSManagedObjectContext* _managedObjectContext;
}

- (id)initWithManagedObjectContext: (NSManagedObjectContext*)moc
{
	self = [super init];
	if (self) {
		_managedObjectContext = moc;
	}
	
	return self;
}

-(void)getContentDetailsWith:(NSString *)contentId fields:(NSString *)fields withCompletionHandler:(RequestContentDetailsWithCompletionHandler)completionHandler {
    
    //url
    //http://alpha.myplex.in:8866/content/v2/contentDetail/156/?clientKey=c86f79514ec7976bd20de36f1c6f15900d8e09f699818024283bad1bf0609650&query=*&fields=videos
   
    NSString *path = [NSString stringWithFormat:@"%@/%@?",@"content/contentDetail",contentId];
    
    NSDictionary *params = @{@"clientKey":[AppData shared].clientKey, @"query":@"*", @"fields":fields};
    
    //When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:path jsonData:params requestType:ServerStandardRequestTypeRead completionHandler:^(id jsonResponse, NSError* error) {
        
        if (error) {
            completionHandler(NO, nil,error);
        } else {
            
            if ([jsonResponse[@"status"] isEqualToString:@"SUCCESS"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(YES,jsonResponse,nil); 
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^ {
                    completionHandler(NO,nil,error);
                });
            }
        }
    }];
}


@end
