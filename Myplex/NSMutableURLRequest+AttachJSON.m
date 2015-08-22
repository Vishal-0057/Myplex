//
//  ServerProtocolUtils.m
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "NSMutableURLRequest+AttachJSON.h"

@implementation NSMutableURLRequest (AttachJSON)

- (void)attachJSONData: (NSDictionary*)jsonDict
{
	NSData* jsonData = [NSJSONSerialization dataWithJSONObject: jsonDict options: kNilOptions error: nil];
	
	static NSString* kContentType = @"application/json";
	
	[self setValue: kContentType forHTTPHeaderField :@"Accept"];
	[self setValue: kContentType forHTTPHeaderField: @"Content-Type"];
	[self setValue: [NSString stringWithFormat: @"%d", [jsonData length]] forHTTPHeaderField: @"Content-Length"];
	
	[self setHTTPBody: jsonData];
}

- (void)attachJSONDataUrlEncoded:(NSDictionary *)postDict {
    
    NSMutableArray *parts = [NSMutableArray new];
    
    if ([[self HTTPMethod] isEqualToString:@"GET"] && [[self.URL query] length]) {
        [parts addObject:self.URL.query];
    }
    
    for (NSString *key in postDict) {
        
        id encodedValue = postDict[key];
        
        if ([[key lowercaseString] isEqualToString:@"clientkey"]) {
            [self setValue:encodedValue forHTTPHeaderField:@"clientKey"];
        }
        else {
            NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
            [parts addObject:part];
        }
    }
    
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    NSData *postData = [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *postString = [[NSString alloc]initWithBytes:[postData bytes] length:[postData length] encoding:NSUTF8StringEncoding];

#ifdef DEBUG
    NSLog(@"Request Body %@",postString);
#endif
    
    static NSString* kContentType = @"application/x-www-form-urlencoded";
    
    [self setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self setValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [self setValue: kContentType forHTTPHeaderField: @"Content-Type"];

    if ([[self HTTPMethod] isEqualToString:@"GET"]) {
        NSString *absURL = [[self.URL absoluteString] componentsSeparatedByString:@"?"][0];
        if ([postString length])
            self.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", absURL, [postString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        else
            self.URL = [NSURL URLWithString:absURL];
        
    }
    else {
        [self setValue: [NSString stringWithFormat: @"%d", [postData length]] forHTTPHeaderField: @"Content-Length"];
        [self setHTTPBody:postData];
    }
}

@end
