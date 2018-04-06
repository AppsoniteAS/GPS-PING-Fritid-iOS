//
//  ASSignInViewController.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASSignInViewController.h"
#import "ASSignInViewModel.h"
#import "AGApiController.h"
#import "ASButton.h"
@interface ASSignInViewController ()
@property (nonatomic, readonly) ASSignInViewModel     *viewModel;
@property (nonatomic, weak    ) IBOutlet UITextField  *textFieldUsername;
@property (nonatomic, weak    ) IBOutlet UITextField  *textFieldPassword;
@property (nonatomic, weak    ) IBOutlet UIButton     *buttonSubmit;
@property (weak, nonatomic) IBOutlet ASButton *btnRestore;
@end

@implementation ASSignInViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
  //  [self registerForKeyboardNotifications];
    
    self->_viewModel = [[ASSignInViewModel alloc] init];
    
    self.textFieldUsername.text   = self.viewModel.username;
    RAC(self.viewModel, username) = self.textFieldUsername.rac_textSignal;
    self.textFieldPassword.text   = self.viewModel.password;
    RAC(self.viewModel, password) = self.textFieldPassword.rac_textSignal;
    self.buttonSubmit.rac_command = self.viewModel.submit;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin) name:kASDidLoginNotification object:nil];
//
//    [self rac_liftSelector:@selector(doSubmit:)
//               withSignals:self.buttonSubmit.rac_command.executionSignals.flatten, nil];
    [self rac_liftSelector:@selector(onError:)
               withSignals:self.buttonSubmit.rac_command.errors, nil];
    
    
    NSString* restore  = NSLocalizedString(@"restore_password", nil);
    [self.btnRestore setTitle:restore forState:UIControlStateNormal];
    [self.btnRestore setTitle:restore forState:UIControlStateSelected];
    [self.btnRestore setTitle:restore forState:UIControlStateHighlighted];
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

-(void)didLogin {
    [self dismissViewControllerAnimated:true completion:nil];
}

-(IBAction)doSubmit:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
