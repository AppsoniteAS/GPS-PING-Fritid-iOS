//
//  ViewController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 18/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "MainMenuViewController.h"
#import "ASSelectTrackerViewController.h"
#import "ASSmsManager.h"
#import "ASMainViewModel.h"
#import "ASMapViewController.h"
#import "AGApiController.h"

#import <CocoaLumberjack.h>
static DDLogLevel ddLogLevel = DDLogLevelDebug;

@interface MainMenuViewController() <ASSelectTrackerProtocol>

@property (nonatomic, readonly) ASMainViewModel     *viewModel;
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
@property (nonatomic, strong) AGApiController   *apiController;

@end

@implementation MainMenuViewController {
    BOOL isAuthShown;
}
objection_requires(@keypath(MainMenuViewController.new, apiController))

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];

    self->_viewModel = [[ASMainViewModel alloc] init];
    
    self.startStopButton.layer.borderColor = [UIColor colorWithRed:0.4796 green:0.7302 blue:0.2274 alpha:1.0].CGColor;
    self.startStopButton.layer.borderWidth = 6.0;
    [self updateButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    self.startStopButton.layer.cornerRadius = self.startStopButton.frame.size.width/2;
}

- (void)viewDidAppear:(BOOL)animated {
    if (isAuthShown == NO) {
        [self showAuth];
        isAuthShown = YES;
    }
}

- (void)showAuth {
    if (self.viewModel.apiController.userProfile == nil) {
        UIViewController* controller = [[UIStoryboard storyboardWithName:@"Auth" bundle:nil] instantiateInitialViewController];
        [self.navigationController presentViewController:controller animated:YES completion:nil];
    } else {
        [[self.apiController registerForPushes] subscribeNext:^(id x) {
            ;
        }];
    }
}

- (IBAction)startStopButtonTap:(id)sender {
    NSNumber *trackerStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kASUserDefaultsKeyMainScreenTrackerStatus];
    
    if (!trackerStatus.boolValue) {
        if (![ASTrackerModel getChoosedTracker]) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No tracker choosed", nil)
                                        message:NSLocalizedString(@"You must choose tracker on Trackers screen in Settings to start it", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles: nil] show];
            return;
        }
        
        [self as_sendSMS:[[ASTrackerModel getChoosedTracker] getSmsTextsForTrackerLaunch:YES]
               recipient:[ASTrackerModel getChoosedTracker].trackerNumber];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:kASUserDefaultsKeyMainScreenTrackerStatus];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self updateButton];
    }
}

-(void)selectTracker:(ASSelectTrackerViewController *)controller trackerChoosed:(ASTrackerModel *)trackerModel
{
    [self as_sendSMS:[trackerModel getSmsTextsForTrackerLaunch:YES]
           recipient:trackerModel.trackerNumber];
}


-(void)smsManagerMessageWasSentWithResult:(MessageComposeResult)result
{
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:kASUserDefaultsKeyMainScreenTrackerStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateButton];
}
- (IBAction)mapTap:(id)sender {
    ASMapViewController *mapVC = [ASMapViewController initialize];
    mapVC.isHistoryMode = NO;
    [self.navigationController pushViewController:mapVC animated:YES];
}
- (IBAction)historyTap:(id)sender {
    ASMapViewController *mapVC = [ASMapViewController initialize];
    mapVC.isHistoryMode = YES;
    [self.navigationController pushViewController:mapVC animated:YES];
}

-(void)updateButton {
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSNumber *trackerStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kASUserDefaultsKeyMainScreenTrackerStatus];
    
    if (trackerStatus.boolValue) {
        [self.startStopButton setTitle:NSLocalizedString(@"STOP", nil) forState:UIControlStateNormal];
    } else {
        [self.startStopButton setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    }
}

@end
