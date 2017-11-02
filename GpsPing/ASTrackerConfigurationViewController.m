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
#import "ASDisplayOptionsViewController.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "ASMapViewController.h"
#import "UIStoryboard+ASHelper.h"
#import <YYWebImage.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
@import MessageUI;
#import "ASS3Manager.h"

static NSString *const kASUserDefaultsKeyBikeLedLight   = @"kASUserDefaultsKeyBikeLedLight";
static NSString *const kASUserDefaultsKeyBikeShockAlarm = @"kASUserDefaultsKeyBikeShockAlarm";
static NSString *const kASUserDefaultsKeyBikeFlashAlarm = @"kASUserDefaultsKeyBikeFlashAlarm";

@interface ASTrackerConfigurationViewController()<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate>

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
@property (weak, nonatomic) IBOutlet ASButton    *resetButton;
@property (weak, nonatomic) IBOutlet UILabel *labelStatusSleepMode;
@property (weak, nonatomic) IBOutlet ASButton *buttonDogSleepMode;
@property (weak, nonatomic) IBOutlet ASButton *buttonCheckBattery;
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
@property (weak, nonatomic) IBOutlet UIView *photoContainer;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewPlaceholder;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewPhoto;
@property (weak, nonatomic) IBOutlet UIButton *buttonPhoto;

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
@property (nonatomic) NSNumber *duration;

//tracking history
@property (weak, nonatomic) IBOutlet ASButton *submitButton;
@property (weak, nonatomic) IBOutlet UITextField *durationTextField;

@property (nonatomic) NSArray      *durationPickerData;
@property (nonatomic) UIPickerView *durationPicker;


@property (strong, nonatomic  ) NSString      *yards;
//signal
@property (nonatomic, weak    ) IBOutlet UITextField  *textFieldYards;
@property (nonatomic, weak    ) IBOutlet UIButton     *buttonGeofence;

@property (weak, nonatomic) IBOutlet UITextField *signalRateTextField;

@end

@implementation ASTrackerConfigurationViewController

objection_requires(@keypath(ASTrackerConfigurationViewController.new, apiController))

+(instancetype)initializeWithTrackerModel:(ASTrackerModel *)trackerModel
{
    NSString *className;
    NSString* t = [trackerModel.trackerType stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([t isEqualToString:kASTrackerTypeLK209] || [t isEqualToString:kASTrackerTypeVT600] || [t isEqualToString:kASTrackerTypeLK330] || [t isEqualToString:kASTrackerTypeTkS1] || [t isEqualToString:kASTrackerTypeTkA9]){
        className = @"ASTrackerConfigurationViewController_Industry";
    } else if ([t isEqualToString:kASTrackerTypeTkStarBike] ||  [t isEqualToString:kASTrackerTypeTkStarPet]){
            className = [NSString stringWithFormat:@"%@_%@", NSStringFromClass([ASTrackerConfigurationViewController class]),
                                                              t];
    } else {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"A server has returned the incorrect tracker's type"
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles: nil] show];
        return nil;
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
    @weakify(self)
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
    [self jps_viewDidLoad];

    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.colors = @[(id)[UIColor whiteColor].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor];
    layer.locations = @[@(0), @(0.5)];
    layer.frame = CGRectMake(0, 0, self.imageViewPhoto.frame.size.width, self.imageViewPhoto.frame.size.height);
    [self.imageViewPhoto.layer insertSublayer:layer atIndex:0];
    
    if (self.trackerObject.trackerName) {
        self.nameTextField.text = self.trackerObject.trackerName;
    }
    RAC(self.trackerObject, trackerName) = self.nameTextField.rac_textSignal;
    
    self.trackerNumberTextField.text = self.trackerObject.trackerNumber;
    self.imeiTextField.text = self.trackerObject.imeiNumber;
    
   // self.nameTextField.enabled = false;
    self.imeiTextField.enabled = false;
    self.trackerNumberTextField.enabled = false;

    [self.dogInStandSwitcher setOn:self.trackerObject.dogInStand];

    [self configPickers];
    
    self.startStopButton.layer.borderColor = [UIColor colorWithRed:0.4796 green:0.7302 blue:0.2274 alpha:1.0].CGColor;
    self.startStopButton.layer.borderWidth = 6.0;
    
    self.startStopButton.layer.cornerRadius = self.startStopButton.frame.size.width/2;
    
    
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

    self.durationPickerData = @[@"10 minutes", @"15 minutes", @"30 minutes", @"60 minutes"];
    
    self.duration = [self loadSavedTrackingDuration];
    if ([self.duration intValue] > 0) {
        self.durationTextField.text = [NSString stringWithFormat:@"%@ minutes", self.duration];
    }
    
    [self configPickers];
    
    
    
    self.textFieldYards.text      = self.yards;
    RAC(self, yards)    = self.textFieldYards.rac_textSignal;
    
    [self.buttonGeofence addTarget:self
                 action:@selector(doSubmit:)
       forControlEvents:UIControlEventTouchUpInside];

    [self updateGeoButton];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    
    self.navigationItem.rightBarButtonItem = nil;
    
    if (self.trackerObject.imageId){
        [self.imageViewPhoto yy_setImageWithURL:[ [ASS3Manager sharedInstance] getURLByImageIdentifier: self.trackerObject.imageId ]placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            if (from == YYWebImageFromDiskCache) {
                @strongify(self)
                DDLogDebug(@"load from disk cache");
                [self showPhotoHidePlaceholder:true];

            }
        }];
    } else{
        [self showPhotoHidePlaceholder:false];
    }
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
    [self updateButton];

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
    if (pickerView == self.durationPicker){
        return self.durationPickerData.count;
    }
    return self.ratePickerData.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.durationPicker){
         return self.durationPickerData[row];
    }
    return self.ratePickerStrings[self.ratePickerData[row]];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.durationPicker){
        self.durationTextField.text = self.durationPickerData[row];
        return;
    }
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
          ToRecipient:self.trackerObject.trackerPhoneNumber] subscribeError:^(NSError *error) {
        [[UIAlertView alertWithTitle:NSLocalizedString(@"Error", nil) error:error] show];

    } completed:^{
        [[[self.apiController updateTracker:self.trackerObject.trackerName
                                  trackerId:self.trackerObject.imeiNumber
                                 repeatTime:repeatTime
                              checkForStand:self.trackerObject.dogInStand] deliverOnMainThread] subscribeNext:^(id x) {
            DDLogDebug(@"Tracker updated!");
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }];
    

}


- (IBAction)updateInfo:(id)sender {
    CGFloat repeatTime = self.trackerObject.signalRateInSeconds.integerValue;

    [[[self.apiController updateTracker:self.trackerObject.trackerName
                              trackerId:self.trackerObject.imeiNumber
                             repeatTime:repeatTime
                          checkForStand:self.trackerObject.dogInStand] deliverOnMainThread] subscribeNext:^(id x) {
        DDLogDebug(@"Tracker updated!");
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
    } else if ([self.trackerObject.trackerType isEqualToString:kASTrackerTypeTkS1] || [self.trackerObject.trackerType isEqualToString:kASTrackerTypeTkA9]){
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
    
    
    self.durationPicker = [[UIPickerView alloc] init];
    self.durationPicker.backgroundColor = [UIColor whiteColor];
    self.durationPicker.delegate = self;
    self.durationPicker.dataSource = self;
    self.durationTextField.inputView = self.durationPicker;
    UIToolbar *accessoryView2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.durationPicker.frame.size.width, 44)];
    accessoryView2.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *done2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
    
    accessoryView2.items = [NSArray arrayWithObjects:space2,done2, nil];
    self.durationTextField.inputAccessoryView = accessoryView2;
}

-(void)doneTapped:(id)sender
{
    [self.signalRateTextField resignFirstResponder];
    [self.durationTextField resignFirstResponder];

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

#pragma mark - Tracking History

- (void)saveTrackingDurationLocally:(NSNumber*)duration{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:duration forKey:kTrackingDurationKey];
    [defaults synchronize];
}

- (NSNumber*)loadSavedTrackingDuration {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kTrackingDurationKey];
}

- (IBAction)doSave:(id)sender {
    NSArray *subStrings = [self.durationTextField.text componentsSeparatedByString:@" "];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterNoStyle;
    [self saveTrackingDurationLocally:[formatter numberFromString:subStrings[0]]];
}


#pragma mark - start stop

- (IBAction)startStopButtonTap:(id)sender {
    ASTrackerModel *trackerModel = self.trackerObject;
    
    if (!trackerModel) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No tracker choosed", nil)
                                    message:NSLocalizedString(@"You must choose tracker on Trackers screen in Settings to start it", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles: nil] show];
        return;
    }
    
    [[self as_sendSMS:[trackerModel getSmsTextsForTrackerLaunch:!trackerModel.isRunning]
          ToRecipient:trackerModel.trackerPhoneNumber] subscribeNext:^(id x) {
        [self updateCurrentTracker];
    } error:^(NSError *error) {
        ;
    }];
}

-(void)updateCurrentTracker
{
    ASTrackerModel *trackerModel = self.trackerObject;
    trackerModel.isRunning = !trackerModel.isRunning;
    [trackerModel saveInUserDefaults];
    [self updateButton];
}

-(void)updateButton {
    ASTrackerModel *trackerModel = self.trackerObject;
    if (trackerModel.isRunning) {
        [self.startStopButton setTitle:NSLocalizedString(@"STOP", nil) forState:UIControlStateNormal];
    } else {
        [self.startStopButton setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    }
}

#pragma mark - Photo

- (void) showPhotoHidePlaceholder: (bool) need{
    self.imageViewPlaceholder.alpha = need ? 0 : 1;
    if (!need){
        self.imageViewPhoto.image = nil;
    }
   // self.photoContainer.backgroundColor = need ? [UIColor clearColor] : [UIColor colorWithWhite:1.0 alpha:0.8];
}

- (IBAction)pressedPhoto:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* libraryAction = [UIAlertAction actionWithTitle:@"Photo album" style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
    
    
                                                         picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
                                                         [self presentViewController:picker animated:YES completion:NULL];
                                                     }];
    
    
    UIAlertAction* removeAction = [UIAlertAction actionWithTitle:@"Remove photo" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              

                                                              [[self.apiController removeImageForTrackerId:self.trackerObject.imeiNumber] subscribeNext:^(id x) {
                                                                  DDLogDebug(@"removed photo");
                                                                  [self showPhotoHidePlaceholder:false];
                                                                  self.trackerObject.imageId = nil;
                                                                  [self.trackerObject saveInUserDefaults];
                                                              } error:^(NSError *error) {
                                                                  DDLogError(@"%@", error.localizedDescription);
                                                              }];
                                                          }];
    
    
    UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         
                                                         
                                                         picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                         
                                                         [self presentViewController:picker animated:YES completion:NULL];
                                                     }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             
                                                         }];
    
    [alert addAction:libraryAction];
    [alert addAction:cameraAction];
    [alert addAction:removeAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:true completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage* selectedImage = info[UIImagePickerControllerEditedImage];
    NSString* imageIdentifier =  [NSString stringWithFormat:@"%@.jpg", [[NSUUID UUID] UUIDString] ];

    [[[[ASS3Manager sharedInstance] handleCognitoS3:imageIdentifier image:selectedImage] flattenMap:^RACStream *(id value) {
        return [self.apiController updateImage:imageIdentifier forTrackerId:self.trackerObject.imeiNumber];
    }] subscribeNext:^(id x) {
        DDLogInfo(@"succefull upload!");
        //self.photoContainer.backgroundColor = [UIColor clearColor];
        self.imageViewPlaceholder.alpha = 0;
        self.imageViewPhoto.image  = selectedImage;
        self.trackerObject.imageId = imageIdentifier;
        [self.trackerObject saveInUserDefaults];
    } error:^(NSError *error) {
        DDLogError(@"error upload!");
    }];
    

    [picker dismissViewControllerAnimated:YES completion:NULL];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction)viewHistory:(ASButton *)sender {
    ASMapViewController *mapVC = [ASMapViewController initialize];
    mapVC.isHistoryMode = YES;
    mapVC.selectedTracker = self.trackerObject;
    [self.navigationController pushViewController:mapVC animated:true];
    //[self presentViewController:mapVC animated:true completion:nil];
    
    
  //  [[UIStoryboard mapStoryboard] instantiateViewController
}

#pragma mark - Pause subscription
- (IBAction)pauseSubscription:(id)sender {
    @weakify(self)
    if (![MFMailComposeViewController canSendMail]) {
        NSLog(@"Mail services are not available.");
        return;
    }
    [[self.apiController getTrackers] subscribeNext:^(NSArray *trackers) {
        @strongify(self)
        
        
        MFMailComposeViewController *composeVC = [[MFMailComposeViewController alloc] init];
        composeVC.mailComposeDelegate = self;
        [composeVC setToRecipients:@[@"support@gpsping.no"]];
        [composeVC setSubject:@"Pause Subscription"];
        
        ASUserProfileModel *profileModel = [ASUserProfileModel loadSavedProfileInfo];
        NSString *message = [NSString stringWithFormat:@"Please put my subscription on pause\n\n Name: %@ %@\nAddress: %@\nUsername: %@\nTracker's phone: %@\n  imei: %@\n", profileModel.firstname, profileModel.lastname, profileModel.address, profileModel.username, self.trackerObject.trackerPhoneNumber, self.trackerObject.imeiNumber];
        
        [composeVC setMessageBody:message isHTML:NO];
        [self presentViewController:composeVC animated:NO completion:nil];
    }];
    
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Geofence

-(void)doSubmit:(id)sender {
    
    if (!(self.yards.length > 0)){
        return;
    }
    [[self as_sendSMS:[ASTrackerModel getSmsTextsForGeofenceLaunch:!(self.trackerObject.isGeofenceStarted)
                                                          distance:self.yards]
          ToRecipient:self.trackerObject.trackerPhoneNumber] subscribeNext:^(id x) {
        ASTrackerModel *activeTracker = self.trackerObject;
        activeTracker.isGeofenceStarted = !activeTracker.isGeofenceStarted;
        
        if (activeTracker.isGeofenceStarted) {
            activeTracker.geofenceYards = self.yards;
        }
        
        [activeTracker saveInUserDefaults];
        
        [self updateGeoButton];
    } error:^(NSError *error) {
        ;
    }];
}

-(void)onError:(NSError*)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                    message:error.localizedDescription
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


-(void)updateGeoButton {
    if (self.trackerObject.isGeofenceStarted) {
        [self.buttonGeofence setTitle:NSLocalizedString(@"STOP", nil) forState:UIControlStateNormal];
        self.textFieldYards.text = self.trackerObject.geofenceYards;
    } else {
        [self.buttonGeofence setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    }
}


-(RACCommand *)submitGeo {
    
    RACSignal* isCorrect = [RACSignal combineLatest:@[RACObserve(self, yards)]
                                             reduce:^id(NSString* yards)
                            {
                                return @((yards.length > 0) && self.trackerObject.isChoosed);
                            }];
    
    return [[RACCommand alloc] initWithEnabled:isCorrect
                                   signalBlock:^RACSignal *(id input)
            {
                return [RACSignal return:nil];
            }];
}


@end
