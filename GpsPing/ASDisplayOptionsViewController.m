//
//  ASDisplayOptionsViewController.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/29/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASDisplayOptionsViewController.h"
#import "UIStoryboard+ASHelper.h"
#import <JPSKeyboardLayoutGuideViewController.h>
#import "Masonry.h"
#import "ASButton.h"

#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
static NSString * const kTrackingDurationKey = @"tracking_duration";

@interface ASDisplayOptionsViewController () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *outerWrapperView;
@property (weak, nonatomic) IBOutlet ASButton *submitButton;

@property (nonatomic) NSNumber *duration;
@property (weak, nonatomic) IBOutlet UITextField *durationTextField;

@property (nonatomic) NSArray      *durationPickerData;
@property (nonatomic) UIPickerView *durationPicker;

@end

@implementation ASDisplayOptionsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self jps_viewDidLoad];
    self.durationPickerData = @[@"10 minutes", @"15 minutes", @"30 minutes", @"60 minutes"];
    
    self.duration = [self loadSavedTrackingDuration];
    if ([self.duration intValue] > 0) {
        self.durationTextField.text = [NSString stringWithFormat:@"%@ minutes", self.duration];
    }
    
    [self configPickers];
}

-(void)configPickers {
    self.durationPicker = [[UIPickerView alloc] init];
    self.durationPicker.backgroundColor = [UIColor whiteColor];
    self.durationPicker.delegate = self;
    self.durationPicker.dataSource = self;
    self.durationTextField.inputView = self.durationPicker;
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.durationPicker.frame.size.width, 44)];
    accessoryView.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
    
    accessoryView.items = [NSArray arrayWithObjects:space,done, nil];
    self.durationTextField.inputAccessoryView = accessoryView;
}

-(void)doneTapped:(id)sender {
    [self.durationTextField resignFirstResponder];
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

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.durationPickerData.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.durationPickerData[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.durationTextField.text = self.durationPickerData[row];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

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


@end
