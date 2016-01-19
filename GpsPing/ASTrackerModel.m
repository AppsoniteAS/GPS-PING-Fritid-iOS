//
//  ASTrackerModel.m
//  GpsPing
//
//  Created by Pavel Ivanov on 19/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASTrackerModel.h"

@implementation ASTrackerModel

+(instancetype)initTrackerWithName:(NSString *)name
                            number:(NSString *)number
                              imei:(NSString *)imei
                              type:(NSString *)type
                         isChoosed:(BOOL)isChoosed {
    ASTrackerModel *model = [[ASTrackerModel alloc] init];
    model.trackerName = name;
    model.imeiNumber = imei;
    model.trackerNumber = number;
    model.trackerType = type;
    model.isChoosed = isChoosed;
    return model;
}

@end
