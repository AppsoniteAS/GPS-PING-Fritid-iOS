//
//  ASProfileViewController.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/21/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASProfileViewController.h"
#import "ASProfileViewModel.h"

@interface ASProfileViewController ()
@property (nonatomic, readonly) ASProfileViewModel           *viewModel;
@property (nonatomic, weak    ) IBOutlet UITextField         *textFieldUsername;
@property (nonatomic, weak    ) IBOutlet UITextField         *textFieldFullName;
@property (nonatomic, weak    ) IBOutlet UITextField         *textFieldEmail;
@property (nonatomic, weak    ) IBOutlet UIButton            *buttonSubmit;

@end

@implementation ASProfileViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    self->_viewModel = [[ASProfileViewModel alloc] init];
    
    self.textFieldUsername.text      = self.viewModel.username;
    RAC(self.viewModel, username)    = self.textFieldUsername.rac_textSignal;
    
    self.textFieldFullName.text   = self.viewModel.fullName;
    RAC(self.viewModel, fullName) = self.textFieldFullName.rac_textSignal;
    
    self.textFieldEmail.text   = self.viewModel.email;
    RAC(self.viewModel, email) = self.textFieldEmail.rac_textSignal;
    
    self.buttonSubmit.rac_command = self.viewModel.submit;

    [self rac_liftSelector:@selector(onError:)
               withSignals:self.buttonSubmit.rac_command.errors, nil];

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

-(IBAction)doLogout:(id)sender {
    [self.viewModel logOut];
    self.textFieldUsername.text = nil;
    self.textFieldFullName.text = nil;
    self.textFieldEmail.text = nil;
}

@end
