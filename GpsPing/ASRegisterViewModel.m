//
//  ASRegisterViewModel.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASRegisterViewModel.h"

@implementation ASRegisterViewModel

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
                                   signalBlock:^RACSignal *(id input)
            {
                @strongify(self);
                return [RACSignal empty];
            }];
}

@end
