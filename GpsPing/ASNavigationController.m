//
//  ASNavigationController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 19/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASNavigationController.h"
#import "UIColor+ASColor.h"
#import "AGApiController.h"
#import "UIStoryboard+ASHelper.h"

#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@interface ASNavigationController()

@property (nonatomic, strong) AGApiController   *apiController;
@property (nonatomic, assign) BOOL isFirstLaunch;

@end

@implementation ASNavigationController

objection_requires(@keypath(ASNavigationController.new, apiController))

-(void)viewDidLoad
{
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
    self.isFirstLaunch = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout) name:kASDidLogoutNotification object:nil];
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

-(void)presentLogInControllerAnimated:(BOOL)animated {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
     [self popToRootViewControllerAnimated:NO];
    UIViewController* controller = [[UIStoryboard authStoryboard] instantiateInitialViewController];
    [self presentViewController:controller
                       animated:animated
                     completion:^{

                     }];
}

@end
