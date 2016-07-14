//
//  ASRegisterViewController.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASRegisterViewController.h"
#import "ASRegisterViewModel.h"
#import "UIStoryboard+ASHelper.h"
#import "ASNewTrackerViewController.h"
#import <JPSKeyboardLayoutGuideViewController.h>
#import "Masonry.h"

@interface ASRegisterViewController ()

@property (readonly, nonatomic) ASRegisterViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;

@property (weak, nonatomic) IBOutlet UITextField *textFieldPhoneCode;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPhoneNumber;

@property (weak, nonatomic) IBOutlet UITextField *textFieldAddress;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCity;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCountry;
@property (weak, nonatomic) IBOutlet UITextField *textFieldZipCode;

@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet UITextField *textFieldConfirmPassword;

@property (weak, nonatomic) IBOutlet UIButton    *buttonSubmit;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ASRegisterViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self jps_viewDidLoad];

    self->_viewModel = [[ASRegisterViewModel alloc] init];
    
    self.textFieldUsername.text      = self.viewModel.username;
    RAC(self.viewModel, username)    = self.textFieldUsername.rac_textSignal;
    
    self.textFieldEmail.text = self.viewModel.email;
    RAC(self.viewModel, email) = self.textFieldEmail.rac_textSignal;
    
    self.textFieldPhoneCode.text = self.viewModel.phoneCode;
    RAC(self.viewModel, phoneCode) = self.textFieldPhoneCode.rac_textSignal;
    
    self.textFieldPhoneNumber.text = self.viewModel.phoneNumber;
    RAC(self.viewModel, phoneNumber) = self.textFieldPhoneNumber.rac_textSignal;
    
    self.textFieldAddress.text   = self.viewModel.address;
    RAC(self.viewModel, address) = self.textFieldAddress.rac_textSignal;
    
    self.textFieldCity.text   = self.viewModel.city;
    RAC(self.viewModel, city) = self.textFieldCity.rac_textSignal;
    
    self.textFieldCountry.text   = self.viewModel.country;
    RAC(self.viewModel, country) = self.textFieldCountry.rac_textSignal;
    
    self.textFieldZipCode.text   = self.viewModel.zipCode;
    RAC(self.viewModel, zipCode) = self.textFieldZipCode.rac_textSignal;
    
    self.textFieldPassword.text   = self.viewModel.password;
    RAC(self.viewModel, password) = self.textFieldPassword.rac_textSignal;
    
    self.textFieldConfirmPassword.text   = self.viewModel.confirmPassword;
    RAC(self.viewModel, confirmPassword) = self.textFieldConfirmPassword.rac_textSignal;
    
    self.buttonSubmit.rac_command = self.viewModel.submit;
    
    [self rac_liftSelector:@selector(doSubmit:)
               withSignals:self.buttonSubmit.rac_command.executionSignals.flatten, nil];

    [self rac_liftSelector:@selector(onError:)
               withSignals:self.buttonSubmit.rac_command.errors, nil];
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


-(void)onError:(NSError*)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                    message:NSLocalizedStringFromTable(error.localizedDescription, @"Errors", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - IBActions

-(IBAction)doSubmit:(id)sender {
}

@end
