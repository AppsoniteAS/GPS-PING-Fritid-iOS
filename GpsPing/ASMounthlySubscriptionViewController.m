//
//  ASMounthlySubscriptionViewController.m
//  GpsPing
//
//  Created by Andrey Prosekov on 4/23/19.
//  Copyright © 2019 Robin Grønvold. All rights reserved.
//

#import "ASMounthlySubscriptionViewController.h"
#import "ASButton.h"
#import "AGApiController.h"
#import "ASInAppPurchaseManager.h"
#import <FCOverlay/FCOverlay.h>

@interface ASMounthlySubscriptionViewController () <ASInAppPurchaseDelegate>
@property (weak, nonatomic) IBOutlet UILabel *validSubscriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateSubscription;
@property (weak, nonatomic) IBOutlet ASButton *subscriptionButton;
@property (weak, nonatomic) IBOutlet UITextView *subscriptionTextView;
@property(nonatomic, strong) ASInAppPurchaseManager *inAppPurchaseManager;
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyButton;
@property (weak, nonatomic) IBOutlet UIButton *termsAndConditionsButton;
@property (weak, nonatomic) IBOutlet ASButton *restoreSubscriptionButton;
@property (nonatomic, weak)  id <ASInAppPurchaseDelegate> delegate;
@end

@implementation ASMounthlySubscriptionViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO];
    self.inAppPurchaseManager = [ASInAppPurchaseManager new];
    self.inAppPurchaseManager.delegate = self;
    [self.privacyPolicyButton setTitle:NSLocalizedString( @"privacy_policy", nil) forState:UIControlStateNormal];
    [self.termsAndConditionsButton setTitle:NSLocalizedString( @"terms_and_Conditions", nil) forState:UIControlStateNormal];
}
- (void)viewWillAppear:(BOOL)animated {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //load your data here.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUI];
        });
    });
}


- (void)updateUI{
    self.subscriptionTextView.text = NSLocalizedString(@"subscription_text_view", nil);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    
    if([self.inAppPurchaseManager areSubscribed] == TRUE){
        
        
        NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptionExpired"];
        self.dateSubscription.text = [formatter stringFromDate:date];
        [self.subscriptionButton setTitle:NSLocalizedString( @"cancel_subscription", nil) forState:UIControlStateNormal];
        self.restoreSubscriptionButton.hidden = YES;
        self.validSubscriptionLabel.text = NSLocalizedString( @"valid_subscription", nil);
    }else{
        [self.subscriptionButton setTitle:NSLocalizedString( @"Subscribe", nil) forState:UIControlStateNormal];
        [self.restoreSubscriptionButton setTitle:NSLocalizedString(@"Restore", nil) forState:UIControlStateNormal];
        self.dateSubscription.text = @"";
        self.validSubscriptionLabel.text = @"";
    }
    [self.view setNeedsLayout];
    [self.view setNeedsDisplay];
    [self viewWillAppear:true];
}

- (IBAction)onTuchSubscriptionButton:(id)sender {
    
       if([self.inAppPurchaseManager areSubscribed] == TRUE){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions"]];
           [self updateUI];
       }else{
           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               [self.inAppPurchaseManager subscribe];
               dispatch_async(dispatch_get_main_queue(), ^{
                   [self updateUI];
               });
           });
       }
    
    
}
- (IBAction)onTuchRestoreSubscriptionButton:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.inAppPurchaseManager restore];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUI];
        });
    });
    
    
}
- (IBAction)openTermsAndConditions:(id)sender {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://fritid.gpsping.no/subscription_agreement/"]];
}
- (IBAction)openPrivacyPolicy:(id)sender {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://fritid.gpsping.no/privacy-policy/"]];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark ASInAppPurchaseDelegate
-(void)openConnect{
}
@end
