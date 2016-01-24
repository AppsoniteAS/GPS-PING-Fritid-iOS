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

@interface MainMenuViewController() <ASSelectTrackerProtocol>

@property (nonatomic, readonly) ASMainViewModel     *viewModel;
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
@property (nonatomic, assign) BOOL trackerStarted;

@end

@implementation MainMenuViewController {
    BOOL isAuthShown;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self->_viewModel = [[ASMainViewModel alloc] init];
    
    self.startStopButton.layer.borderColor = [UIColor colorWithRed:0.4796 green:0.7302 blue:0.2274 alpha:1.0].CGColor;
    self.startStopButton.layer.borderWidth = 6.0;
    [self.startStopButton setTitle:NSLocalizedString(@"START", nil) forState:UIControlStateNormal];
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
    }
}

- (IBAction)startStopButtonTap:(id)sender {
    if (!self.trackerStarted) {
        ASSelectTrackerViewController *selectVC = [ASSelectTrackerViewController initialize];
        selectVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        selectVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        selectVC.delegate = self;
        [self presentViewController:selectVC animated:YES completion:nil];
    } else {
        self.trackerStarted = NO;
        [self.startStopButton setTitle:NSLocalizedString(@"START", nil) forState:UIControlStateNormal];
    }
}

-(void)selectTracker:(ASSelectTrackerViewController *)controller trackerChoosed:(ASTrackerModel *)trackerModel
{
    [self as_sendSMS:[trackerModel getSmsTextsForTrackerLaunch:YES]
           recipient:trackerModel.trackerNumber];
}


-(void)smsManagerMessageWasSentWithResult:(MessageComposeResult)result
{
    [self.startStopButton setTitle:NSLocalizedString(@"STOP", nil) forState:UIControlStateNormal];
    self.trackerStarted = YES;
}

@end
