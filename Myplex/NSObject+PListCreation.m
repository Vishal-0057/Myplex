//
//  NSObject+PListCreation.m
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "NSObject+PListCreation.h"

@implementation NSObject (PListCreation)

+ (id)awakenFromPList: (NSString*)plist
{
	id obj = [[self alloc] init];
	
	NSString* plistPath = [[NSBundle mainBundle] pathForResource: plist ofType: @"plist"];
	NSDictionary* plistDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
	
	[obj setValuesForKeysWithDictionary:plistDict];
	
	return obj;
}


@end
