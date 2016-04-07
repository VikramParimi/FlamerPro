//
//  InAppHelper.h
//  LDS WedList
//
//  Created by Jignesh on 10/11/13.
//  Copyright (c) 2013 Jigs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


#define INAPP_PRODUCT_ONEDAYS    @"com.appdupe.Flamer.OneDay"
#define INAPP_PRODUCT_THREEDAYS  @"com.appdupe.Flamer.ThreeDays"
#define INAPP_PRODUCT_SEVENDAYS  @"com.appdupe.Flamer.SevenDay"


typedef enum {
    TransactionPurchasing=0,
    TransactionPurchased,
    TransactionRestored,
    TransactionFailed,
    TransactionNoProduct
} Transaction;

typedef void (^PurchaseResult)(Transaction result);
typedef void (^ProductResult)(BOOL result);

@interface InAppHelper : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
    SKProductsRequest *productsRequest;
    NSMutableDictionary *allValidProducts;
    BOOL isFetching;
    //blocks
    PurchaseResult dataBlock;
    ProductResult dataBlockProductResult;
}

+(InAppHelper *)sharedObject;

- (void)fetchAvailableProducts;
-(void)fetchAvailableProductsWithBlock:(ProductResult)block;
-(void)purchaseProduct:(NSString *)productName withBlock:(PurchaseResult)block;

/*
- (BOOL)canMakePurchases;
- (void)purchaseMyProduct:(SKProduct*)product;
*/



@end
