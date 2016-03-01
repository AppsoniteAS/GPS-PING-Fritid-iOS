//
//  ASTrackerConfigurationViewController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 20/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASTrackerConfigurationViewController.h"
#import "UIStoryboard+ASHelper.h"
#import <JPSKeyboardLayoutGuideViewController.h>
#import "Masonry.h"
#import "ASButton.h"
#import "ASSmsManager.h"
#import "AGApiController.h"

#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@interface ASTrackerConfigurationViewController()<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MFMessageComposeViewControllerDelegate, ASSmsManagerProtocol>

@property (weak, nonatomic) IBOutlet UIView *outerWrapperView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *imeiTextField;
@property (weak, nonatomic) IBOutlet UITextField *trackerNumberTextField;
@property (weak, nonatomic) IBOutlet UISwitch *dogInStandSwitcher;
@property (weak, nonatomic) IBOutlet ASButton *completeButton;
@property (weak, nonatomic) IBOutlet UIView *editButtonsPanel;

@property (nonatomic) NSString *metricType;
@property (nonatomic, assign) CGFloat signalRate;
@property (weak, nonatomic) IBOutlet UITextField *signalRateMetricTextField;
@property (weak, nonatomic) IBOutlet UITextField *signalRateTextField;
@property (weak, nonatomic) IBOutlet ASButton *resetButton;

@property (nonatomic) NSArray      *ratePickerData;
@property (nonatomic) NSArray      *rateMetricPickerData;
@property (nonatomic) UIPickerView *ratePicker;
@property (nonatomic) UIPickerView *rateMetricPicker;

@property (nonatomic, assign) NSInteger smsCount;

@property (nonatomic, strong) AGApiController   *apiController;

@property (nonatomic) NSArray *smsesForActivation;

@end

@implementation ASTrackerConfigurationViewController

objection_requires(@keypath(ASTrackerConfigurationViewController.new, apiController))

+(instancetype)initialize
{
    return [[UIStoryboard trackerStoryboard] instantiateViewControllerWithIdentifier:NSStringFromClass([ASTrackerConfigurationViewController class])];
}

#pragma mark - UIViewController methods

-(void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
    [self jps_viewDidLoad];

    if (self.shouldShowInEditMode) {
        self.navigationItem.title = NSLocalizedString(@"Edit Tracker", nil);
        
        if (self.trackerObject.trackerName) {
            self.nameTextField.text = self.trackerObject.trackerName;
        }
        
        self.trackerNumberTextField.text = self.trackerObject.trackerNumber;
        self.imeiTextField.text = self.trackerObject.imeiNumber;

        [self.dogInStandSwitcher setOn:self.trackerObject.dogInStand];
    }

    [self configPickers];
    
    NSString *newTitle = NSLocalizedString(@"Activation: step %ld", nil);
    [self.completeButton setTitle:[NSString stringWithFormat:newTitle, (long)self.smsCount + 1]
                         forState:UIControlStateNormal];
    
    NSString *newResetTitle = NSLocalizedString(@"Reset: step %ld", nil);
    [self.resetButton setTitle:[NSString stringWithFormat:newResetTitle, (long)self.smsCount + 1]
                         forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.editButtonsPanel.hidden = !self.shouldShowInEditMode;
    self.completeButton.hidden   = self.shouldShowInEditMode;
    [self jps_viewWillAppear:animated];
    [self.outerWrapperView mas_makeConstraints:^
     (MASConstraintMaker *make) {
         make.bottom.equalTo(self.keyboardLayoutGuide);
     }];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self jps_viewDidDisappear:animated];
}



#pragma mark - UIPickerView delegate & datasource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.ratePicker) {
        return self.ratePickerData.count;
    } else {
        return self.rateMetricPickerData.count;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.ratePicker) {
        return self.ratePickerData[row];
    } else {
        return NSLocalizedString(self.rateMetricPickerData[row], nil);
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.ratePicker) {
        self.signalRateTextField.text = NSLocalizedString(self.ratePickerData[row], nil);
    } else {
        self.signalRateMetricTextField.text = NSLocalizedString(self.rateMetricPickerData[row], nil);
    }
}

#pragma mark - UITextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - IBActions

- (IBAction)dogInStandValueChanged:(UISwitch *)sender {
}

- (IBAction)addTrackerTap:(id)sender {
    [self updateTrackerObject];
    [self sendSmses];
}

- (IBAction)updateButtonTap:(id)sender {
    [self updateTrackerObject];
    [self.trackerObject saveInUserDefaults];
    CGFloat repeatTime = self.trackerObject.signalRateInSeconds.integerValue;
    [[self.apiController updateTracker:self.trackerObject.trackerName
                             trackerId:self.trackerObject.imeiNumber
                            repeatTime:repeatTime
                         checkForStand:self.trackerObject.dogInStand] subscribeNext:^(id x) {
        DDLogDebug(@"Tracker updated!");
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)resetButtonTap:(id)sender {
    [self sendSmses];
}


- (IBAction)cancelButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SMS stuff

-(void)sendSmses {
    if (!self.smsesForActivation) {
        [[self.trackerObject getSmsTextsForActivation] subscribeNext:^(id x) {
            self.smsesForActivation = x;
            [self checkSmsCount];
        } error:^(NSError *error) {
            [[UIAlertView alertWithTitle:NSLocalizedString(@"Error", nil) error:error] show];
        }];
    } else {
        [self checkSmsCount];
    }
}

-(void)checkSmsCount{
    if (self.smsCount == self.smsesForActivation.count) {
        if (self.shouldShowInEditMode) {
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        
        CGFloat repeatTime = [self.trackerObject.signalRateMetric isEqualToString:kASSignalMetricTypeSeconds] ?
        self.trackerObject.signalRate : self.trackerObject.signalRate * 60;
        [[self.apiController addTracker:self.trackerObject.trackerName
                                  imei:self.trackerObject.imeiNumber
                                number:self.trackerObject.trackerNumber
                            repeatTime:repeatTime
                                  type:self.trackerObject.trackerType
                         checkForStand:self.trackerObject.dogInStand] subscribeNext:^(id x) {
            DDLogDebug(@"Tracker Added!");
            [self.trackerObject saveInUserDefaults];
            [self dismissViewControllerAnimated:YES completion:nil];
        } error:^(NSError *error) {
            [[UIAlertView alertWithTitle:NSLocalizedString(@"Error", nil) error:error] show];
        }];
    } else {
        [self as_sendSMS:self.smsesForActivation[self.smsCount]
           recipient:self.trackerObject.trackerNumber];
    }
}

-(void)smsManagerMessageWasSentWithResult:(MessageComposeResult)result
{
    self.smsCount++;
    
    if (self.shouldShowInEditMode) {
        [self.resetButton setTitle:[self newTitleForReset:self.smsCount]
                             forState:UIControlStateNormal];
    } else {
        [self.completeButton setTitle:[self newTitleForActivation:self.smsCount]
                             forState:UIControlStateNormal];
    }
}

-(NSString *)newTitleForReset:(NSInteger)smsCount {
    NSString *newTitle;
    if (smsCount == self.smsesForActivation.count) {
        newTitle = NSLocalizedString(@"Finish reset", nil);
    } else {
        newTitle = [NSString stringWithFormat:NSLocalizedString(@"Reset: step %ld", nil), (long)self.smsCount + 1];
    }
    
    return newTitle;
}

-(NSString *)newTitleForActivation:(NSInteger)smsCount {
    NSString *newTitle;
    if (smsCount == self.smsesForActivation.count) {
        newTitle = NSLocalizedString(@"Finish activation", nil);
    } else {
        newTitle = [NSString stringWithFormat:NSLocalizedString(@"Activation: step %ld", nil), (long)self.smsCount + 1];
    }
    
    return newTitle;
}

#pragma mark - Private methods

-(void)configPickers {
    self.ratePickerData = @[@"1", @"2", @"3", @"5", @"7", @"10", @"20", @"30", @"40", @"50", @"60"];
    self.rateMetricPickerData = @[kASSignalMetricTypeSeconds, kASSignalMetricTypeMinutes];
    
    self.ratePicker = [[UIPickerView alloc] init];
    self.ratePicker.backgroundColor = [UIColor whiteColor];
    self.ratePicker.delegate = self;
    self.ratePicker.dataSource = self;

    NSString *currentSignalRate = [NSString stringWithFormat:@"%ld", self.trackerObject.signalRate];
    if ([self.rateMetricPickerData containsObject:currentSignalRate]) {
        [self.ratePicker selectRow:[self.ratePickerData indexOfObject:currentSignalRate]
                       inComponent:0
                          animated:NO];
    } else {
        [self.ratePicker selectRow:0
                       inComponent:0
                          animated:NO];
    }
    
    self.signalRateTextField.inputView = self.ratePicker;
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.ratePicker.frame.size.width, 44)];
    accessoryView.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
    
    accessoryView.items = [NSArray arrayWithObjects:space,done, nil];
    self.signalRateTextField.inputAccessoryView = accessoryView;
    
    self.rateMetricPicker = [[UIPickerView alloc] init];
    self.rateMetricPicker.delegate = self;
    self.rateMetricPicker.dataSource = self;
    [self.rateMetricPicker selectRow:[self.rateMetricPickerData indexOfObject:self.trackerObject.signalRateMetric]
                   inComponent:0
                      animated:NO];
    self.signalRateMetricTextField.inputView = self.rateMetricPicker;
    self.signalRateMetricTextField.inputAccessoryView = accessoryView;
    
    self.signalRateTextField.text = [NSString stringWithFormat:@"%ld", (long)self.trackerObject.signalRate];
    self.signalRateMetricTextField.text = NSLocalizedString(self.trackerObject.signalRateMetric, nil);
}

-(void)doneTapped:(id)sender
{
    [self.signalRateMetricTextField resignFirstResponder];
    [self.signalRateTextField resignFirstResponder];
}

-(void)updateTrackerObject {
    self.trackerObject.trackerName         = self.nameTextField.text;
    self.trackerObject.imeiNumber          = self.imeiTextField.text;
    self.trackerObject.trackerNumber       = self.trackerNumberTextField.text;
    self.trackerObject.dogInStand          = self.dogInStandSwitcher.isOn;
    if ([self.signalRateMetricTextField.text isEqualToString:self.rateMetricPickerData[0]]) {
        self.trackerObject.signalRateInSeconds = @(self.signalRateTextField.text.integerValue);
    } else {
        self.trackerObject.signalRateInSeconds = @(self.signalRateTextField.text.integerValue * 60);
    }
}

@end
