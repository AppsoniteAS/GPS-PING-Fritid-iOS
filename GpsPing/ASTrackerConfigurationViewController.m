//
//  ASTrackerConfigurationViewController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 20/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASTrackerConfigurationViewController.h"
#import "UIStoryboard+ASHelper.h"

@implementation ASTrackerConfigurationViewController

+(instancetype)initialize
{
    return [[UIStoryboard trackerStoryboard] instantiateViewControllerWithIdentifier:NSStringFromClass([ASTrackerConfigurationViewController class])];
}

-(void)viewDidLoad
{
    self.navigationItem.title = self.trackerObject.trackerType;
}

@end
