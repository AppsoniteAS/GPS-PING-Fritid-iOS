//
//  ViewController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 18/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "MainMenuViewController.h"
#import "ASSelectTrackerViewController.h"
#import "ASSmsManager.h"
#import "ASMainViewModel.h"
#import "ASMapViewController.h"
#import "AGApiController.h"
#import <FCOverlay/FCOverlay.h>
#import "UIStoryboard+ASHelper.h"
#import "ASSmsManager.h"

#import <CocoaLumberjack.h>
static DDLogLevel ddLogLevel = DDLogLevelDebug;

@interface MainMenuViewController() <ASSelectTrackerProtocol>

@property (nonatomic, readonly) ASMainViewModel     *viewModel;
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
@property (nonatomic, strong) AGApiController   *apiController;
@property (weak, nonatomic) IBOutlet UILabel *activeTrackerLabel;

@end

@implementation MainMenuViewController

objection_requires(@keypath(MainMenuViewController.new, apiController))

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];

    self->_viewModel = [[ASMainViewModel alloc] init];
    
    self.startStopButton.layer.borderColor = [UIColor colorWithRed:0.4796 green:0.7302 blue:0.2274 alpha:1.0].CGColor;
    self.startStopButton.layer.borderWidth = 6.0;
    
    [self handleExistedTracker];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    [self updateButton];
    self.startStopButton.layer.cornerRadius = self.startStopButton.frame.size.width/2;
    ASTrackerModel *activeTracker = [ASTrackerModel getChoosedTracker];
    self.activeTrackerLabel.text = activeTracker.trackerName;
}



- (IBAction)startStopButtonTap:(id)sender {
    ASTrackerModel *trackerModel = [ASTrackerModel getChoosedTracker];
    
    if (!trackerModel) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No tracker choosed", nil)
                                    message:NSLocalizedString(@"You must choose tracker on Trackers screen in Settings to start it", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles: nil] show];
        return;
    }

    [[self as_sendSMS:[trackerModel getSmsTextsForTrackerLaunch:!trackerModel.isRunning]
           ToRecipient:trackerModel.trackerPhoneNumber] subscribeNext:^(id x) {
        [self updateCurrentTracker];
    } error:^(NSError *error) {
        ;
    }];
}

-(void)selectTracker:(ASSelectTrackerViewController *)controller trackerChoosed:(ASTrackerModel *)trackerModel
{
    [[self as_sendSMS:[trackerModel getSmsTextsForTrackerLaunch:YES]
           ToRecipient:trackerModel.trackerPhoneNumber] subscribeNext:^(id x) {
        [self updateCurrentTracker];
    } error:^(NSError *error) {
        ;
    }];
}

-(void)updateCurrentTracker
{
    ASTrackerModel *trackerModel = [ASTrackerModel getChoosedTracker];
    trackerModel.isRunning = !trackerModel.isRunning;
    [trackerModel saveInUserDefaults];
    [self updateButton];
}

- (IBAction)mapTap:(id)sender {
    ASMapViewController *mapVC = [ASMapViewController initialize];
    mapVC.isHistoryMode = NO;
    [self.navigationController pushViewController:mapVC animated:YES];
}

- (IBAction)historyTap:(id)sender {
    ASMapViewController *mapVC = [ASMapViewController initialize];
    mapVC.isHistoryMode = YES;
    [self.navigationController pushViewController:mapVC animated:YES];
}

-(void)updateButton {
    ASTrackerModel *trackerModel = [ASTrackerModel getChoosedTracker];
    if (trackerModel.isRunning) {
        [self.startStopButton setTitle:NSLocalizedString(@"STOP", nil) forState:UIControlStateNormal];
    } else {
        [self.startStopButton setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    }
}

- (IBAction)helpTap:(id)sender {
    [FCOverlay presentOverlayWithViewController:[UIStoryboard introStoryboard].instantiateInitialViewController animated:YES completion:nil];
}

-(BOOL)prefersStatusBarHidden {
    return NO;
}

- (void) handleExistedTracker{
    
    
    [[self.apiController getTrackers] subscribeNext:^(NSArray* trackers) {
        for (ASTrackerModel* tracker in trackers) {
            int smsNumber = 0;
            [[tracker getSmsTextsForActivation] subscribeNext:^(NSArray* list) {
                
                RACSignal *signal = [RACSignal empty];
                for (NSString* text in list) {
                    signal = [signal then:^{
                        return [self as_sendSMS:text ToRecipient:tracker.trackerPhoneNumber];
                    }];
                }
                
                
//                RACSignal *signal = [RACSignal concat:[list.rac_sequence map:^(NSString* text) {
//                    return [self as_sendSMS:text ToRecipient:tracker.trackerPhoneNumber];
//                }]];
//                
                [signal subscribeCompleted:^{
                    DDLogDebug(@"completed");
                }];
            }];
        }
    }];
    
    
//    [[[self.apiController getTrackers] flattenMap:^id(NSArray *trackers)  {
//        NSMutableArray* result = [NSMutableArray array];
//        for (ASTrackerModel* tracker in trackers) {
//            [result addObject:[tracker getSmsTextsForActivation]];
//        }
//        return [RACSignal zip:result reduce:;
//    }] subscribeNext:^(NSArray* listOfSMSList) {
//        
//        
//        NSMutableArray* arr = [NSMutableArray array];
//        for (NSArray* a in listOfSMSList) {
//            [arr addObjectsFromArray:a];
//        }
//        
//        
//        
//        RACSignal *signal = [RACSignal concat:[arr.rac_sequence map:^(NSString* text) {
//            return self as_sendSMS:text ToRecipient:<#(NSString *)#>;
//        }]];
//        
//        DDLogDebug(@"%@", x);
//    }];
//    


}

@end
