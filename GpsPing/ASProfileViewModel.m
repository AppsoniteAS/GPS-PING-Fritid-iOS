//
//  ASProfileViewModel.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/21/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASProfileViewModel.h"
#import "AGApiController.h"

#import <CocoaLumberjack.h>
static DDLogLevel ddLogLevel = DDLogLevelDebug;

@interface ASProfileViewModel()
@property (nonatomic, strong) AGApiController   *apiController;
@property (strong, nonatomic) NSString* lastname;
@property (strong, nonatomic) NSString* firstname;
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
        self.phone = self.apiController.userProfile.phone;
    }];
}

- (RACCommand *)submit {
    
    RACSignal* isCorrect = [RACSignal combineLatest:@[RACObserve(self, username),
                                                      RACObserve(self, fullName),
                                                      RACObserve(self, email),
                                                      RACObserve(self, phone)]
                                             reduce:^id(NSString* username, NSString* fullName, NSString* email, NSString *phone)
                            {
                                return @((username.length > 0) && (fullName.length > 0) && (email.length > 0) && (phone.length == 8));
                            }];
    @weakify(self)
    return [[RACCommand alloc] initWithEnabled:isCorrect
                                   signalBlock:^RACSignal *(id input)
            {
                @strongify(self)
                ASUserProfileModel* profile = self.apiController.userProfile.copy ?: [ASUserProfileModel new];
                NSArray *subStrings = [self.fullName componentsSeparatedByString:@" "];
                profile.firstname    = subStrings[0];
                profile.lastname   = [subStrings lastObject];
                profile.phone = self.phone;
                [ASUserProfileModel saveProfileInfoLocally:profile];
                self.apiController.userProfile = profile;
                return [self.apiController submitUserMetaData:profile];
            }];
}

- (void)logOut {
    [[self.apiController logout] replay];
    self.username = nil;
    self.fullName = nil;
    self.email = nil;

}

@end
