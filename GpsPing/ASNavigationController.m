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

@end

@implementation ASNavigationController

objection_requires(@keypath(ASNavigationController.new, apiController))

-(void)viewDidLoad
{
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout) name:kASDidLogoutNotification object:nil];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (self.apiController.userProfile == nil) {
        [self presentLogInControllerAnimated:NO];
    } else {
        [[self.apiController registerForPushes] subscribeNext:^(id x) {
            ;
        }];
    }
}

-(void)didLogout {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    [self presentLogInControllerAnimated:YES];
}

-(void)dismissModalStack {
    UIViewController *vc = self.presentingViewController;
    while (vc.presentingViewController) {
        vc = vc.presentingViewController;
    }
    [vc dismissViewControllerAnimated:YES completion:NULL];
}

-(void)presentLogInControllerAnimated:(BOOL)animated {
    [self dismissModalStack];
    
    [self popToRootViewControllerAnimated:!animated];
    UIViewController* controller = [[UIStoryboard authStoryboard] instantiateInitialViewController];
    [self presentViewController:controller
                       animated:animated
                     completion:nil];
}

@end
