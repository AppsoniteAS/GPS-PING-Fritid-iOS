//
//  ASGeofenceViewController.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASGeofenceViewController.h"
#import "ASGeofenceViewModel.h"
#import "ASTrackerModel.h"
#import "ASSmsManager.h"


@interface ASGeofenceViewController ()

@property (nonatomic, readonly) ASGeofenceViewModel   *viewModel;
@property (nonatomic, weak    ) IBOutlet UITextField  *textFieldYards;
@property (nonatomic, weak    ) IBOutlet UIButton     *buttonSubmit;
@property (weak, nonatomic) IBOutlet UILabel *activeTrackerLabel;
@end

@implementation ASGeofenceViewController 

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    self.activeTrackerLabel.text = [ASTrackerModel getChoosedTracker].trackerName;
    
    self->_viewModel = [[ASGeofenceViewModel alloc] init];
    self.viewModel.yards = [ASTrackerModel getChoosedTracker].geofenceYards;
    
    self.textFieldYards.text      = self.viewModel.yards;
    RAC(self.viewModel, yards)    = self.textFieldYards.rac_textSignal;
    self.buttonSubmit.rac_command = self.viewModel.submit;
    
    [self rac_liftSelector:@selector(doSubmit:)
               withSignals:self.buttonSubmit.rac_command.executionSignals.flatten, nil];
    [self rac_liftSelector:@selector(onError:)
               withSignals:self.buttonSubmit.rac_command.errors, nil];
    
    [self updateButton];
}

-(void)onError:(NSError*)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                    message:error.localizedDescription
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - IBActions

-(IBAction)doSubmit:(id)sender {
    [[self as_sendSMS:[ASTrackerModel getSmsTextsForGeofenceLaunch:!([ASTrackerModel getChoosedTracker].isGeofenceStarted)
                                                      distance:self.viewModel.yards]
           ToRecipient:[ASTrackerModel getChoosedTracker].trackerPhoneNumber] subscribeNext:^(id x) {
        ASTrackerModel *activeTracker = [ASTrackerModel getChoosedTracker];
        activeTracker.isGeofenceStarted = !activeTracker.isGeofenceStarted;
        
        if (activeTracker.isGeofenceStarted) {
            activeTracker.geofenceYards = self.viewModel.yards;
        }
        
        [activeTracker saveInUserDefaults];
        
        [self updateButton];
    } error:^(NSError *error) {
        ;
    }];
}

-(void)updateButton {
    if ([ASTrackerModel getChoosedTracker].isGeofenceStarted) {
        [self.buttonSubmit setTitle:NSLocalizedString(@"STOP", nil) forState:UIControlStateNormal];
        self.textFieldYards.text = [ASTrackerModel getChoosedTracker].geofenceYards;
    } else {
        [self.buttonSubmit setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    }
}

@end
