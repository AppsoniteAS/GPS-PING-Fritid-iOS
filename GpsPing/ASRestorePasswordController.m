//
//  ASRestorePasswordController.m
//  GpsPing
//
//  Created by Eugene Yakubovich on 06/04/2018.
//  Copyright © 2018 Robin Grønvold. All rights reserved.
//

#import "ASRestorePasswordController.h"
#import "ASButton.h"
#import "ASRestoreViewModel.h"

@interface ASRestorePasswordController ()
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;

@property (weak, nonatomic) IBOutlet ASButton *btnRestore;

@property (nonatomic, readonly) ASRestoreViewModel     *viewModel;

@end

@implementation ASRestorePasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    
    self->_viewModel = [[ASRestoreViewModel alloc] init];
    
    self.textFieldEmail.text   = self.viewModel.email;
    RAC(self.viewModel, email) = self.textFieldEmail.rac_textSignal;
    self.btnRestore.rac_command = self.viewModel.restore;

    [self rac_liftSelector:@selector(doSubmit:)
               withSignals:self.btnRestore.rac_command.executionSignals.flatten, nil];

    
    [self rac_liftSelector:@selector(onError:)
               withSignals:self.btnRestore.rac_command.errors, nil];
    
    self.labelEmail.text = NSLocalizedString(@"profile_email", nil);
    NSString* restore  = NSLocalizedString(@"Restore", nil);
    self.title = restore;
    [self.btnRestore setTitle:restore forState:UIControlStateNormal];
    [self.btnRestore setTitle:restore forState:UIControlStateSelected];
    [self.btnRestore setTitle:restore forState:UIControlStateHighlighted];
    self.labelTitle.text = NSLocalizedString(@"retore_password", nil);
}

-(void)onError:(NSError*)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                    message:NSLocalizedStringFromTable(error.localizedDescription, @"Errors", nil)
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void) doSubmit:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:NSLocalizedString(@"restore_success", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self.navigationController popViewControllerAnimated:true];
                               }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:true];
}


@end
