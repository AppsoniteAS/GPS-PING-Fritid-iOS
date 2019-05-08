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
#import "ASMounthlySubscriptionViewController.h"

static DDLogLevel ddLogLevel = DDLogLevelDebug;
#define kYearlySubscriptionProductIdentifier @"Monthly_Sub"

@interface ASInAppPurchaseManager() <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property ASMounthlySubscriptionViewController* mounthlyViewController;
@end

@implementation ASInAppPurchaseManager

- (instancetype)init {
    self = [super init];
    if (self) {
       // [self initialize];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}


//- (void)initialize {
//    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"areSubscribedAtDate"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    self.areSubscribed = [[[NSDate date] dateBySubtractingYears:1] isEarlierThan:date];
//}


-(void)getSubscriptionPeriod{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (BOOL)areSubscribed{
    
    
    
    
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptionExpired"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSDate date] isEarlierThan:date];
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
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)doSubcribeWithDate:(NSDate*)date {
    //currentMunt
    ///date = date dateByAddingMonths: 
    //[date dateByAddingMonths:<#(NSInteger)#>]
//
//    [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"areSubscribedAtDate"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [[NSUbiquitousKeyValueStore defaultStore] setObject:date forKey:@"areSubscribedAtDate"];
    //[self.delegate openConnect];
}

-(void)updateNextSubscriptionDate:(NSDate*)transactionDate {
    NSDate *date = [NSDate date];
    NSDateComponents* comps = [[NSDateComponents alloc]init];
    comps.year = date.year;
    comps.month = date.month;
    comps.day = date.day;
    if(date.day >= transactionDate.day) {
        comps.month++;
    }
    comps.day =transactionDate.day;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    date = [calendar dateFromComponents:comps];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"subscriptionExpired"];
    
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    DDLogDebug(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    bool restored = false;
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored || transaction.transactionState == SKPaymentTransactionStatePurchased){
//            DDLogDebug(@"Transaction state -> Restored");
           // [self doSubcribeWithDate:[[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"areSubscribedAtDate"]];
            //transaction.transactionDate
            
            [self updateNextSubscriptionDate: transaction.transactionDate];
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            restored = true;
            break;
        }
    }
    if (!restored){
        [[[UIAlertView alloc] initWithTitle: NSLocalizedString( @"You don't have any subscription", nil) message: NSLocalizedString(@"Please subscribe", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];

    }
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];

}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: DDLogDebug(@"Transaction state -> Purchasing");
                break;
            case SKPaymentTransactionStatePurchased:
                    [self updateNextSubscriptionDate: [NSDate date]];
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
