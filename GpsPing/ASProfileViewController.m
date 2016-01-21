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
@property (nonatomic, weak    ) IBOutlet UIScrollView        *scrollView;
@property (nonatomic, weak    ) IBOutlet UITextField         *textFieldUsername;
@property (nonatomic, weak    ) IBOutlet UITextField         *textFieldFullName;
@property (nonatomic, weak    ) IBOutlet UITextField         *textFieldEmail;
@property (nonatomic, weak    ) IBOutlet UIButton            *buttonSubmit;
@end

@implementation ASProfileViewController {
    BOOL keyboardIsShown;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    keyboardIsShown = NO;
    
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

- (void)keyboardWillHide:(NSNotification *)n {
    NSDictionary* userInfo = [n userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height += keyboardSize.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.scrollView setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
}

- (void)keyboardWillShow:(NSNotification *)n {
    
    if (keyboardIsShown) {
        return;
    }
    
    NSDictionary* userInfo = [n userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect viewFrame = self.scrollView.frame;
    
    viewFrame.size.height -= keyboardSize.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.scrollView setFrame:viewFrame];
    [UIView commitAnimations];
    keyboardIsShown = YES;
}

#pragma mark - IBActions

-(IBAction)doLogout:(id)sender {
    
}

@end
