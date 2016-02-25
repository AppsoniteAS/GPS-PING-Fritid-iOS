//
//  ASSignInViewController.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASSignInViewController.h"
#import "ASSignInViewModel.h"

@interface ASSignInViewController ()
@property (nonatomic, readonly) ASSignInViewModel     *viewModel;
@property (nonatomic, weak    ) IBOutlet UITextField  *textFieldUsername;
@property (nonatomic, weak    ) IBOutlet UITextField  *textFieldPassword;
@property (nonatomic, weak    ) IBOutlet UIButton     *buttonSubmit;
@end

@implementation ASSignInViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    self->_viewModel = [[ASSignInViewModel alloc] init];
    
    self.textFieldUsername.text   = self.viewModel.username;
    RAC(self.viewModel, username) = self.textFieldUsername.rac_textSignal;
    self.textFieldPassword.text   = self.viewModel.password;
    RAC(self.viewModel, password) = self.textFieldPassword.rac_textSignal;
    self.buttonSubmit.rac_command = self.viewModel.submit;
    
    [self rac_liftSelector:@selector(doSubmit:)
               withSignals:self.buttonSubmit.rac_command.executionSignals.flatten, nil];
    [self rac_liftSelector:@selector(onError:)
               withSignals:self.buttonSubmit.rac_command.errors, nil];
}

-(void)onError:(NSError*)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                    message:NSLocalizedStringFromTable(error.localizedDescription, @"Errors", nil)
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
