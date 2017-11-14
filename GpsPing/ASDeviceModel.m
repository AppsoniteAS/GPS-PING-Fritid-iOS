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

static DDLogLevel ddLogLevel           = DDLogLevelDebug;

NSString* const kASDeviceName          = @"device.name";
NSString* const kASDeviceLongitude     = @"device.last_lon";
NSString* const kASDeviceLatitude      = @"device.last_lat";
NSString* const kASDeviceLastDate      = @"device.last_time_stamp";
NSString* const kASDeviceLastUpdate    = @"device.last_update";
NSString* const kASDevicePoints        = @"points";
NSString* const kASDeviceTrackDistance       = @"device.track_distance";

NSString* const kASDeviceTrackerNumber = @"device.tracker_number";
NSString* const kASDeviceImei          = @"device.imei_number";
NSString* const kASDeviceImageId          = @"device.picUrl";
NSString* const kASDeviceHeading = @"device.heading";
NSString* const kASDeviceSpeedKPH = @"device.speedKPH";
NSString* const kASDeviceGPS = @"device.GPS_Signal";

NSString* const kASDeviceGSM = @"device.GSM_Signal";

NSString* const kASDeviceAttributes = @"attributes";


NSString* const kASAttributesBatteryD          = @"device.attributes.battery";
NSString* const kASAttributesPowerD          = @"device.attributes.power";
NSString* const kASAttributesIngnitionD          = @"device.attributes.ignition";

NSString* const kASAttributesIPD         = @"device.attributes.ip";
//NSString* const kASAttributesDistanceD    = @"device.attributes.distance";
//NSString* const kASAttributesTotalDistanceD = @"device.attributes.totalDistance";

NSString* const kASAttributesDistanceD    = @"device.real_dist";
NSString* const kASAttributesTotalDistanceD = @"device.t_distance";

@implementation ASDeviceModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @keypath(ASDeviceModel.new, name) : kASDeviceName,
              @keypath(ASDeviceModel.new, trackDistance) : kASDeviceTrackDistance,

              @keypath(ASDeviceModel.new, longitude) : kASDeviceLongitude,
              @keypath(ASDeviceModel.new, latitude) : kASDeviceLatitude,
              @keypath(ASDeviceModel.new, lastDate) : kASDeviceLastDate,
              @keypath(ASDeviceModel.new, lastUpdate) : kASDeviceLastUpdate,
              @keypath(ASDeviceModel.new, points) : kASDevicePoints,
              @keypath(ASDeviceModel.new, trackerNumber) : kASDeviceTrackerNumber,
              @keypath(ASDeviceModel.new, imei) : kASDeviceImei,
              @keypath(ASDeviceModel.new, imageId) : kASDeviceImageId,
              @keypath(ASDeviceModel.new, gps)     : kASDeviceGPS,
              @keypath(ASDeviceModel.new, gsm)    : kASDeviceGSM,
              @keypath(ASDeviceModel.new, heading)     : kASDeviceHeading,
              @keypath(ASDeviceModel.new, speed)    : kASDeviceSpeedKPH,
            //  @keypath(ASDeviceModel.new, attributes)    : kASDeviceAttributes,
              @keypath(ASDeviceModel.new, power)     : kASAttributesPowerD,

              @keypath(ASDeviceModel.new, battery)     : kASAttributesBatteryD,
              @keypath(ASDeviceModel.new, ipAddress)    : kASAttributesIPD,
              @keypath(ASDeviceModel.new, distance)     : kASAttributesDistanceD,
              @keypath(ASDeviceModel.new, totalDistance)    : kASAttributesTotalDistanceD,
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
