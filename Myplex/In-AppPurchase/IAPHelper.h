//
//  IAPHelper.h
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import <StoreKit/StoreKit.h>

//UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
//UIKIT_EXTERN NSString *const IAPHelperProductPurchaseFailureNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);
typedef void (^RequestPurchaseCompletionHandler)(BOOL success, SKPaymentTransaction *transaction, NSError *error);

@interface IAPHelper : NSObject {
    NSMutableData *receiptVerificationData;
}

@property (nonatomic,retain) NSArray *prodcuts;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
-(void)buyPackage:(NSString *)packageIdentifier withCompletionHandler:(RequestPurchaseCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

@end