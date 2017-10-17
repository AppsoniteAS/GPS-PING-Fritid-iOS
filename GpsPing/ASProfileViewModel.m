//
//  ASProfileViewModel.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/21/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASProfileViewModel.h"
#import "AGApiController.h"
#import "NSString+ASNameComponents.h"
#import "ASMapViewController.h"

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
        self.email       = self.apiController.userProfile.email;
        self.phoneCode   = self.apiController.userProfile.phoneCode;
        self.phoneNumber = self.apiController.userProfile.phoneNumber;
        self.address     = self.apiController.userProfile.address;
        self.city        = self.apiController.userProfile.city;
        self.country     = self.apiController.userProfile.country;
        self.zipCode     = self.apiController.userProfile.zipCode;
    }];
}

- (RACCommand *)submit {
    
    RACSignal* isCorrect = [RACSignal combineLatest:@[RACObserve(self, username),
                                                      RACObserve(self, fullName),
                                                      RACObserve(self, phoneCode),
                                                      RACObserve(self, phoneNumber),
                                                      RACObserve(self, address),
                                                      RACObserve(self, city),
                                                      RACObserve(self, country),
                                                      RACObserve(self, zipCode),
                                                      RACObserve(self, email)]
                                             reduce:^id(NSString* username,
                                                        NSString* fullName,
                                                        NSString* phoneCode,
                                                        NSString* phoneNumber,
                                                        NSString* address,
                                                        NSString* city,
                                                        NSString* country,
                                                        NSString* zipCode,
                                                        NSString* email)
                            {
                                return @(
                                (username.length > 0) &&
                                [fullName extractFirstName] &&
                                [fullName extractLastName] &&
                                (phoneCode.length > 0) &&
                                (phoneNumber.length > 0) &&
                                (address.length > 0) &&
                          //      (city.length > 0) &&
                            //    (country.length > 0) &&
                                (zipCode.length > 0) &&
                                (email.length > 0));
                            }];
    @weakify(self)
    return [[RACCommand alloc] initWithEnabled:isCorrect
                                   signalBlock:^RACSignal *(id input)
            {
                ASUserProfileModel* profile = self.apiController.userProfile.copy ?: [ASUserProfileModel new];
                profile.firstname    = [self.fullName extractFirstName];
                profile.lastname   = [self.fullName extractLastName];
                profile.address = self.address;
                profile.phoneCode = self.phoneCode;
                profile.phoneNumber = self.phoneNumber;
                profile.city = self.city;
                profile.zipCode = self.zipCode;
                profile.country = self.country;
                [ASUserProfileModel saveProfileInfoLocally:profile];
                @strongify(self)
                self.apiController.userProfile = profile;
                return [self.apiController submitUserMetaData:profile];
            }];
}

- (void)logOut {
    [[self.apiController logout] replay];
    self.username = nil;
    self.fullName = nil;
    self.email = nil;
    self.phoneCode = nil;
    self.phoneNumber = nil;
    self.address = nil;
    self.city = nil;
    self.country = nil;
    self.zipCode = nil;
    
    
   UITabBarController* target =  (UITabBarController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController] ;
    ASMapViewController* map = [((UINavigationController*)[target childViewControllers][0]) childViewControllers][0];
    [map setNeedRefresh:true];
    //[map refresh];
}

@end
