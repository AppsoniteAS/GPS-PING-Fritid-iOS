//
//  ASProfileViewModel.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/21/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASProfileViewModel.h"
#import "AGApiController.h"

@interface ASProfileViewModel()
@property (nonatomic, strong) AGApiController   *apiController;
@end

@implementation ASProfileViewModel
objection_requires(@keypath(ASProfileViewModel.new, apiController))

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [[JSObjection defaultInjector] injectDependencies:self];
    @weakify(self);
    [[RACObserve(self, apiController.userProfile) distinctUntilChanged] subscribeNext:^(ASUserProfileModel* profile) {
        @strongify(self);
        self.username = self.apiController.userProfile.username;
        if (self.apiController.userProfile.firstname != nil && self.apiController.userProfile.lastname != nil) {
            self.fullName = [NSString stringWithFormat:@"%@ %@",self.apiController.userProfile.firstname, self.apiController.userProfile.lastname];
        }
        self.email = self.apiController.userProfile.email;
    }];
}

- (RACCommand *)submit {
    
    RACSignal* isCorrect = [RACSignal combineLatest:@[RACObserve(self, username),
                                                      RACObserve(self, fullName),
                                                      RACObserve(self, email)]
                                             reduce:^id(NSString* username, NSString* fullName, NSString* email)
                            {
                                return @((username.length > 0) && (fullName.length > 0) && (email.length > 0));
                            }];
    
    return [[RACCommand alloc] initWithEnabled:isCorrect
                                   signalBlock:^RACSignal *(id input)
            {
                return [RACSignal empty];
            }];
}

- (void)logOut {
    [[self.apiController logout] replay];
    self.username = nil;
    self.fullName = nil;
    self.email = nil;

}

@end
