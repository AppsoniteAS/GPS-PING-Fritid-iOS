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
#import "UIColor+ASColor.h"

#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

static NSString *const kASUserDefaultsKeyBikeLedLight   = @"kASUserDefaultsKeyBikeLedLight";
static NSString *const kASUserDefaultsKeyBikeShockAlarm = @"kASUserDefaultsKeyBikeShockAlarm";
static NSString *const kASUserDefaultsKeyBikeFlashAlarm = @"kASUserDefaultsKeyBikeFlashAlarm";

@interface ASTrackerConfigurationViewController()<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIView      *outerWrapperView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *imeiTextField;
@property (weak, nonatomic) IBOutlet UITextField *trackerNumberTextField;
@property (weak, nonatomic) IBOutlet UISwitch    *dogInStandSwitcher;
@property (weak, nonatomic) IBOutlet UIView      *editButtonsPanel;
@property (weak, nonatomic) IBOutlet UILabel     *labelStatusBikeLEDLight;
@property (weak, nonatomic) IBOutlet UILabel     *labelStatusBikeShockAlarm;
@property (weak, nonatomic) IBOutlet UILabel     *labelStatusBikeFlashAlarm;
@property (weak, nonatomic) IBOutlet ASButton    *buttonBikeLEDLight;
@property (weak, nonatomic) IBOutlet ASButton    *buttonBikeShockAlarm;
@property (weak, nonatomic) IBOutlet ASButton    *buttonBikeFlashAlarm;
@property (weak, nonatomic) IBOutlet UITextField *signalRateTextField;
@property (weak, nonatomic) IBOutlet ASButton    *resetButton;
@property (weak, nonatomic) IBOutlet UILabel *labelStatusSleepMode;
@property (weak, nonatomic) IBOutlet ASButton *buttonDogSleepMode;
@property (weak, nonatomic) IBOutlet ASButton *buttonCheckBattery;

@property (nonatomic) NSString *metricType;
@property (nonatomic, assign) CGFloat signalRate;


@property (nonatomic) NSArray      *ratePickerData;
@property (nonatomic) NSDictionary  *ratePickerStrings;

@property (nonatomic) NSArray      *rateMetricPickerData;
@property (nonatomic) UIPickerView *ratePicker;

@property (nonatomic, assign) NSInteger smsCount;

@property (nonatomic, strong) AGApiController   *apiController;

@property (nonatomic) NSArray *smsesForActivation;


@property (nonatomic) NSNumber      *choosedTime;

@end

@implementation ASTrackerConfigurationViewController

objection_requires(@keypath(ASTrackerConfigurationViewController.new, apiController))

+(instancetype)initializeWithTrackerModel:(ASTrackerModel *)trackerModel
{
    NSString *className;
    NSString* t = trackerModel.trackerType;
    if ([t isEqualToString:kASTrackerTypeLK209] || [t isEqualToString:kASTrackerTypeVT600] || [t isEqualToString:kASTrackerTypeLK330] || [t isEqualToString:kASTrackerTypeTkS1]){
        className = @"ASTrackerConfigurationViewController_Industry";
    } else {
        className = [NSString stringWithFormat:@"%@_%@", NSStringFromClass([ASTrackerConfigurationViewController class]),
                                                              trackerModel.trackerType];
    }
    ASTrackerConfigurationViewController *result = [[UIStoryboard trackerConfigurationStoryboard] instantiateViewControllerWithIdentifier:className];
    result.trackerObject = trackerModel;
    return result;
}
//+ (instancetype)initialize {
//    return [[UIStoryboard trackerConfigurationStoryboard] instantiateViewControllerWithIdentifier:NSStringFromClass([ASTrackerConfigurationViewController class])];
//}
//


#pragma mark - UIViewController methods

-(void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
    [self jps_viewDidLoad];

    if (self.trackerObject.trackerName) {
        self.nameTextField.text = self.trackerObject.trackerName;
    }
    
    self.trackerNumberTextField.text = self.trackerObject.trackerNumber;
    self.imeiTextField.text = self.trackerObject.imeiNumber;

    [self.dogInStandSwitcher setOn:self.trackerObject.dogInStand];

    [self configPickers];
    
    NSString *newResetTitle = NSLocalizedString(@"Reset: step %ld", nil);
    [self.resetButton setTitle:[NSString stringWithFormat:newResetTitle, (long)self.smsCount + 1]
                         forState:UIControlStateNormal];
    
    self.buttonBikeLEDLight.titleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:9];
    self.buttonBikeFlashAlarm.titleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:9];
    self.buttonBikeShockAlarm.titleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:9];
    self.buttonCheckBattery.titleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:9];
    self.buttonDogSleepMode.titleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:9];

    
    [RACObserve(self.trackerObject, bikeLedLightIsOn) subscribeNext:^(NSNumber *x) {
        [self configBikeSettingButton:self.buttonBikeLEDLight Status:x.boolValue];
        [self configBikeSettingStatusLabel:self.labelStatusBikeLEDLight Status:x.boolValue];
    }];
    
    [RACObserve(self.trackerObject, bikeShockAlarmIsOn) subscribeNext:^(NSNumber *x) {
        [self configBikeSettingButton:self.buttonBikeShockAlarm Status:x.boolValue];
        [self configBikeSettingStatusLabel:self.labelStatusBikeShockAlarm Status:x.boolValue];
    }];
    
    [RACObserve(self.trackerObject, bikeFlashAlarmIsOn) subscribeNext:^(NSNumber *x) {
        [self configBikeSettingButton:self.buttonBikeFlashAlarm Status:x.boolValue];
        [self configBikeSettingStatusLabel:self.labelStatusBikeFlashAlarm Status:x.boolValue];
    }];
    
    [RACObserve(self.trackerObject, dogSleepModeIsOn) subscribeNext:^(NSNumber *x) {
        [self configBikeSettingButton:self.buttonDogSleepMode Status:x.boolValue];
        [self configBikeSettingStatusLabel:self.labelStatusSleepMode Status:x.boolValue];
    }];
    
    [self.outerWrapperView mas_remakeConstraints:^
     (MASConstraintMaker *make) {
         make.leading.equalTo(self.outerWrapperView.superview.mas_leading);
         make.trailing.equalTo(self.outerWrapperView.superview.mas_trailing);
         make.top.equalTo(self.mas_topLayoutGuide);
         make.bottom.equalTo(self.keyboardLayoutGuide);
     }];
}

-(void)configBikeSettingStatusLabel:(UILabel*)label Status:(BOOL)isActive {
    if (isActive) {
        label.text = NSLocalizedString(@"Active", @"bike setting status");
        label.textColor = [UIColor as_greenColor];
    } else {
        label.text = NSLocalizedString(@"Inactive", @"bike setting status");
        label.textColor = [UIColor as_grayColor];
    }
}

-(void)configBikeSettingButton:(ASButton*)button Status:(BOOL)isActive {
    if (isActive) {
        [button setTitle:NSLocalizedString(@"TURN OFF", @"bike setting button on/off") forState:UIControlStateNormal];
        [button setStyle:ASButtonStyleGrey];
    } else {
        [button setTitle:NSLocalizedString(@"TURN ON", @"bike setting button on/off") forState:UIControlStateNormal];
        [button setStyle:ASButtonStyleGreen];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self jps_viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self jps_viewDidDisappear:animated];
}

#pragma mark - UIPickerView delegate & datasource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.ratePickerData.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.ratePickerStrings[self.ratePickerData[row]];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.choosedTime = self.ratePickerData[[pickerView selectedRowInComponent:0]];
    [self updateRateTextField];
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

- (IBAction)updateButtonTap:(id)sender {
    [self updateTrackerObject];
    [self.trackerObject saveInUserDefaults];
    CGFloat repeatTime = self.trackerObject.signalRateInSeconds.integerValue;
    
    [[self as_sendSMS:[self.trackerObject getSmsTextsForTrackerUpdate]
          ToRecipient:self.trackerObject.trackerPhoneNumber] subscribeNext:^(id x) {
        
        [[[self.apiController updateTracker:self.trackerObject.trackerName
                                 trackerId:self.trackerObject.imeiNumber
                                repeatTime:repeatTime
                             checkForStand:self.trackerObject.dogInStand] deliverOnMainThread] subscribeNext:^(id x) {
            DDLogDebug(@"Tracker updated!");
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    } error:^(NSError *error) {
        [[UIAlertView alertWithTitle:NSLocalizedString(@"Error", nil) error:error] show];
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
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [[self as_sendSMS:self.smsesForActivation[self.smsCount]
              ToRecipient:self.trackerObject.trackerPhoneNumber] subscribeNext:^(id x) {
            self.smsCount++;
            [self.resetButton setTitle:[self newTitleForReset:self.smsCount]
                              forState:UIControlStateNormal];
        } error:^(NSError *error) {
            ;
        }];
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

-(void)setRatePickerData:(NSArray *)ratePickerData
{
    _ratePickerData = ratePickerData;
    
    NSMutableDictionary *valuesDictionary = @{}.mutableCopy;
    NSString *secondsString = NSLocalizedString(@"%d seconds", nil);
    NSString *minutesString = NSLocalizedString(@"%d minutes", nil);
    NSString *hoursString = NSLocalizedString(@"%d hours", nil);

    for (NSNumber *value in ratePickerData) {
        if (value.integerValue >= 3600) {
            valuesDictionary[value] = [NSString localizedStringWithFormat:hoursString, value.integerValue / 60 / 60];
        } else if (value.integerValue >= 60) {
            valuesDictionary[value] = [NSString localizedStringWithFormat:minutesString, value.integerValue/60];
        } else {
            valuesDictionary[value] = [NSString localizedStringWithFormat:secondsString, value.integerValue];
        }
    }
    self.ratePickerStrings = [NSDictionary dictionaryWithDictionary:valuesDictionary];
}

#pragma mark - Private methods

-(void)configPickers {
    if ([self.trackerObject.trackerType isEqualToString:kASTrackerTypeLK330] || [self.trackerObject.trackerType isEqualToString:kASTrackerTypeLK209]) {
        self.ratePickerData = @[@(1 * 60 * 60), @(2 * 60 * 60), @(3 * 60 * 60), @(4 * 60 * 60), @(5 * 60 * 60), @(6 * 60 * 60), @(7 * 60 * 60), @(8 * 60 * 60), @(9 * 60 * 60), @(10 * 60 * 60),
                                @(11 * 60 * 60), @(12 * 60 * 60), @(13 * 60 * 60), @(14 * 60 * 60), @(15 * 60 * 60), @(16 * 60 * 60), @(17 * 60 * 60), @(18 * 60 * 60), @(19 * 60 * 60), @(20 * 60 * 60), @(21 * 60 * 60),
                                @(22 * 60 * 60), @(23 * 60 * 60), @(24 * 60 * 60)];
    } else if ([self.trackerObject.trackerType isEqualToString:kASTrackerTypeVT600]) {
        self.ratePickerData = @[@(20), @(30), @(40), @(50), @(60), @(2 * 60), @(3 * 60), @(5 * 60), @(7 * 60), @(10 * 60), @(20 * 60), @(30 * 60), @(40 * 60), @(50 * 60), @(60 * 60)];
    } else if ([self.trackerObject.trackerType isEqualToString:kASTrackerTypeTkS1]){
        self.ratePickerData = @[@(10),@(20), @(30), @(40), @(50), @(60), @(2*60), @(3*60), @(4 * 60), @(5 * 60), @(7 * 60), @(8 * 60), @(9 * 60), @(10 * 60)];
    
    } else {
        self.ratePickerData = @[@(20), @(30), @(40), @(50), @(60), @(2*60), @(3*60)];
    }
    
    self.ratePicker = [[UIPickerView alloc] init];
    self.ratePicker.backgroundColor = [UIColor whiteColor];
    self.ratePicker.delegate = self;
    self.ratePicker.dataSource = self;

    self.choosedTime = (self.trackerObject.signalRateInSeconds.integerValue == 0) ? @60 : self.trackerObject.signalRateInSeconds;
    
    if ([self.ratePickerData containsObject:self.choosedTime]) {
        [self.ratePicker selectRow:[self.ratePickerData indexOfObject:self.choosedTime]
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
    
    [self updateRateTextField];
}

-(void)doneTapped:(id)sender
{
    [self.signalRateTextField resignFirstResponder];
}

-(void)updateTrackerObject {
    self.trackerObject.trackerName         = self.nameTextField.text;
    self.trackerObject.imeiNumber          = self.imeiTextField.text;
    self.trackerObject.trackerNumber       = self.trackerNumberTextField.text;
    self.trackerObject.dogInStand          = self.dogInStandSwitcher.isOn;
    self.trackerObject.signalRateInSeconds = self.choosedTime;
}

-(void)updateRateTextField {
    self.signalRateTextField.text = self.ratePickerStrings[self.choosedTime];
}

- (IBAction)ledLightTap:(id)sender {
    RACSignal *signal = [self as_sendSMS:[ASTrackerModel getSmsTextsForBikeLedLightForMode:!self.trackerObject.bikeLedLightIsOn]
                             ToRecipient:self.trackerObject.trackerPhoneNumber];
    [signal subscribeNext:^(NSNumber *result) {
        if (result.integerValue == MessageComposeResultSent) {
            self.trackerObject.bikeLedLightIsOn = !self.trackerObject.bikeLedLightIsOn;
            [self.trackerObject saveInUserDefaults];
        }
    } error:^(NSError *error) {
        DDLogError(@"Error sending Sms %@", error);
    }];
}

- (IBAction)shockAlarmTap:(id)sender {
    RACSignal *signal = [self as_sendSMS:[ASTrackerModel getSmsTextsForBikeShockAlarmForMode:!self.trackerObject.bikeShockAlarmIsOn]
                             ToRecipient:self.trackerObject.trackerPhoneNumber];
    [signal subscribeNext:^(NSNumber *result) {
        if (result.integerValue == MessageComposeResultSent) {
            self.trackerObject.bikeShockAlarmIsOn = !self.trackerObject.bikeShockAlarmIsOn;
            [self.trackerObject saveInUserDefaults];
        }
    } error:^(NSError *error) {
        DDLogError(@"Error sending Sms %@", error);
    }];
}

- (IBAction)flashAlarmTap:(id)sender {
    if (self.trackerObject.bikeFlashAlarmIsOn) {
        return;
    }
    
    RACSignal *signal = [self as_sendSMS:[ASTrackerModel getSmsTextsForBikeFlashAlarm]
                             ToRecipient:self.trackerObject.trackerPhoneNumber];
    [signal subscribeNext:^(NSNumber *result) {
        if (result.integerValue == MessageComposeResultSent) {
            self.trackerObject.bikeFlashAlarmIsOn = !self.trackerObject.bikeFlashAlarmIsOn;
            [self.trackerObject saveInUserDefaults];
        }
    } error:^(NSError *error) {
        DDLogError(@"Error sending Sms %@", error);
    }];
}

- (IBAction)sleepModeTap:(id)sender {
    RACSignal *signal = [self as_sendSMS:[ASTrackerModel getSmsTextForSleepMode:!self.trackerObject.dogSleepModeIsOn]
                             ToRecipient:self.trackerObject.trackerPhoneNumber];
    [signal subscribeNext:^(NSNumber *result) {
        if (result.integerValue == MessageComposeResultSent) {
            self.trackerObject.dogSleepModeIsOn = !self.trackerObject.dogSleepModeIsOn;
            [self.trackerObject saveInUserDefaults];
        }
    } error:^(NSError *error) {
        DDLogError(@"Error sending Sms %@", error);
    }];
}

- (IBAction)batteryCheckTap:(id)sender {
    RACSignal *signal = [self as_sendSMS:[ASTrackerModel getSmsTextForCheckBattery]
                             ToRecipient:self.trackerObject.trackerPhoneNumber];
    [signal subscribeError:^(NSError *error) {
        DDLogError(@"Error sending Sms %@", error);
    }];
}

@end
