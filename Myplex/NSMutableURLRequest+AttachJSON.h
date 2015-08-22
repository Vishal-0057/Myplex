//
//  ServerProtocolUtils.h
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (AttachJSON)

//- (void)attachJSONData: (NSDictionary*)jsonDict;
- (void)attachJSONDataUrlEncoded: (NSDictionary *)postDict;

@end
