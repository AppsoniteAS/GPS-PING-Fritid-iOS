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
#import <BEMCheckBox.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;



@interface ASNewTrackerViewController ()<BEMCheckBoxDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *helpHeight; // 68
@property (weak, nonatomic) IBOutlet UIButton *btnBasicTracker;

@property (weak, nonatomic) IBOutlet UIView      *outerWrapperView;
@property (weak, nonatomic) IBOutlet UITextField *imeiTextField;
@property (weak, nonatomic) IBOutlet UITextField *trackerNumberTextField;

@property (nonatomic) NSArray *smsesForActivation;
@property (nonatomic) ASTrackerModel *trackerObject;
@property (nonatomic, assign) NSInteger smsCount;
@property (nonatomic, strong) AGApiController   *apiController;
- (IBAction)helpTap:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *labelAddingATracker;
@property (weak, nonatomic) IBOutlet UILabel *labelIhaveRead;
@property (weak, nonatomic) IBOutlet BEMCheckBox *checkBox;
@property (strong, nonatomic) RACSubject* checkboxSignal;

@property (weak, nonatomic) IBOutlet UILabel *labelTracker;
@property (weak, nonatomic) IBOutlet UILabel *labelIMEI;
@property (weak, nonatomic) IBOutlet UILabel *labelTrackerNUmber;
@property (weak, nonatomic) IBOutlet UILabel *labelAdding;
@property (weak, nonatomic) IBOutlet UILabel *labelIHaveRead;
@property (weak, nonatomic) IBOutlet ASButton    *completeButton;


@end

@implementation ASNewTrackerViewController

objection_requires(@keypath(ASNewTrackerViewController.new, apiController))

- (void)viewDidLoad {
    [super viewDidLoad];
    self.checkboxSignal = [RACSubject new];
    [[JSObjection defaultInjector] injectDependencies:self];
    [self jps_viewDidLoad];
    self.smsCount = 0;
    RACSignal *inputFieldsSignal = [RACSignal combineLatest:@[self.imeiTextField.rac_textSignal, self.trackerNumberTextField.rac_textSignal, self.checkboxSignal]
                                                     reduce:^id (NSString *imei, NSString *number, NSNumber* checked){
        return @(imei && imei.length && number && number.length == 4 && checked && [checked boolValue]);
    }];
    
    RAC(self.completeButton, enabled) = inputFieldsSignal;
    self.checkBox.delegate = self;
    self.completeButton.enabled = self.checkBox.on;
    self.checkBox.animationDuration = 0.4;
    self.checkBox.lineWidth = 1.5;
    self.labelAddingATracker.text = NSLocalizedString(@"adding_a_tracker", nil);
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"I_have_read", nil)];
    [attributeString addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInt:1]
                            range:(NSRange){0,[attributeString length]}];
    self.labelIhaveRead.attributedText = attributeString;

    
    self.helpHeight.constant = 68;
    
    [self localizeAll];
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
    [self.view layoutIfNeeded];

    if (self.helpHeight.constant < 100){
        [UIView animateWithDuration:0.4 animations:^{
            self.helpHeight.constant = 200;
            [self.view layoutIfNeeded];
        }];
    } else {
        [UIView animateWithDuration:0.4 animations:^{
            self.helpHeight.constant = 68;
            [self.view layoutIfNeeded];
        }];
    }

}
- (IBAction)presedBtnTerms:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:@"https://fritid.gpsping.no/subscription_agreement/"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (IBAction)pressedBtnBasicTracker:(UIButton *)sender {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HelpPopup" bundle:[NSBundle mainBundle]];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"HelpPopup"];
        viewController.transitioningDelegate = self.transitioningDelegate;
        [FCOverlay presentOverlayWithViewController:viewController windowLevel:UIWindowLevelNormal animated:YES completion:nil];
}

- (IBAction)pressedBtnMarcelTracker:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HelpPopup" bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"HelpPopupMarcel"];
    viewController.transitioningDelegate = self.transitioningDelegate;
    [FCOverlay presentOverlayWithViewController:viewController windowLevel:UIWindowLevelNormal animated:YES completion:nil];
}

//MARK: - Checkbox delegate

- (void)didTapCheckBox:(BEMCheckBox *)checkBox{
    [self.checkboxSignal sendNext:@(checkBox.on)];
}


- (void) localizeAll{
 
    NSString* addTracker = NSLocalizedString(@"trackers_add_tracker", nil);
 
    [_completeButton setTitle:addTracker forState:UIControlStateNormal];
    [_completeButton setTitle:addTracker forState:UIControlStateSelected];
    [_completeButton setTitle:addTracker forState:UIControlStateHighlighted];
    self.title =  NSLocalizedString(addTracker, nil);
    //self.labelTracker.text = NSLocalizedString(@"profile_title", nil);
    self.labelIMEI.text = NSLocalizedString(@"trackers_imei", nil);
    self.labelTrackerNUmber.text = NSLocalizedString(@"trackers_number", nil);
}

@end
