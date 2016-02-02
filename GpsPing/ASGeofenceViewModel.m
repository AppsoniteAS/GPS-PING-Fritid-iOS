//
//  ASGeofenceViewModel.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASGeofenceViewModel.h"


@implementation ASGeofenceViewModel

-(RACCommand *)submit {
    
    RACSignal* isCorrect = [RACSignal combineLatest:@[RACObserve(self, phoneNumber),
                                                      RACObserve(self, yards)]
                                             reduce:^id(NSString* phoneNumber, NSString* yards)
                            {
                                return @((phoneNumber.length > 0) && (yards.length > 0));
                            }];
    
    return [[RACCommand alloc] initWithEnabled:isCorrect
                                   signalBlock:^RACSignal *(id input)
            {
                return [RACSignal return:nil];
            }];
}
@end
