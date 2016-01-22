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

@interface ASTrackerConfigurationViewController()<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MFMessageComposeViewControllerDelegate, ASSmsManagerProtocol>

@property (weak, nonatomic) IBOutlet UIView *outerWrapperView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *imeiTextField;
@property (weak, nonatomic) IBOutlet UITextField *trackerNumberTextField;
@property (weak, nonatomic) IBOutlet UISwitch *dogInStandSwitcher;
@property (weak, nonatomic) IBOutlet ASButton *completeButton;

@property (nonatomic) NSString *metricType;
@property (nonatomic, assign) CGFloat signalRate;
@property (weak, nonatomic) IBOutlet UITextField *signalRateMetricTextField;
@property (weak, nonatomic) IBOutlet UITextField *signalRateTextField;

@property (nonatomic) NSArray      *ratePickerData;
@property (nonatomic) NSArray      *rateMetricPickerData;
@property (nonatomic) UIPickerView *ratePicker;
@property (nonatomic) UIPickerView *rateMetricPicker;

@property (nonatomic, assign) NSInteger smsCount;


@end

@implementation ASTrackerConfigurationViewController

+(instancetype)initialize
{
    return [[UIStoryboard trackerStoryboard] instantiateViewControllerWithIdentifier:NSStringFromClass([ASTrackerConfigurationViewController class])];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self jps_viewDidLoad];
    self.ratePickerData = @[@"1", @"2", @"3", @"5", @"7", @"10", @"20", @"30", @"40", @"50", @"60"];
    self.rateMetricPickerData = @[@"Seconds", @"Minutes"];
    
    if (self.shouldShowInEditMode) {
        self.navigationItem.title = NSLocalizedString(@"Edit Tracker", nil);
        [self.completeButton setTitle:NSLocalizedString(@"Update", nil) forState:UIControlStateNormal];
        
        if (self.trackerObject.trackerName) {
            self.nameTextField.text = self.trackerObject.trackerName;
        }
        
        self.trackerNumberTextField.text = self.trackerObject.trackerNumber;
        self.imeiTextField.text = self.trackerObject.imeiNumber;
        self.signalRateTextField.text = [NSString stringWithFormat:@"%ld", (long)self.trackerObject.signalRate];
        self.signalRateMetricTextField.text = self.trackerObject.signalRateMetric;
        [self.dogInStandSwitcher setOn:self.trackerObject.dogInStand];
    }
    

    [self configPickers];
    
    NSString *newTitle = NSLocalizedString(@"Activation: step %ld", nil);
    [self.completeButton setTitle:[NSString stringWithFormat:newTitle, (long)self.smsCount + 1]
                         forState:UIControlStateNormal];
}

-(void)configPickers {
    self.ratePicker = [[UIPickerView alloc] init];
    self.ratePicker.backgroundColor = [UIColor whiteColor];
    self.ratePicker.delegate = self;
    self.ratePicker.dataSource = self;
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
    self.signalRateMetricTextField.inputView = self.rateMetricPicker;
    self.signalRateMetricTextField.inputAccessoryView = accessoryView;
}

-(void)doneTapped:(id)sender
{
    [self.signalRateMetricTextField resignFirstResponder];
    [self.signalRateTextField resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
        return self.rateMetricPickerData[row];
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.ratePicker) {
        self.signalRateTextField.text = self.ratePickerData[row];
    } else {
        self.signalRateMetricTextField.text = self.rateMetricPickerData[row];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)dogInStandValueChanged:(UISwitch *)sender {
}

- (IBAction)addTrackerTap:(id)sender {
    self.trackerObject.trackerName      = self.nameTextField.text;
    self.trackerObject.imeiNumber       = self.imeiTextField.text;
    self.trackerObject.trackerNumber    = self.trackerNumberTextField.text;
    self.trackerObject.isChoosed        = NO;
    self.trackerObject.dogInStand       = self.dogInStandSwitcher.isOn;
    self.trackerObject.signalRate       = self.signalRateTextField.text.integerValue;
    self.trackerObject.signalRateMetric = self.signalRateMetricTextField.text;
    
    if (self.smsCount == self.trackerObject.getSmsTextsForActivation.count) {
        [self.trackerObject saveInUserDefaults];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    [self as_sendSMS:self.trackerObject.getSmsTextsForActivation[self.smsCount]
           recipient:self.trackerObject.trackerNumber];
}

-(void)smsManagerMessageWasSentWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultSent) {
        self.smsCount++;
        NSString *newTitle;
        if (self.smsCount == self.trackerObject.getSmsTextsForActivation.count) {
            newTitle = NSLocalizedString(@"Finish activation", nil);
        } else {
            newTitle = [NSString stringWithFormat:NSLocalizedString(@"Activation: step %ld", nil), (long)self.smsCount + 1];
        }
    
        [self.completeButton setTitle:newTitle
                             forState:UIControlStateNormal];
    }
}

- (IBAction)cancelButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
