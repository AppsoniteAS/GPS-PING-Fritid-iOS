//
//  ASSettingsViewController.m
//  GpsPing
//
//  Created by Maks Niagolov on 2/25/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASSettingsViewController.h"
#import "UIStoryboard+ASHelper.h"
#import "ASTrackerModel.h"
#import "ASInAppPurchaseManager.h"
#import "ASChooseTrackerViewController.h"
#import "UIStoryboard+ASHelper.h"
#import "Masonry.h"
#import "ASButton.h"
#import "ASProfileViewModel.h"
#import <JPSKeyboardLayoutGuideViewController.h>

#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@interface ASSettingsViewController () <ASInAppPurchaseDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) ASInAppPurchaseManager* inAppPurchaseManager;
@property (nonatomic) NSNumber     *duration;
@property (nonatomic) NSArray      *durationPickerData;
@property (nonatomic) UIPickerView *durationPicker;
@property (nonatomic, readonly) ASProfileViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UITextField *durationTextField;
@property (weak, nonatomic) IBOutlet ASButton    *submitButton;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPhone;
@property (nonatomic, weak) IBOutlet UITextField *textFieldUsername;
@property (nonatomic, weak) IBOutlet UITextField *textFieldFullName;
@property (nonatomic, weak) IBOutlet UITextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet UIScrollView*scrollView;

@end

@implementation ASSettingsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self jps_viewDidLoad];

    self.inAppPurchaseManager = [ASInAppPurchaseManager new];
    self.inAppPurchaseManager.delegate = self;
    
    self.durationPickerData = @[@"10 minutes", @"15 minutes", @"30 minutes", @"60 minutes"];
    
    self.duration = [self loadSavedTrackingDuration];
    if ([self.duration intValue] > 0) {
        self.durationTextField.text = [NSString stringWithFormat:@"%@ minutes", self.duration];
    }
    
    [self configPickers];
    
    [self registerForKeyboardNotifications];
    
    [self bindViewModel];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self jps_viewWillAppear:animated];
    [self.scrollView mas_makeConstraints:^
     (MASConstraintMaker *make) {
         make.bottom.equalTo(self.keyboardLayoutGuide);
     }];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self jps_viewDidDisappear:animated];
}

#pragma mark - Bind View Model

- (void)bindViewModel {
    self->_viewModel = [[ASProfileViewModel alloc] init];
    
    @weakify(self);
    [[RACObserve(self.viewModel, username) distinctUntilChanged] subscribeNext:^(NSString* username) {
        @strongify(self);
        self.textFieldUsername.text = username;
    }];
    RAC(self.viewModel, username)    = self.textFieldUsername.rac_textSignal;
    
    [[RACObserve(self.viewModel, fullName) distinctUntilChanged] subscribeNext:^(NSString* fullName) {
        @strongify(self);
        self.textFieldFullName.text   = fullName;
    }];
    RAC(self.viewModel, fullName) = self.textFieldFullName.rac_textSignal;
    
    [[RACObserve(self.viewModel, email) distinctUntilChanged] subscribeNext:^(NSString* email) {
        @strongify(self);
        self.textFieldEmail.text   = email;
    }];
    RAC(self.viewModel, email) = self.textFieldEmail.rac_textSignal;
    
    [[RACObserve(self.viewModel, phone) distinctUntilChanged] subscribeNext:^(NSString* value) {
        @strongify(self);
        self.textFieldPhone.text   = value;
    }];
    RAC(self.viewModel, phone) = self.textFieldPhone.rac_textSignal;
    
    self.submitButton.rac_command = self.viewModel.submit;
    
    [self rac_liftSelector:@selector(doSave:)
               withSignals:self.submitButton.rac_command.executionSignals.flatten, nil];
    
    [self rac_liftSelector:@selector(onError:)
               withSignals:self.submitButton.rac_command.errors, nil];
}

- (void)doSave:(id)sender {
    NSArray *subStrings = [self.durationTextField.text componentsSeparatedByString:@" "];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterNoStyle;
    [self saveTrackingDurationLocally:[formatter numberFromString:subStrings[0]]];
}

-(void)onError:(NSError*)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                    message:error.localizedDescription
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Private methods

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

- (void)saveTrackingDurationLocally:(NSNumber*)duration{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:duration forKey:kTrackingDurationKey];
    [defaults synchronize];
}

- (NSNumber*)loadSavedTrackingDuration {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kTrackingDurationKey];
}

-(void)checkingForTrackers {
    if ([ASTrackerModel getTrackersFromUserDefaults].count == 0) {
        if(![self.inAppPurchaseManager areSubscribed]) {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:NSLocalizedString(@"You don't have any tracker", nil)
                                                  message:NSLocalizedString(@"Please add a tracker or subscribe to your friend's tracker", nil)
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *addTrackerAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"Add tracker", @"Add tracker")
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   UIViewController* controller = [[UIStoryboard trackerStoryboard] instantiateViewControllerWithIdentifier:NSStringFromClass([ASChooseTrackerViewController  class])];
                                                   [self presentViewController:controller animated:YES completion:nil];
                                               }];
            UIAlertAction *restoreSubscribeAction = [UIAlertAction
                                                     actionWithTitle:NSLocalizedString(@"Restore", @"Restore subscription")
                                                     style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
                                                     {
                                                         [self.inAppPurchaseManager restore];
                                                     }];
            UIAlertAction *subscribeAction = [UIAlertAction
                                              actionWithTitle:NSLocalizedString(@"Subcribe", @"Subcribe action")
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *action)
                                              {
                                                  [self.inAppPurchaseManager subscribe];
                                              }];
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               DDLogDebug(@"Cancel action");
                                               [self.navigationController popoverPresentationController];
                                           }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:addTrackerAction];
            [alertController addAction:restoreSubscribeAction];
            [alertController addAction:subscribeAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            [self openConnect];
        }
    } else {
        [self openConnect];
    }
}

#pragma mark - IBActions

- (IBAction)goToConnect:(id)sender {
    [self checkingForTrackers];
}

-(IBAction)doLogout:(id)sender {
    [self.viewModel logOut];
}

#pragma  mark - ASInAppPurchaseDelegate
-(void)openConnect {
    UIViewController* controller = [[UIStoryboard connectStoryboard] instantiateInitialViewController];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.durationPickerData.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.durationPickerData[row];
}

#pragma mark - UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.durationTextField.text = self.durationPickerData[row];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
