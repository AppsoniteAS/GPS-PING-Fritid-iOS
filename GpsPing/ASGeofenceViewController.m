//
//  ASGeofenceViewController.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASGeofenceViewController.h"
#import "ASGeofenceViewModel.h"

@interface ASGeofenceViewController ()
@property (nonatomic, readonly) ASGeofenceViewModel   *viewModel;
@property (nonatomic, weak    ) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak    ) IBOutlet UITextField  *textFieldYards;
@property (nonatomic, weak    ) IBOutlet UITextField  *textFieldPhoneNumber;
@property (nonatomic, weak    ) IBOutlet UIButton     *buttonSubmit;
@end

@implementation ASGeofenceViewController {
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
    
    self->_viewModel = [[ASGeofenceViewModel alloc] init];
    
    self.textFieldYards.text      = self.viewModel.yards;
    RAC(self.viewModel, yards)    = self.textFieldYards.rac_textSignal;
    self.textFieldPhoneNumber.text   = self.viewModel.phoneNumber;
    RAC(self.viewModel, phoneNumber) = self.textFieldPhoneNumber.rac_textSignal;
    self.buttonSubmit.rac_command = self.viewModel.submit;
    
    [self rac_liftSelector:@selector(doSubmit:)
               withSignals:self.buttonSubmit.rac_command.executionSignals.flatten, nil];
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

-(IBAction)doSubmit:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
