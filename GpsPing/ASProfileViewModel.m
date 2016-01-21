//
//  ASProfileViewModel.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/21/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASProfileViewModel.h"

@implementation ASProfileViewModel

-(RACCommand *)submit {
    
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

@end
