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
//@property (weak, nonatomic) IBOutlet UIView *editButtonsPanel;

@property (nonatomic) NSString *metricType;
@property (nonatomic, assign) CGFloat signalRate;
@property (weak, nonatomic) IBOutlet UITextField *signalRateTextField;
@property (weak, nonatomic) IBOutlet ASButton *updateButton;

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
    
//    NSString *newResetTitle = NSLocalizedString(@"Reset: step %ld", nil);
//    [self.resetButton setTitle:[NSString stringWithFormat:newResetTitle, (long)self.smsCount + 1]
//                         forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.updateButton.hidden = !self.shouldShowInEditMode;
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
            if ([NSLocalizedStringFromTable(error.localizedDescription, @"Errors", nil) isEqualToString:@"Invalid authentication cookie. Use the `generate_auth_cookie` method."]) {
                UIViewController* controller = [[UIStoryboard authStoryboard] instantiateInitialViewController];
                [self presentViewController:controller
                                   animated:YES
                                 completion:nil];
            }
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
    
    [self.completeButton setTitle:[self newTitleForActivation:self.smsCount]
                             forState:UIControlStateNormal];
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

-(void)setRatePickerData:(NSArray *)ratePickerData
{
    _ratePickerData = ratePickerData;
    
    NSMutableDictionary *valuesDictionary = @{}.mutableCopy;
    NSString *secondsString = NSLocalizedString(@"%d seconds", nil);
    NSString *minutesString = NSLocalizedString(@"%d minutes", nil);
    for (NSNumber *value in ratePickerData) {
        if (value.integerValue >= 60) {
            valuesDictionary[value] = [NSString localizedStringWithFormat:minutesString, value.integerValue/60];
        } else {
            valuesDictionary[value] = [NSString localizedStringWithFormat:secondsString, value.integerValue];
        }
    }
    self.ratePickerStrings = [NSDictionary dictionaryWithDictionary:valuesDictionary];
}

#pragma mark - Private methods

-(void)configPickers {
    self.ratePickerData = @[@(20), @(30), @(40), @(50), @(60), @(2*60), @(3*60), @(5*60), @(7*60), @(10*60), @(20*60), @(30*60), @(40*60), @(50*60), @(60*60)];
    
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

@end
