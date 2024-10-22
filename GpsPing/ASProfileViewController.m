//
//  ASProfileViewController.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/21/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASProfileViewController.h"
#import "ASProfileViewModel.h"
#import <CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelDebug;

@interface ASProfileViewController ()

@property (nonatomic, readonly) ASProfileViewModel   *viewModel;

@property (weak, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *textFieldFullName;

@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;

@property (weak, nonatomic) IBOutlet UITextField *textFieldPhoneCode;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPhoneNumber;

@property (weak, nonatomic) IBOutlet UITextField *textFieldAddress;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCity;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCountry;
@property (weak, nonatomic) IBOutlet UITextField *textFieldZipCode;

@property (weak, nonatomic) IBOutlet UIButton    *buttonSubmit;

@property (weak, nonatomic) IBOutlet UILabel *labelProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (weak, nonatomic) IBOutlet UILabel *labelFullName;
@property (weak, nonatomic) IBOutlet UILabel *labelAddress;
@property (weak, nonatomic) IBOutlet UILabel *labelPostcode;
@property (weak, nonatomic) IBOutlet UILabel *labelCity;
@property (weak, nonatomic) IBOutlet UILabel *labelCountry;
@property (weak, nonatomic) IBOutlet UILabel *labelCode;
@property (weak, nonatomic) IBOutlet UILabel *labelPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnLogout;


@end

@implementation ASProfileViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    
    self->_viewModel = [[ASProfileViewModel alloc] init];
    
    self.textFieldEmail.enabled = false;
    self.textFieldUsername.enabled = false;
    
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
    
    [[RACObserve(self.viewModel, phoneCode) distinctUntilChanged] subscribeNext:^(NSString* phoneCode) {
        @strongify(self);
        self.textFieldPhoneCode.text   = phoneCode;
    }];
    RAC(self.viewModel, phoneCode) = self.textFieldPhoneCode.rac_textSignal;
    
    [[RACObserve(self.viewModel, phoneNumber) distinctUntilChanged] subscribeNext:^(NSString* phoneNumber) {
        @strongify(self);
        self.textFieldPhoneNumber.text   = phoneNumber;
    }];
    RAC(self.viewModel, phoneNumber) = self.textFieldPhoneNumber.rac_textSignal;
    
    [[RACObserve(self.viewModel, address) distinctUntilChanged] subscribeNext:^(NSString* address) {
        @strongify(self);
        self.textFieldAddress.text   = address;
    }];
    RAC(self.viewModel, address) = self.textFieldAddress.rac_textSignal;
    
    [[RACObserve(self.viewModel, city) distinctUntilChanged] subscribeNext:^(NSString* city) {
        @strongify(self);
        self.textFieldCity.text   = city;
    }];
    RAC(self.viewModel, city) = self.textFieldCity.rac_textSignal;
    
    [[RACObserve(self.viewModel, country) distinctUntilChanged] subscribeNext:^(NSString* country) {
        @strongify(self);
        self.textFieldCountry.text   = country;
    }];
    RAC(self.viewModel, country) = self.textFieldCountry.rac_textSignal;
    
    [[RACObserve(self.viewModel, zipCode) distinctUntilChanged] subscribeNext:^(NSString* zipCode) {
        @strongify(self);
        self.textFieldZipCode.text   = zipCode;
    }];
    RAC(self.viewModel, zipCode) = self.textFieldZipCode.rac_textSignal;
    
    self.buttonSubmit.rac_command = self.viewModel.submit;

    [self rac_liftSelector:@selector(onError:)
               withSignals:self.buttonSubmit.rac_command.errors, nil];
    
//    [self rac_liftSelector:@selector(doSubmit:)
//               withSignals:self.buttonSubmit.rac_command.executionSignals.flatten, nil];
//
    
//    [self rac_liftSelector:@selector(doSubmit:)
//               withSignals:self.buttonSubmit.rac_command.executing, nil];
    
    [self localizeAll];
}

-(void)onError:(NSError*)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                    message:error.localizedDescription
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)doSubmit:(id)x {
    
    DDLogInfo(@"x: %@", x);
    if ([x integerValue] == 1){
        self.navigationItem.hidesBackButton = true;
    } else {
        self.navigationItem.hidesBackButton = false;
    }
}

#pragma mark - IBActions

-(IBAction)doLogout:(id)sender {
    [self.viewModel logOut];
    self.navigationItem.backBarButtonItem.enabled = true;

}

- (void) localizeAll{
    self.labelUserName.text = NSLocalizedString(@"profile_username", nil);
    self.labelFullName.text = NSLocalizedString(@"profile_fullname", nil);
    self.labelAddress.text = NSLocalizedString(@"profile_address", nil);
    self.labelPostcode.text = NSLocalizedString(@"profile_postcode", nil);
    self.labelCity.text = NSLocalizedString(@"profile_city", nil);
    self.labelCountry.text = NSLocalizedString(@"profile_country", nil);
    self.labelCode.text = NSLocalizedString(@"profile_code", nil);
    self.labelPhoneNumber.text = NSLocalizedString(@"profile_phonenumber", nil);
    self.labelEmail.text = NSLocalizedString(@"profile_email", nil);

    NSString* save = NSLocalizedString(@"profile_save", nil);
    NSString* logout = NSLocalizedString(@"profile_logout", nil);
    [self.btnLogout setTitle:logout];
    [_buttonSubmit setTitle:save forState:UIControlStateNormal];
    [_buttonSubmit setTitle:save forState:UIControlStateSelected];
    [_buttonSubmit setTitle:save forState:UIControlStateHighlighted];
    self.title =  NSLocalizedString(@"tabbar_settings", nil);
    self.labelProfile.text = NSLocalizedString(@"profile_title", nil);
}

@end
