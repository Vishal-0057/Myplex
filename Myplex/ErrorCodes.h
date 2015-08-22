//
//  ErrorCodes.h
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "NSError+Utils.h"


#define kGenericErrors @"tv.myplex.GenericError"
#define kGenericErrorInvalidManagedContext 990
#define kGenericErrorInvalidParameter 991
#define kGenericErrorInvalidOperation 992

#define kServerErrors @"tv.myplex.ServerError"
#define kServerErrorNotAuthorized 1001
#define kServerErrorGeneric 1002

#define kAccountCreationErrors @"tv.myplex.AccountCreationError"
#define kAccountCreationErrorGeneric 3001
#define kAccountCreationErrorInvalidPasswordChoice 3002

#define kStoreErrors @"tv.myplex.StoreError"
#define kStoreErrorPaymentsNotEnabled 4001
