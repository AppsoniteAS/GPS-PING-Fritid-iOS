//
//  ASNewTrackerViewController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 14/07/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASNewTrackerViewController.h"
#import "UIStoryboard+ASHelper.h"
#import <JPSKeyboardLayoutGuideViewController.h>
#import "Masonry.h"
#import "ASButton.h"
#import "ASSmsManager.h"
#import "AGApiController.h"
#import "UIColor+ASColor.h"
#import "ReactiveCocoa.h"

#import <CocoaLumberjack/CocoaLumberjack.h>
#import <FCOverlay/FCOverlay.h>

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@interface ASNewTrackerViewController ()

@property (weak, nonatomic) IBOutlet UIView      *outerWrapperView;
@property (weak, nonatomic) IBOutlet UITextField *imeiTextField;
@property (weak, nonatomic) IBOutlet UITextField *trackerNumberTextField;
@property (weak, nonatomic) IBOutlet ASButton    *completeButton;

@property (nonatomic) NSArray *smsesForActivation;
@property (nonatomic) ASTrackerModel *trackerObject;
@property (nonatomic, assign) NSInteger smsCount;
@property (nonatomic, strong) AGApiController   *apiController;
- (IBAction)helpTap:(id)sender;

@end

@implementation ASNewTrackerViewController

objection_requires(@keypath(ASNewTrackerViewController.new, apiController))

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
    [self jps_viewDidLoad];
    self.smsCount = 0;
    RACSignal *inputFieldsSignal = [RACSignal combineLatest:@[self.imeiTextField.rac_textSignal, self.trackerNumberTextField.rac_textSignal]
                                                     reduce:^id (NSString *imei, NSString *number){
        return @(imei && imei.length && number && number.length == 4);
    }];
    
    RAC(self.completeButton, enabled) = inputFieldsSignal;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self jps_viewWillAppear:animated];
//    [self.outerWrapperView mas_makeConstraints:^
//     (MASConstraintMaker *make) {
//         make.bottom.equalTo(self.keyboardLayoutGuide);
//     }];
}



-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self jps_viewDidDisappear:animated];
}


- (IBAction)addTrackerTap:(id)sender {
    [self.imeiTextField resignFirstResponder];
    [self.trackerNumberTextField resignFirstResponder];
    if (self.smsCount > 0) {
        [self sendSmses];
    } else {
        [self updateTrackerObject];
        [self bindTrackerOnServer];
    }
}

- (IBAction)cancelButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

-(void)updateTrackerObject {
    self.trackerObject =  [ASTrackerModel initTrackerWithName:nil
                                                       number:self.trackerNumberTextField.text
                                                         imei:self.imeiTextField.text
                                                         type:self.trackerName
                                                    isChoosed:NO
                                                    isRunning:NO];
}

-(void)bindTrackerOnServer {
    [[[self.apiController bindTrackerImei:self.trackerObject.imeiNumber
                                   number:self.trackerObject.trackerNumber
                                     /*type: self.trackerObject.trackerType*/] flattenMap:^RACStream *(id value) {
        DDLogDebug(@"Tracker Added! Acquiring tracker list...");
        return [self.apiController getTrackers];
    }] subscribeNext:^(NSArray *trackers) {
        DDLogVerbose(@"Saving new tracker localy...");
        for (ASTrackerModel *tracker in trackers) {
            if ([tracker.imeiNumber isEqualToString:self.trackerObject.imeiNumber]) {
                [tracker saveInUserDefaults];
                self.trackerObject = tracker;
                DDLogVerbose(@"Done");
                break;
            }
        }
        
        [self sendSmses];
    } error:^(NSError *error) {
        if ([NSLocalizedStringFromTable(error.localizedDescription, @"Errors", nil) isEqualToString:@"Invalid authentication cookie. Use the `generate_auth_cookie` method."]) {
            UIViewController* controller = [[UIStoryboard authStoryboard] instantiateInitialViewController];
            [self presentViewController:controller
                               animated:YES
                             completion:nil];
        }
        [[UIAlertView alertWithTitle:NSLocalizedString(@"Error", nil) error:error] show];
    }];
}

#pragma mark - SMS stuff

-(void)sendSmses {
    if (!self.smsesForActivation) {
        [[self.trackerObject getSmsTextsForActivation] subscribeNext:^(id x) {
            self.smsesForActivation = x;
            [self checkSmsCount];
        } error:^(NSError *error) {
            [[UIAlertView alertWithTitle:NSLocalizedString(@"Error", nil) error:error] show];
        }];
    } else {
        [self checkSmsCount];
    }
}

-(void)checkSmsCount{
    if (self.smsCount == self.smsesForActivation.count) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [[self as_sendSMS:self.smsesForActivation[self.smsCount]
              ToRecipient:self.trackerObject.trackerPhoneNumber] subscribeNext:^(id x) {
            self.smsCount++;
            [self.completeButton setTitle:[self newTitleForActivation:self.smsCount]
                                 forState:UIControlStateNormal];
        } error:^(NSError *error) {
            ;
        }];
    }
}

-(NSString *)newTitleForActivation:(NSInteger)smsCount {
    NSString *newTitle;
    if (smsCount == self.smsesForActivation.count) {
        newTitle = NSLocalizedString(@"Finish activation", nil);
    } else {
        newTitle = [NSString stringWithFormat:NSLocalizedString(@"Activation: step %ld", nil), (long)self.smsCount + 1];
    }
    
    return newTitle;
}

- (IBAction)helpTap:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HelpPopup" bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"HelpPopup"];
    viewController.transitioningDelegate = self.transitioningDelegate;
    [FCOverlay presentOverlayWithViewController:viewController windowLevel:UIWindowLevelNormal animated:YES completion:nil];
}
@end
