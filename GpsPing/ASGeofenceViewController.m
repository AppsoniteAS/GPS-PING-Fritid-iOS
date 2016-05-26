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


@interface ASGeofenceViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, readonly) ASGeofenceViewModel *viewModel;

@property (nonatomic, weak) IBOutlet UITextField *textFieldYards;
@property (nonatomic, weak) IBOutlet UIButton    *buttonSubmit;
@property (nonatomic, weak) IBOutlet UILabel     *activeTrackerLabel;

@property (nonatomic) NSArray      *distancePickerData;
@property (nonatomic) UIPickerView *distancePicker;

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
    self.distancePickerData = [ASTrackerModel getChoosedTracker].getGeofenceDistanceOptions;
    [self configPickers];
}

-(void)configPickers {
    self.distancePicker = [[UIPickerView alloc] init];
    self.distancePicker.backgroundColor = [UIColor whiteColor];
    self.distancePicker.delegate = self;
    self.distancePicker.dataSource = self;
    self.textFieldYards.inputView = self.distancePicker;
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.distancePicker.frame.size.width, 44)];
    accessoryView.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
    
    accessoryView.items = [NSArray arrayWithObjects:space,done, nil];
    self.textFieldYards.inputAccessoryView = accessoryView;
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
    [self as_sendSMS:[[ASTrackerModel getChoosedTracker] getSmsTextsForGeofenceLaunchWithDistance:self.viewModel.yards]
           recipient:[ASTrackerModel getChoosedTracker].trackerNumber];
}

-(void)smsManagerMessageWasSentWithResult:(MessageComposeResult)result
{
    ASTrackerModel *activeTracker = [ASTrackerModel getChoosedTracker];
    activeTracker.isGeofenceStarted = !activeTracker.isGeofenceStarted;
    
    if (activeTracker.isGeofenceStarted) {
        activeTracker.geofenceYards = self.viewModel.yards;
    }
    
    [activeTracker saveInUserDefaults];
    
    [self updateButton];
}

-(void)updateButton {
    if ([ASTrackerModel getChoosedTracker].isGeofenceStarted) {
        [self.buttonSubmit setTitle:NSLocalizedString(@"STOP", nil) forState:UIControlStateNormal];
        self.textFieldYards.text = [ASTrackerModel getChoosedTracker].geofenceYards;
    } else {
        [self.buttonSubmit setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    }
}

#pragma mark - Handlers

-(void)doneTapped:(id)sender {
    [self.textFieldYards resignFirstResponder];
}

#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.distancePickerData.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.distancePickerData[row];
}

#pragma mark - UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.textFieldYards.text = self.distancePickerData[row];
}

@end
