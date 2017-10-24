//
//  ASSignInViewModel.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASSignInViewModel.h"
#import "AGApiController.h"
#import "ASTrackerModel.h"

#import <CocoaLumberjack.h>
static DDLogLevel ddLogLevel = DDLogLevelDebug;

@interface ASSignInViewModel ()
@property (nonatomic, strong) AGApiController   *apiController;
@end

@implementation ASSignInViewModel
objection_requires(@keypath(ASSignInViewModel.new, apiController))

- (instancetype)init {
    self = [super init];
    if (self) {
        [[JSObjection defaultInjector] injectDependencies:self];
    }
    return self;
}

-(RACCommand *)submit {
    
    RACSignal* isCorrect = [RACSignal combineLatest:@[RACObserve(self, password),
                                                      RACObserve(self, username)]
                                             reduce:^id(NSString* username, NSString* password)
                            {
                                return @((username.length > 0) && (password.length > 0));
                            }];
    
    @weakify(self);
    
//    return [[RACCommand alloc] initWithEnabled:isCorrect
//                                   signalBlock:^RACSignal *(id input)
    
    return      [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
   
                return [[self.apiController authUser:self.username password:self.password] then:^RACSignal *{
                    @strongify(self);
                    [[NSNotificationCenter defaultCenter] postNotificationName:kASDidLoginNotification object:nil];
                    return [[self.apiController getTrackers] flattenMap:^RACStream *(NSArray *value) {
                        DDLogDebug(@"%@", value);
                        for (ASTrackerModel *tracker in value) {
                            [tracker saveInUserDefaults];
                        }
                        
                        return [RACSignal return:value];
                    }];
                }];;
            }];
}


@end
