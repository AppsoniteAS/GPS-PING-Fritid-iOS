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
}

@end
