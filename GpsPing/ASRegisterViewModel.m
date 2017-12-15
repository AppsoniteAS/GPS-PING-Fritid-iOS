//
//  ASRegisterViewModel.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASRegisterViewModel.h"
#import "AGApiController.h"

#import <CocoaLumberjack.h>
static DDLogLevel ddLogLevel = DDLogLevelDebug;

@interface ASRegisterViewModel ()
@property (nonatomic, strong) AGApiController   *apiController;
@end

@implementation ASRegisterViewModel
objection_requires(@keypath(ASRegisterViewModel.new, apiController))

- (instancetype)init {
    self = [super init];
    if (self) {
        [[JSObjection defaultInjector] injectDependencies:self];
    }
    return self;
}


- (RACSignal*) registerSignal{
    @weakify(self);
    
        return [[self.apiController getNonce] flattenMap:^RACStream *(id x) {
            @strongify(self);
            ASNewUserModel *newUser = ASNewUserModel.new;
            newUser.username = self.username;
            newUser.password = self.password;
            newUser.email = self.email;
            newUser.phoneCode = self.phoneCode;
            newUser.phoneNumber = self.phoneNumber;
            newUser.fullName = self.fullName;
            newUser.nonce = x[@"nonce"];
            newUser.displayName = self.username;
            newUser.address = self.address;
            newUser.city = self.city;
            newUser.country = self.country;
            newUser.zipCode = self.zipCode;
            return [[self.apiController registerUser:newUser] flattenMap:^RACStream *(id x) {
                DDLogDebug(@"register result %@", x);
                @strongify(self);
                return [[self.apiController authUser:self.username password:self.password] doNext:^(id x) {
                    DDLogDebug(@"userProfile %@", self.apiController.userProfile);
                    [[NSNotificationCenter defaultCenter] postNotificationName:kASDidRegisterNotification object:nil];
                }];
            }];
        }];
    
}

-(RACCommand *)submit {
    
//    RACSignal* isCorrect = [RACSignal combineLatest:@[RACObserve(self, username),
//                                                      RACObserve(self, fullName),
//                                                      RACObserve(self, password),
//                                                      RACObserve(self, confirmPassword),
//                                                      RACObserve(self, phoneCode),
//                                                      RACObserve(self, phoneNumber),
//                                                      RACObserve(self, address),
//                                                      RACObserve(self, city),
//                                                      RACObserve(self, country),
//                                                      RACObserve(self, zipCode),
//                                                      RACObserve(self, email)]
//                                             reduce:^id(NSString* username,
//                                                        NSString *fullName,
//                                                        NSString* password,
//                                                        NSString* confirmPassword,
//                                                        NSString* phoneCode,
//                                                        NSString* phoneNumber,
//                                                        NSString* address,
//                                                        NSString* city,
//                                                        NSString* country,
//                                                        NSString* zipCode,
//                                                        NSString* email)
//                            {
//                                return @(
//                                (fullName.length > 0) &&
//                                (username.length > 0) &&
//                                (email.length > 0) &&
//                                (phoneCode.length > 0) &&
//                                (phoneNumber.length > 0) &&
//                                (password.length > 0) &&
//                                (address.length > 0) &&
//                                (city.length > 0) &&
//                                (country.length > 0) &&
//                                (zipCode.length > 0)/* &&
//                                ([password isEqualToString:confirmPassword])*/);
//                            }];
    
    @weakify(self);
    
    return [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [[self.apiController getNonce] flattenMap:^RACStream *(id x) {
            @strongify(self);
            ASNewUserModel *newUser = ASNewUserModel.new;
            newUser.username = self.username;
            newUser.password = self.password;
            newUser.email = self.email;
            newUser.phoneCode = self.phoneCode;
            newUser.phoneNumber = self.phoneNumber;
            newUser.fullName = self.fullName;
            newUser.nonce = x[@"nonce"];
            newUser.displayName = self.username;
            newUser.address = self.address;
            newUser.city = self.city;
            newUser.country = self.country;
            newUser.zipCode = self.zipCode;
            return [[self.apiController registerUser:newUser] flattenMap:^RACStream *(id x) {
                DDLogDebug(@"register result %@", x);
                @strongify(self);
                return [[self.apiController authUser:self.username password:self.password] doNext:^(id x) {
                    DDLogDebug(@"userProfile %@", self.apiController.userProfile);
                    [[NSNotificationCenter defaultCenter] postNotificationName:kASDidRegisterNotification object:nil];
                }];
            }];
        }];
    }];
    
//    return [[RACCommand alloc] initWithEnabled:isCorrect
//                                   signalBlock:^RACSignal *(id input) {
//                return [[self.apiController getNonce] flattenMap:^RACStream *(id x) {
//                    @strongify(self);
//                    ASNewUserModel *newUser = ASNewUserModel.new;
//                    newUser.username = self.username;
//                    newUser.password = self.password;
//                    newUser.email = self.email;
//                    newUser.phoneCode = self.phoneCode;
//                    newUser.phoneNumber = self.phoneNumber;
//                    newUser.fullName = self.fullName;
//                    newUser.nonce = x[@"nonce"];
//                    newUser.displayName = self.username;
//                    newUser.address = self.address;
//                    newUser.city = self.city;
//                    newUser.country = self.country;
//                    newUser.zipCode = self.zipCode;
//                    return [[self.apiController registerUser:newUser] flattenMap:^RACStream *(id x) {
//                                    DDLogDebug(@"register result %@", x);
//                                    @strongify(self);
//                                    return [[self.apiController authUser:self.username password:self.password] doNext:^(id x) {
//                                        DDLogDebug(@"userProfile %@", self.apiController.userProfile);
//                                        [[NSNotificationCenter defaultCenter] postNotificationName:kASDidRegisterNotification object:nil];
//                                    }];
//                    }];
//                }];
//            }];
}

@end
