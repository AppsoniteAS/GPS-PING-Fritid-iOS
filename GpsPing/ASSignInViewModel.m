//
//  ASSignInViewModel.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASSignInViewModel.h"

@implementation ASSignInViewModel

-(RACSignal *)signalSubmit
{
    return [RACSignal combineLatest:@[RACObserve(self, password),
                                      RACObserve(self, username)]
                             reduce:^id(NSString* username, NSString* password)
            {
                return @((username.length > 0) && (password.length > 0));
            }];
}

-(RACCommand *)submit {
    
    RACSignal* isCorrect = [RACSignal combineLatest:@[RACObserve(self, password),
                                                      RACObserve(self, username)]
                                             reduce:^id(NSString* username, NSString* password)
                            {
                                return @((username.length > 0) && (password.length > 0));
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
