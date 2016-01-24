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

-(RACCommand *)submit {
    
    RACSignal* isCorrect = [RACSignal combineLatest:@[RACObserve(self, username),
                                                      RACObserve(self, password),
                                                      RACObserve(self, confirmPassword),
                                                      RACObserve(self, email)]
                                             reduce:^id(NSString* username, NSString* password, NSString* confirmPassword, NSString* email)
                            {
                                return @((username.length > 0) && (email.length > 0) && (password.length > 0) && ([password isEqualToString:confirmPassword]));
                            }];
    
    @weakify(self);
    return [[RACCommand alloc] initWithEnabled:isCorrect
                                   signalBlock:^RACSignal *(id input) {
                return [[self.apiController getNonce] flattenMap:^RACStream *(id x) {
                    @strongify(self);
                    return [[self.apiController registerUser:self.username
                                                       email:self.email
                                                    password:self.password
                                                       nonce:x[@"nonce"]
                             ] flattenMap:^RACStream *(id x) {
                                    DDLogDebug(@"register result %@", x);
                                    @strongify(self);
                                    return [[self.apiController authUser:self.username password:self.password] doNext:^(id x) {
                                        DDLogDebug(@"userProfile %@", self.apiController.userProfile);
                                    }];
                    }];
                }];
            }];
}


@end
