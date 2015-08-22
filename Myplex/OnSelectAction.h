//
//  OnSelectAction.h
//  Myplex
//
//  Created by Igor Ostriz on 31/10/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content;

@interface OnSelectAction : NSManagedObject

@property (nonatomic, retain) NSString * actionUrl;
@property (nonatomic, retain) NSString * feedbackOnAction;
@property (nonatomic, retain) NSString * feedbackOnImpress;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Content *owner;

@end
