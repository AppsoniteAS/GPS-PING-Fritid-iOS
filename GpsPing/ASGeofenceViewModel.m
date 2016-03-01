//
//  ASGeofenceViewModel.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASGeofenceViewModel.h"
#import "ASTrackerModel.h"

@implementation ASGeofenceViewModel

-(RACCommand *)submit {
    
    RACSignal* isCorrect = [RACSignal combineLatest:@[RACObserve(self, yards)]
                                             reduce:^id(NSString* yards)
                            {
                                return @((yards.length > 0) && [ASTrackerModel getChoosedTracker]);
                            }];
    
    return [[RACCommand alloc] initWithEnabled:isCorrect
                                   signalBlock:^RACSignal *(id input)
            {
                return [RACSignal return:nil];
            }];
}
@end
