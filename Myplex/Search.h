//
//  Search.h
//  Myplex
//
//  Created by shiva on 9/19/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Search : NSObject

- (id)initWithManagedObjectContext: (NSManagedObjectContext*)moc;
- (void)getTagsWithCategory: (NSString*)category qualifier: (NSString*)qualifier numPerQualifier: (NSString*)numPerQualifier startLetter:(NSString *)startLetter numStartLetter:(NSString *)numStartLetter clientKey:(NSString *)clientKey;
-(void)searchWithQuery:(NSString *)query inline:(NSNumber *)inline_ where:(NSString *)where clientKey:(NSString *)clientKey;

@end
