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
NSString* const kASPointAttributes = @"attributes";


@implementation ASPointModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@keypath(ASPointModel.new, latitude)     : kASPointLat,
             @keypath(ASPointModel.new, longitude)    : kASPointLon,
              @keypath(ASPointModel.new, heading)     : kASPointHeading,
              @keypath(ASPointModel.new, speed)    : kASPointSpeedKPH,
              @keypath(ASPointModel.new, attributes)    : kASPointAttributes,

             @keypath(ASPointModel.new, timestamp)    : kASPointTimestamp,
             @keypath(ASPointModel.new, creationTime) : kASPointCreationTime};
}

+ (NSValueTransformer *)timestampJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *timestamp, BOOL *success, NSError *__autoreleasing *error) {
        return [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue];
    }];
}

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
