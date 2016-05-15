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
@property (weak, nonatomic) IBOutlet UILabel *activeTrackerLabel;

@end

@implementation MainMenuViewController

objection_requires(@keypath(MainMenuViewController.new, apiController))

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];

    self->_viewModel = [[ASMainViewModel alloc] init];
    
    self.startStopButton.layer.borderColor = [UIColor as_darkestBlueColor].CGColor;
    self.startStopButton.layer.borderWidth = 6.0;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    [self updateButton];
    self.startStopButton.layer.cornerRadius = self.startStopButton.frame.size.width/2;
    ASTrackerModel *activeTracker = [ASTrackerModel getChoosedTracker];
    self.activeTrackerLabel.text = activeTracker.trackerName;

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (IBAction)startStopButtonTap:(id)sender {
    ASTrackerModel *trackerModel = [ASTrackerModel getChoosedTracker];
    
    if (![ASTrackerModel getChoosedTracker]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No tracker choosed", nil)
                                    message:NSLocalizedString(@"You must choose tracker on Trackers screen in Settings to start it", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles: nil] show];
        return;
    }

    [self as_sendSMS:[trackerModel getSmsTextsForTrackerLaunch:!trackerModel.isRunning]
           recipient:trackerModel.trackerNumber];
}

-(void)selectTracker:(ASSelectTrackerViewController *)controller trackerChoosed:(ASTrackerModel *)trackerModel
{
    [self as_sendSMS:[trackerModel getSmsTextsForTrackerLaunch:YES]
           recipient:trackerModel.trackerNumber];
}


-(void)smsManagerMessageWasSentWithResult:(MessageComposeResult)result
{
    ASTrackerModel *trackerModel = [ASTrackerModel getChoosedTracker];
    trackerModel.isRunning = !trackerModel.isRunning;
    [trackerModel saveInUserDefaults];
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
    ASTrackerModel *trackerModel = [ASTrackerModel getChoosedTracker];
    if (trackerModel.isRunning) {
        self.startStopButton.layer.backgroundColor = [UIColor as_redColor].CGColor;
        self.startStopButton.layer.borderColor = [UIColor as_darkRedColor].CGColor;
        [self.startStopButton setTitle:NSLocalizedString(@"STOP", nil) forState:UIControlStateNormal];
    } else {
        self.startStopButton.layer.backgroundColor = [UIColor as_darkblueColor].CGColor;
        self.startStopButton.layer.borderColor = [UIColor as_darkestBlueColor].CGColor;
        [self.startStopButton setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    }
}

@end
