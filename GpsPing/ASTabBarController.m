//
//  ASTabBarController.m
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/2/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import "ASTabBarController.h"
#import "UIColor+ASColor.h"
#import "AGApiController.h"
#import "UIStoryboard+ASHelper.h"
#import "ASNewTrackerViewController.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <FCOverlay/FCOverlay.h>
#import "ASTrackerModel.h"
#import "ASMapViewController.h"
#import "ASTrackersViewController.h"

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@interface ASTabBarController()
@property (nonatomic, strong) AGApiController   *apiController;
@property (nonatomic, assign) BOOL isFirstLaunch;
@end

@implementation ASTabBarController

objection_requires(@keypath(ASTabBarController.new, apiController))

-(void)viewDidLoad
{
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
    self.isFirstLaunch = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin) name:kASDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout) name:kASDidLogoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegister) name:kASDidRegisterNotification object:nil];
    
    
    ASMapViewController* map = [[UIStoryboard mapStoryboard] instantiateInitialViewController];
    map.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"Map"
                                  image:[UIImage imageNamed:@"tabbar_maps"]
                                    tag:1];
    
    
    ASTrackersViewController* tracker =[[UIStoryboard trackerStoryboard] instantiateInitialViewController];
    tracker.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"Trackers"
                                  image:[UIImage imageNamed:@"tabbar_trackers"]
                                    tag:2];
    
    ASTrackersViewController* settings =[[UIStoryboard settingsStoryboard] instantiateInitialViewController];
    settings.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"Settings"
                                  image:[UIImage imageNamed:@"tabbar_settings"]
                                    tag:3];
    
    
    [self setViewControllers:@[map, tracker, settings]];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (!self.isFirstLaunch) return;
    self.isFirstLaunch = NO;
    if (self.apiController.userProfile == nil) {
        DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
        [self presentLogInControllerAnimated:NO];
    } else {
        [[self.apiController registerForPushes] subscribeNext:^(id x) {
            ;
        }];
    }
}

-(void)presentIntro {
    NSNumber *didShowIntro = [[NSUserDefaults standardUserDefaults] objectForKey:kASUserDefaultsDidShowIntro];
    if (!didShowIntro.boolValue) {
        [FCOverlay presentOverlayWithViewController:[UIStoryboard introStoryboard].instantiateInitialViewController animated:YES completion:nil];
    }
}

-(void)didLogin {
    [self presentIntro];
    
    
    [[self.apiController getTrackers]  subscribeNext:^(NSArray* value) {
        DDLogInfo(@"-->2");
        DDLogDebug(@"%@", value);
        for (ASTrackerModel *tracker in value) {
            [tracker saveInUserDefaults];
        }
    } ];
    
    
}

-(void)didLogout {
    
    if (self.presentedViewController) {
        DDLogVerbose(@"%s with dismiss", __PRETTY_FUNCTION__);
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [self presentLogInControllerAnimated:YES];
        }];
    } else {
        DDLogVerbose(@"%s without dismiss", __PRETTY_FUNCTION__);
        [self presentLogInControllerAnimated:YES];
    }
}

-(void)didRegister {
    [self presentIntro];
    if (self.presentedViewController) {
        DDLogVerbose(@"%s with dismiss", __PRETTY_FUNCTION__);
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [self presentAddTrackerViewController];
        }];
    } else {
        DDLogVerbose(@"%s without dismiss", __PRETTY_FUNCTION__);
        [self presentAddTrackerViewController];
    }
}

-(void)presentLogInControllerAnimated:(BOOL)animated {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
   // [self popToRootViewControllerAnimated:NO];
    UIViewController* controller = [[UIStoryboard authStoryboard] instantiateInitialViewController];
    [self presentViewController:controller
                       animated:animated
                     completion:^{
                         
                     }];
}

-(void)presentAddTrackerViewController {
    UIViewController* controller = [[UIStoryboard trackerStoryboard] instantiateViewControllerWithIdentifier:NSStringFromClass([ASNewTrackerViewController  class])];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
