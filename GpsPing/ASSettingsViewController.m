//
//  ASSettingsViewController.m
//  GpsPing
//
//  Created by Maks Niagolov on 2/25/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASSettingsViewController.h"
#import "UIStoryboard+ASHelper.h"
#import "ASTrackerModel.h"
#import "ASInAppPurchaseManager.h"
#import <CocoaLumberjack.h>
#import "ASChooseTrackerViewController.h"
#import "UIStoryboard+ASHelper.h"

static DDLogLevel ddLogLevel = DDLogLevelDebug;

@interface ASSettingsViewController () <ASInAppPurchaseDelegate>
@property (nonatomic, strong) ASInAppPurchaseManager* inAppPurchaseManager;
@end

@implementation ASSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.inAppPurchaseManager = [ASInAppPurchaseManager new];
    self.inAppPurchaseManager.delegate = self;
    
}
- (IBAction)goToConnect:(id)sender {
    [self checkingForTrackers];
}

-(void)checkingForTrackers {
    if ([ASTrackerModel getTrackersFromUserDefaults].count == 0) {
        if(![self.inAppPurchaseManager areSubscribed]) {
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
                                                         [self.inAppPurchaseManager restore];
                                                     }];
            UIAlertAction *subscribeAction = [UIAlertAction
                                              actionWithTitle:NSLocalizedString(@"Subcribe", @"Subcribe action")
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *action)
                                              {
                                                  [self.inAppPurchaseManager subscribe];
                                              }];
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               DDLogDebug(@"Cancel action");
                                               [self.navigationController popoverPresentationController];
                                           }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:addTrackerAction];
            [alertController addAction:restoreSubscribeAction];
            [alertController addAction:subscribeAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            [self openConnect];
        }
    } else {
        [self openConnect];
    }
}

#pragma  mark - ASInAppPurchaseDelegate
-(void)openConnect {
    UIViewController* controller = [[UIStoryboard connectStoryboard] instantiateInitialViewController];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
