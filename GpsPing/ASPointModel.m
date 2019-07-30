//
//  ASPointModel.m
//  GpsPing
//
//  Created by Pavel Ivanov on 28/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASPointModel.h"
#import <extobjc.h>
#import "AGGeoValueTransformer.h"

#import <CocoaLumberjack.h>
static DDLogLevel ddLogLevel               = DDLogLevelDebug;

NSString* const kASPointLat          = @"lat";
NSString* const kASPointLon          = @"lon";
NSString* const kASPointTimestamp    = @"timestamp";
NSString* const kASPointCreationTime = @"creationTime";
NSString* const kASPointHeading = @"heading";
NSString* const kASPointSpeedKPH = @"speedKPH";
NSString* const kASPointGPS = @"GPS_Signal";

NSString* const kASPointGSM = @"GSM_Signal";

NSString* const kASPointAttributes = @"attributes";
NSString* const kASAttributesBatteryP          = @"battery";
NSString* const kASAttributesPowerP          = @"attributes.power";
//NSString* const kASAttributesIngnitionP          = @"attributes.ignition";

NSString* const kASAttributesIPP         = @"attributes.ip";
//NSString* const kASAttributesDistanceP    = @"attributes.distance";
//NSString* const kASAttributesTotalDistanceP = @"attributes.totalDistance";

NSString* const kASAttributesDistanceP    = @"real_dist";
NSString* const kASAttributesTotalDistanceP = @"daily_track";//@"t_distance";


@implementation ASPointModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@keypath(ASPointModel.new, latitude)     : kASPointLat,
             @keypath(ASPointModel.new, longitude)    : kASPointLon,
              @keypath(ASPointModel.new, gps)     : kASPointGPS,
              @keypath(ASPointModel.new, gsm)    : kASPointGSM,
              @keypath(ASPointModel.new, heading)     : kASPointHeading,
              @keypath(ASPointModel.new, speed)    : kASPointSpeedKPH,
            //  @keypath(ASPointModel.new, attributes)    : kASPointAttributes,
              @keypath(ASPointModel.new, power)     : kASAttributesPowerP,

              @keypath(ASPointModel.new, battery)     : kASAttributesBatteryP,
              @keypath(ASPointModel.new, ipAddress)    : kASAttributesIPP,
              @keypath(ASPointModel.new, distance)     : kASAttributesDistanceP,
              @keypath(ASPointModel.new, totalDistance)    : kASAttributesTotalDistanceP,
             @keypath(ASPointModel.new, timestamp)    : kASPointTimestamp,
             @keypath(ASPointModel.new, creationTime) : kASPointCreationTime};
}

+ (NSValueTransformer *)timestampJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *timestamp, BOOL *success, NSError *__autoreleasing *error) {
        return [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue];
    }];
}

//+ (NSValueTransformer *)batteryJSONTransformer {
//    return [MTLValueTransformer transformerUsingForwardBlock:^id(id battery, BOOL *success, NSError *__autoreleasing *error) {
//        if ([battery isKindOfClass:[NSString class] ]){
//            return @([battery integerValue]);
//        }
//        return battery;
//    }];
//}

+ (NSValueTransformer *)creationTimeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *timestamp, BOOL *success, NSError *__autoreleasing *error) {
        return [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue];
    }];
}

+ (NSValueTransformer *)longitudeJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NSStringFromClass([AGGeoValueTransformer class])];
}


//+ (NSValueTransformer *)headingJSONTransformer {
//    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
//        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
//        f.numberStyle = NSNumberFormatterDecimalStyle;
//        return [f numberFromString:value];
//    }];
//}
//
+ (NSValueTransformer *)attributesJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSString class]]){
            if ([value isEqualToString:@"<null>"]){
                return [NSNull null];
            }
        }
        return value;
    }];
}

+ (NSValueTransformer *)latitudeJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NSStringFromClass([AGGeoValueTransformer class])];
}

@end
