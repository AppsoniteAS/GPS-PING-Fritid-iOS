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
#import "MKStoreKit.h"
#import <CocoaLumberjack.h>

#define SUBSCRIPTION_ID      @"Yearly_subscription"

static DDLogLevel ddLogLevel = DDLogLevelDebug;

@interface ASFriendsListViewController ()
@property (nonatomic, strong) AGApiController   *apiController;
@property (nonatomic, strong) ASTrackerModel    *tracker;
@end

@implementation ASFriendsListViewController

objection_requires(@keypath(ASFriendsListViewController.new, apiController))

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self registerCellClass:[ASFriendTableViewCell class]
              forModelClass:[ASFriendModel class]];
    [self registerCellClass:[ASRequestTableViewCell class]
              forModelClass:[ASAddFriendModel class]];
    
    [self subscribeToTracker];
}

- (void)viewWillAppear:(BOOL)animated {
    [self refreshListOfFriends];
}

-(void)subscribeToTracker {
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      [[self.apiController addTracker:self.tracker.trackerName
                                                                                 imei:self.tracker.imeiNumber
                                                                               number:self.tracker.trackerNumber
                                                                           repeatTime:10.0f
                                                                                 type:self.tracker.trackerType
                                                                        checkForStand:self.tracker.dogInStand] subscribeNext:^(id x) {
                                                          DDLogDebug(@"Tracker Added!");
                                                          [self.tracker saveInUserDefaults];
                                                      } error:^(NSError *error) {
                                                          [[UIAlertView alertWithTitle:NSLocalizedString(@"Error", nil) error:error] show];
                                                      }];
                                                      DDLogDebug(@"Purchased/Subscribed to product with id: %@", [note object]);
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoredPurchasesNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      DDLogDebug(@"Restored Purchases");
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoringPurchasesFailedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      DDLogDebug(@"Failed restoring purchases with error: %@", [note object]);
                                                  }];
    
    if ([ASTrackerModel getTrackersFromUserDefaults].count == 0) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"Subscribe to the tracker", nil)
                                              message:nil
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = NSLocalizedString(@"Enter name", @"Enter name");
         }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = NSLocalizedString(@"Enter IMEI number", @"Enter IMEI number");
         }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = NSLocalizedString(@"Enter Tracker number", @"Enter Tracker number");
         }];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:SUBSCRIPTION_ID];
                                       self.tracker.trackerName = alertController.textFields.firstObject.text;
                                       self.tracker.imeiNumber = [alertController.textFields[1] text];
                                       self.tracker.trackerNumber = alertController.textFields.lastObject.text;
                                   }];
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           DDLogDebug(@"Cancel action");
                                       }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

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
