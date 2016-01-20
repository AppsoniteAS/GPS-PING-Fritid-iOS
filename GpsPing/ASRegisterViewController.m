//
//  ASRegisterViewController.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASRegisterViewController.h"
#import "ASRegisterViewModel.h"
#import <JPSKeyboardLayoutGuideViewController.h>
#import "Masonry.h"

@interface ASRegisterViewController ()
@property (nonatomic, readonly) ASRegisterViewModel     *viewModel;
@property (nonatomic, weak    ) IBOutlet UIView       *viewKeyboardInteractive;
@property (nonatomic, weak    ) IBOutlet UITextField  *textFieldUsername;
@property (nonatomic, weak    ) IBOutlet UITextField  *textFieldEmail;
@property (nonatomic, weak    ) IBOutlet UITextField  *textFieldPassword;
@property (nonatomic, weak    ) IBOutlet UITextField  *textFieldConfirmPassword;
@property (nonatomic, weak    ) IBOutlet UIButton     *buttonSubmit;
@end

@implementation ASRegisterViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self jps_viewDidLoad];
    [self.viewKeyboardInteractive mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.keyboardLayoutGuide);
    }];
    
    self->_viewModel = [[ASRegisterViewModel alloc] init];
    
    self.textFieldUsername.text      = self.viewModel.username;
    RAC(self.viewModel, username)    = self.textFieldUsername.rac_textSignal;
    
    self.textFieldEmail.text = self.viewModel.email;
    RAC(self.viewModel, email)    = self.textFieldEmail.rac_textSignal;
    
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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self jps_viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self jps_viewDidDisappear:animated];
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
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
