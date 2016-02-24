//
//  ASFriendsListViewController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 26/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASFriendsListViewController.h"
#import "ASFriendTableViewCell.h"
#import "ASRequestTableViewCell.h"
#import "AGApiController.h"
#import "ASFriendModel.h"
#import "ASAddFriendModel.h"
#import "ASTrackerModel.h"
#import "UIStoryboard+ASHelper.h"
#import <CocoaLumberjack.h>
#import <StoreKit/StoreKit.h>
#import "ASChooseTrackerViewController.h"

#define kYearlySubscriptionProductIdentifier @"Yearly_subscription"

static DDLogLevel ddLogLevel = DDLogLevelDebug;

@interface ASFriendsListViewController () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, strong) AGApiController   *apiController;
@end

@implementation ASFriendsListViewController
{
    BOOL areSubscribed;
}

objection_requires(@keypath(ASFriendsListViewController.new, apiController))

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self registerCellClass:[ASFriendTableViewCell class]
              forModelClass:[ASFriendModel class]];
    [self registerCellClass:[ASRequestTableViewCell class]
              forModelClass:[ASAddFriendModel class]];
    
    [self checkingForTrackers];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self refreshListOfFriends];
}

-(void)checkingForTrackers {
    if ([ASTrackerModel getTrackersFromUserDefaults].count == 0) {
        areSubscribed = [[NSUserDefaults standardUserDefaults] boolForKey:@"areSubscribed"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if(areSubscribed){
            // do something here if already subscribed....
        } else {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:NSLocalizedString(@"You don't have any tracker", nil)
                                                  message:NSLocalizedString(@"Please add a tracker or subscribe to your friend's tracker", nil)
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *addTrackerAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"Add tracker", @"Add tracker")
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   UIViewController* controller = [[UIStoryboard trackerStoryboard] instantiateViewControllerWithIdentifier:NSStringFromClass([ASChooseTrackerViewController  class])];
                                                   [self presentViewController:controller animated:YES completion:nil];
                                               }];
            UIAlertAction *restoreSubscribeAction = [UIAlertAction
                                                     actionWithTitle:NSLocalizedString(@"Restore", @"Restore subscription")
                                                     style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
                                                     {
                                                         NSLog(@"User requests to restore subscribtion");
                                                         
                                                         [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
                                                         [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
                                                     }];
            UIAlertAction *subscribeAction = [UIAlertAction
                                              actionWithTitle:NSLocalizedString(@"Subcribe", @"Subcribe action")
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *action)
                                              {
                                                  NSLog(@"User requests to subscribe");
                                                  
                                                  if([SKPaymentQueue canMakePayments]){
                                                      NSLog(@"User can make payments");
                                                      
                                                      SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kYearlySubscriptionProductIdentifier]];
                                                      productsRequest.delegate = self;
                                                      [productsRequest start];
                                                      
                                                  }
                                                  else{
                                                      NSLog(@"User cannot make payments due to parental controls");
                                                  }
                                              }];
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               DDLogDebug(@"Cancel action");
                                           }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:addTrackerAction];
            [alertController addAction:restoreSubscribeAction];
            [alertController addAction:subscribeAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    if([response.products count] > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
    }
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)doSubcribe {
    //add user friend's trackers here...
    areSubscribed = YES;
    [[NSUserDefaults standardUserDefaults] setBool:areSubscribed forKey:@"areSubscribed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            NSLog(@"Transaction state -> Restored");
            [self doSubcribe];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                break;
            case SKPaymentTransactionStatePurchased:
                [self doSubcribe];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

#pragma mark - UITableView delegate
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([[self.memoryStorage itemAtIndexPath:indexPath] isKindOfClass:[ASFriendModel class]]) {
            ASFriendModel *friend = [self.memoryStorage itemAtIndexPath:indexPath];
            [[self.apiController removeFriendWithId:[NSString stringWithFormat:@"%@",friend.userId]] subscribeNext:^(id x) {
                [self.memoryStorage removeItem:friend];
            }];
        } else {
            ASAddFriendModel *addFriend = [self.memoryStorage itemAtIndexPath:indexPath];
            [[self.apiController declineFriendshipWithFriendId:[NSString stringWithFormat:@"%@",addFriend.userId]] subscribeNext:^(id x) {
                [self.memoryStorage removeItem:addFriend];
            }];
        }
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[ASRequestTableViewCell class]]) {
        ASAddFriendModel *addFriend = [self.memoryStorage itemAtIndexPath:indexPath];
        [[[self.apiController confirmFriendshipWithFriendId:[NSString stringWithFormat:@"%@",addFriend.userId]] deliverOnMainThread] subscribeNext:^(id x) {
            [self refreshListOfFriends];
        }];
    } else {
        ASFriendModel *friend = [self.memoryStorage itemAtIndexPath:indexPath];
        [self setFriend:friend ssSeeingTrackers:!friend.isSeeingTracker.boolValue];
    }
}

-(void)setFriend:(ASFriendModel*)friend ssSeeingTrackers:(BOOL)isSeeing {
    [[self.apiController setSeeingTracker:isSeeing friendId:friend.userId.stringValue] subscribeNext:^(id x) {
        friend.isSeeingTracker = @(isSeeing);
        [self.memoryStorage reloadItem:friend];
    }];
}

-(void)refreshListOfFriends{
    [[self.apiController getFriends] subscribeNext:^(id x) {
        [self.memoryStorage removeAllTableItems];
        [self.memoryStorage addItems:x];
        [self.tableView reloadData];
    }];
}

@end
