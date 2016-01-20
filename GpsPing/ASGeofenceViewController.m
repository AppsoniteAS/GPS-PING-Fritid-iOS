//
//  ASGeofenceViewController.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASGeofenceViewController.h"
#import "ASGeofenceViewModel.h"
#import <JPSKeyboardLayoutGuideViewController.h>
#import "Masonry.h"

@interface ASGeofenceViewController ()
@property (nonatomic, readonly) ASGeofenceViewModel     *viewModel;
@property (nonatomic, weak    ) IBOutlet UIView       *viewKeyboardInteractive;
@property (nonatomic, weak    ) IBOutlet UITextField  *textFieldYards;
@property (nonatomic, weak    ) IBOutlet UITextField  *textFieldPhoneNumber;
@property (nonatomic, weak    ) IBOutlet UIButton     *buttonSubmit;
@end

@implementation ASGeofenceViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self jps_viewDidLoad];
    [self.viewKeyboardInteractive mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.keyboardLayoutGuide);
    }];
    
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
    [self.navigationController popViewControllerAnimated:YES];
}

@end
