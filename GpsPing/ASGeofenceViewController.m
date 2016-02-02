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
@property (nonatomic, weak    ) IBOutlet UITextField  *textFieldPhoneNumber;
@property (nonatomic, weak    ) IBOutlet UIButton     *buttonSubmit;
@end

@implementation ASGeofenceViewController 

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    self->_viewModel = [[ASGeofenceViewModel alloc] init];
    
    self.textFieldYards.text      = self.viewModel.yards;
    RAC(self.viewModel, yards)    = self.textFieldYards.rac_textSignal;
    self.textFieldPhoneNumber.text   = self.viewModel.phoneNumber;
    RAC(self.viewModel, phoneNumber) = self.textFieldPhoneNumber.rac_textSignal;
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
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSNumber *geofenceStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kASGeofenceStatus];
    [self as_sendSMS:[ASTrackerModel getSmsTextsForGeofenceLaunch:!geofenceStatus.boolValue
                                                      phoneNumber:self.viewModel.phoneNumber]
           recipient:self.viewModel.phoneNumber];
}

-(void)smsManagerMessageWasSentWithResult:(MessageComposeResult)result
{
    NSNumber *geofenceStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kASGeofenceStatus];
    
    BOOL newValue = !geofenceStatus.boolValue;
    [[NSUserDefaults standardUserDefaults] setObject:@(newValue) forKey:kASGeofenceStatus];
    if (newValue) {
        [[NSUserDefaults standardUserDefaults] setObject:self.viewModel.phoneNumber forKey:kASUserDefaultsKeyGeofencePhoneNumber];
        [[NSUserDefaults standardUserDefaults] setObject:self.viewModel.yards forKey:kASUserDefaultsKeyGeofenceYards];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateButton];
}

-(void)updateButton {
    NSNumber *geofenceStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kASGeofenceStatus];
    
    if (geofenceStatus.boolValue) {
        [self.buttonSubmit setTitle:NSLocalizedString(@"STOP", nil) forState:UIControlStateNormal];
        self.textFieldPhoneNumber.text = [[NSUserDefaults standardUserDefaults] objectForKey:kASUserDefaultsKeyGeofencePhoneNumber];
        self.textFieldYards.text = [[NSUserDefaults standardUserDefaults] objectForKey:kASUserDefaultsKeyGeofenceYards];
    } else {
        [self.buttonSubmit setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    }
}

@end
