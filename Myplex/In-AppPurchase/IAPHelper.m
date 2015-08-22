//
//  IAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

// 1
#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "NSManagedObject+Utils.h"
#import "UIAlertView+ReportError.h"
#import "Subscribe.h"
#import "AppDelegate.h"
#import "Purchase.h"
#import "NSManagedObjectContext+Utils.h"
#import "Notifications.h"
#import "NSNotificationCenter+Utils.h"

//NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
//NSString *const IAPHelperProductPurchaseFailureNotification = @"IAPHelperProductPurchaseFailureNotification";

static NSString *kProductIdentifier = @"com.apalya.myplexv1.";

NSInteger try = 0;

// 2
@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

// 3
@implementation IAPHelper {
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _productCompletionHandler;
    RequestPurchaseCompletionHandler _purchaseCompletionHandler;

    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

@synthesize prodcuts;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
//        _productIdentifiers = productIdentifiers;
//        
//        [self requestProductsWithCompletionHandler:^(BOOL success, NSArray *products_) {
//            if (success) {
//                self.prodcuts = products_;
//            }
//        }];
        
        // Add self as transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
    
}

//-(void)setProdcuts:(NSArray *)prodcuts_ {
//    if (prodcuts_.count > 0) {
//        self.prodcuts = prodcuts_; 
//    }
//}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    
    // 1
    _productCompletionHandler = [completionHandler copy];
    
    // 2
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

-(void)buyPackage:(NSString *)packageIdentifier withCompletionHandler:(RequestPurchaseCompletionHandler)completionHandler {
    
    _purchaseCompletionHandler = [completionHandler copy];
    
    __block BOOL isProductExistInITunesStore = NO;
    
    NSString *productId = [NSString stringWithFormat:@"%@%@",kProductIdentifier,packageIdentifier];

    // Store product identifiers
    _productIdentifiers = [NSSet setWithArray:@[productId]];
    
    [self requestProductsWithCompletionHandler:^(BOOL success, NSArray *products_) {
        if (success) {
            self.prodcuts = products_;
            for (SKProduct *product in  self.prodcuts) {
                if ([productId isEqualToString:product.productIdentifier]) {
                    [self buyProduct:product];
                    isProductExistInITunesStore = YES;
                    break;
                }
            }
            
            if (!isProductExistInITunesStore) { //For showing package doesn't exist in iTunes store.
                NSError *error = [NSError errorWithDomain:kStoreErrors andCode:kStoreErrorPaymentsNotEnabled andDescriptionKey:@"Selected pack cannot be subscribed using In-App Purchase." andUnderlying:0];
                [self callCompletionHandlerWithStatus:NO withResponse:nil withError:error];
            }

        } else {
            NSError *error = [NSError errorWithDomain:kStoreErrors andCode:kStoreErrorPaymentsNotEnabled andDescriptionKey:@"Fetching product failed. Please try again." andUnderlying:0];
            [self callCompletionHandlerWithStatus:NO withResponse:nil withError:error];
        }
    }];
}

- (void)buyProduct:(SKProduct *)product {
    
    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _productCompletionHandler(YES, skProducts);
    _productCompletionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _productCompletionHandler(NO, nil);
    _productCompletionHandler = nil;
    
}

#pragma mark SKPaymentTransactionOBserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [self callCompletionHandlerWithStatus:NO withResponse:transaction withError:transaction.error];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)provideContentForProductIdentifier:(SKPaymentTransaction *)transaction {
    
    //Validating receipt at client for testing.
    NSLog(@"Transaction identifier %@",transaction.transactionIdentifier);
    [self verifyReceipt:transaction];
    
    [_purchasedProductIdentifiers addObject:transaction.payment.productIdentifier];

    NSManagedObjectContext *managedObjectContext_ = [NSManagedObjectContext childUIManagedObjectContext];
    
    NSRange range = [transaction.payment.productIdentifier rangeOfString:kProductIdentifier];
    NSString *packageId = [transaction.payment.productIdentifier substringFromIndex:range.length];
    Package *package = (Package *)[Package fetchFirstObjectHaving:packageId forKey:@"packageId" inManagedObjectContext:managedObjectContext_];
    PAY_COMMERCIAL_TYPES payComericaltypes = Buy;
    if ([self isNotNull:package.commercialModel] && [package.commercialModel isEqualToString:@"Rental"]) {
        payComericaltypes = Rental;
    }else {
        payComericaltypes = Buy;
    }
    
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptUrl];
    
    Purchase *pur = (Purchase *)[Purchase modelFromJSONData:@{@"type":PAY_COMMERCIAL_TYPES_STRING(payComericaltypes),@"contentType":package.contentType,@"receipt":receipt,@"isReceiptValidated":@NO} forEntityName:[Purchase entityName] inContext:managedObjectContext_ keySanitizer:[Purchase keySanitizer]];
    
    //Add date at client side
//    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//    [dateComponents setMonth:1];
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    
    NSArray *contents = [managedObjectContext_ fetchObjectsForEntityName:[Content entityName] withPredicate:[NSPredicate predicateWithFormat:@"ANY packages.packageId == %@", package.packageId]];
    //Content *content = (Content *)[Content fetchByRemoteId:package.contentId context:managedObjectContext_];
    for (Content *content in contents) {
        pur.content = content;
        
        if ([self isNotNull:package.packageId]) {
            pur.package = package;
        }
        content.purchased = [NSNumber numberWithBool:YES];
        NSError *error;
        if ([pur validateForInsertOrUpdate:&error]) {
            [content addPurchasesObject:pur];
        }
    }
    
    NSError *error = nil;
    NSManagedObjectContext *temp = [NSManagedObjectContext tempManagedObjectContext];
    [temp savePropagateWait];
    if (!error) {
#if DEBUG
        NSLog(@"Purchase status updated");
#endif
    }
#if DEBUG
    NSLog(@"receipt Data is %@",[[NSString alloc]initWithData:receipt encoding:NSUTF8StringEncoding]);
#endif

    [self validateTheReceipt:receipt withPurchase:pur withPackage:package payComercialType:payComericaltypes];
}

-(void)validateTheReceipt:(NSData *)receipt withPurchase:(Purchase *)pur withPackage:(Package *)package payComercialType:(PAY_COMMERCIAL_TYPES)payCommercialTypes {
    
    NSManagedObjectContext *managedObjectContext_ = [NSManagedObjectContext childUIManagedObjectContext];

    Subscribe *subscribe = [[Subscribe alloc]initWithManagedObjectContext:managedObjectContext_];
    [subscribe subscribe:package.packageId reiept:[receipt base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn] withCompletionHandler:^(BOOL success, NSDictionary *jsonResponse, NSError *error) {
#if DEBUG
        NSLog(@"In-App response from server %@",jsonResponse);
#endif
        if (success) {
            [Analytics logEvent:EVENT_PAY parameters:@{PAY_STATUS_PROPERTY: PAY_CONTENT_STATUS_TYPES_STRING(PayContentSuccess),PAY_PACKAGE_PURCHASE_STATUS:PAY_PACKAGE_PURCHASE_STATUS_STRING(InProgress),PAY_PACKAGE_ID:package.packageId,PAY_PACKAGE_NAME:package.packageName,PAY_PACKAGE_CHANNEL:PAY_COMMERCIAL_TYPES_STRING(payCommercialTypes)} timed:YES];
            
            
            pur.isReceiptValidated = @YES;
            
            [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationPurchaseSuccess object:nil];
            [self callCompletionHandlerWithStatus:YES withResponse:nil withError:nil];
            
        } else {
            [Analytics logEvent:EVENT_PAY parameters:@{PAY_STATUS_PROPERTY: PAY_CONTENT_STATUS_TYPES_STRING(PayContentFailure),PAY_PACKAGE_PURCHASE_STATUS:PAY_PACKAGE_PURCHASE_STATUS_STRING(InProgress),PAY_PACKAGE_ID:package.packageId,PAY_PACKAGE_NAME:package.packageName?:@"",PAY_PACKAGE_CHANNEL:PAY_COMMERCIAL_TYPES_STRING(payCommercialTypes)} timed:YES];
            
            if (try < 2) {
                try++;
                [self validateTheReceipt:receipt withPurchase:pur withPackage:package payComercialType:payCommercialTypes];
            } else {
                [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationPurchaseSuccess object:nil];

                [AppDelegate removeActivityIndicator];
            }
            //[self callCompletionHandlerWithStatus:NO withResponse:transaction withError:error];
        }
    }];
}

-(void)callCompletionHandlerWithStatus:(BOOL)success  withResponse:(SKPaymentTransaction *)transaction withError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_purchaseCompletionHandler) {
            _purchaseCompletionHandler(success,transaction,error);
        }
    });
}
- (void)verifyReceipt:(SKPaymentTransaction *)transaction {
    
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptUrl];
#if DEBUG
    NSLog(@"receipt Data is %@",[[NSString alloc]initWithData:receipt encoding:NSUTF8StringEncoding]);
#endif
    NSString *encodedRecieptString = [receipt base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    
    //NSString *encodedRecieptString = [self encode:(uint8_t *)transaction.transactionReceipt.bytes length:transaction.transactionReceipt.length];
    
    NSString *jsonObjectString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\", \"password\" : \"%@\"}",encodedRecieptString,@"60e27c47bde04defa427a3520b29475a"];
    NSLog(@"receipt Data String is %@",jsonObjectString);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[jsonObjectString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        NSLog(@"Connection successfull");
    }
}
//
//- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
//    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
//    
//    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
//    uint8_t *output = (uint8_t *)data.mutableBytes;
//    
//    for (NSInteger i = 0; i < length; i += 3) {
//        NSInteger value = 0;
//        for (NSInteger j = i; j < (i + 3); j++) {
//            value <<= 8;
//            
//            if (j < length) {
//                value |= (0xFF & input[j]);
//            }
//        }
//        
//        NSInteger index = (i / 3) * 4;
//        output[index + 0] =                    table[(value >> 18) & 0x3F];
//        output[index + 1] =                    table[(value >> 12) & 0x3F];
//        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
//        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
//    }
//    
//    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//}
//
#pragma mark NSURLConnection Delegate Methods.

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    receiptVerificationData = [[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receiptVerificationData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *receiptVerificationString = [[NSString alloc]initWithBytes:[receiptVerificationData bytes] length:receiptVerificationData.length encoding:NSUTF8StringEncoding];
    NSLog(@"receiptVerificationString %@",receiptVerificationString);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Receipt Validation didFailWithError %@",error);
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end