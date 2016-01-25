//
//  ASMainViewModel.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/24/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASMainViewModel.h"

@implementation ASMainViewModel
objection_requires(@keypath(ASMainViewModel.new, apiController))

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [[JSObjection defaultInjector] injectDependencies:self];
    self.apiController.userProfile = [ASUserProfileModel loadSavedProfileInfo];
}

@end