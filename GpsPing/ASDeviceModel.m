//
//  ASDeviceModel.m
//  GpsPing
//
//  Created by Pavel Ivanov on 27/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASDeviceModel.h"
#import <extobjc.h>
#import <CocoaLumberjack.h>
#import "ASPointModel.h"
#import "AGGeoValueTransformer.h"

static DDLogLevel ddLogLevel               = DDLogLevelDebug;

NSString* const kASDeviceName          = @"device.name";
NSString* const kASDeviceLongitude     = @"device.last_lon";
NSString* const kASDeviceLatitude      = @"device.last_lat";
NSString* const kASDeviceLastDate      = @"device.last_time_stamp";
NSString* const kASDeviceLastUpdate    = @"device.last_update";
NSString* const kASDevicePoints        = @"points";
NSString* const kASDeviceTrackerNumber = @"device.tracker_number";
NSString* const kASDeviceImei          = @"device.imei_number";

@implementation ASDeviceModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @keypath(ASDeviceModel.new, name) : kASDeviceName,
              @keypath(ASDeviceModel.new, longitude) : kASDeviceLongitude,
              @keypath(ASDeviceModel.new, latitude) : kASDeviceLatitude,
              @keypath(ASDeviceModel.new, lastDate) : kASDeviceLastDate,
              @keypath(ASDeviceModel.new, lastUpdate) : kASDeviceLastUpdate,
              @keypath(ASDeviceModel.new, points) : kASDevicePoints,
              @keypath(ASDeviceModel.new, trackerNumber) : kASDeviceTrackerNumber,
              @keypath(ASDeviceModel.new, imei) : kASDeviceImei,
              };
}

+ (NSValueTransformer *)lastUpdateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *timestamp, BOOL *success, NSError *__autoreleasing *error) {
        return [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue];
    }];
}

+ (NSValueTransformer *)lastDateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *timestamp, BOOL *success, NSError *__autoreleasing *error) {
        return [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue];
    }];
}

+ (NSValueTransformer *)pointsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[ASPointModel class]];
}

+ (NSValueTransformer *)longitudeJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NSStringFromClass([AGGeoValueTransformer class])];
}

+ (NSValueTransformer *)latitudeJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NSStringFromClass([AGGeoValueTransformer class])];
}

@end
