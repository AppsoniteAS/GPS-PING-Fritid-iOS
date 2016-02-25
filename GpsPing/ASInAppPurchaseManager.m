//
//  ASInAppPurchaseManager.m
//  GpsPing
//
//  Created by Maks Niagolov on 2/25/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASInAppPurchaseManager.h"
#import <StoreKit/StoreKit.h>
#import <CocoaLumberjack.h>
#import "NSDate+DateTools.h"

static DDLogLevel ddLogLevel = DDLogLevelDebug;

#define kYearlySubscriptionProductIdentifier @"Yearly_subscription"

@interface ASInAppPurchaseManager() <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end

@implementation ASInAppPurchaseManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    NSDate *date = [[NSUserDefaults standardUserDefaults] valueForKey:@"areSubscribedAtDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.areSubscribed = [[[NSDate date] dateBySubtractingYears:1] isEarlierThan:date];
}

- (void)subscribe {
    DDLogDebug(@"User requests to subscribe");
    
    if([SKPaymentQueue canMakePayments]){
        DDLogDebug(@"User can make payments");
        
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kYearlySubscriptionProductIdentifier]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        DDLogDebug(@"User cannot make payments due to parental controls");
    }
}

- (void)restore {
    DDLogDebug(@"User requests to restore subscribtion");
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    if([response.products count] > 0){
        validProduct = [response.products objectAtIndex:0];
        DDLogDebug(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        DDLogDebug(@"No products available");
    }
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)doSubcribeWithDate:(NSDate*)date {
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"areSubscribedAtDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUbiquitousKeyValueStore defaultStore] setObject:date forKey:@"areSubscribedAtDate"];
    [self.delegate openConnect];
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    DDLogDebug(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            DDLogDebug(@"Transaction state -> Restored");
            [self doSubcribeWithDate:[[NSUbiquitousKeyValueStore defaultStore] valueForKey:@"areSubscribedAtDate"]];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: DDLogDebug(@"Transaction state -> Purchasing");
                break;
            case SKPaymentTransactionStatePurchased:
                [self doSubcribeWithDate:[NSDate date]];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                DDLogDebug(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                DDLogDebug(@"Transaction state -> Restored");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                if(transaction.error.code == SKErrorPaymentCancelled){
                    DDLogDebug(@"Transaction state -> Cancelled");
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

@end
