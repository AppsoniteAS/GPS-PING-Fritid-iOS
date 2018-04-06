//
//  ASResoreViewModel.m
//  GpsPing
//
//  Created by Eugene Yakubovich on 06/04/2018.
//  Copyright © 2018 Robin Grønvold. All rights reserved.
//

#import "ASRestoreViewModel.h"


#import "AGApiController.h"
#import "ASTrackerModel.h"

#import <CocoaLumberjack.h>
static DDLogLevel ddLogLevel = DDLogLevelDebug;

@interface ASRestoreViewModel ()
@property (nonatomic, strong) AGApiController   *apiController;
@end



@implementation ASRestoreViewModel
objection_requires(@keypath(ASRestoreViewModel.new, apiController))


- (instancetype)init {
    self = [super init];
    if (self) {
        [[JSObjection defaultInjector] injectDependencies:self];
    }
    return self;
}

-(RACCommand *)restore {
    @weakify(self);

    RACSignal* isCorrect = [RACSignal combineLatest:@[RACObserve(self, email)]
                                             reduce:^id(NSString* email)
                            {
                                return @(email.length > 0);
                            }];
    
    
    return [[RACCommand alloc] initWithEnabled:isCorrect
                                   signalBlock:^RACSignal *(id input){
                                       @strongify(self)
                                       return [self.apiController restorePasswordBy:self.email];
                                   }];
    
}

@end
