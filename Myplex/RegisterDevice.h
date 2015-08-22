//
//  RegisterDevice.h
//  Myplex
//
//  Created by shiva on 9/14/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegisterDevice : NSObject

- (id)initWithManagedObjectContext: (NSManagedObjectContext*)moc;
-(void)registerDeviceWithSerialNumber:(NSString *)serialNumber osName:(NSString *)osName osVersion:(NSString *)osVersion model:(NSString *)model resolution:(NSString *)resolution;

@end
