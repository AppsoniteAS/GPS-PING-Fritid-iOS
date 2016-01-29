//
//  ASPointModel.m
//  GpsPing
//
//  Created by Pavel Ivanov on 28/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASPointModel.h"
#import <extobjc.h>
#import <CocoaLumberjack.h>
static DDLogLevel ddLogLevel               = DDLogLevelDebug;

NSString* const kASPointLat          = @"lat";
NSString* const kASPointLon          = @"lon";
NSString* const kASPointTimestamp    = @"timestamp";
NSString* const kASPointCreationTime = @"creationTime";

@implementation ASPointModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@keypath(ASPointModel.new, latitude)     : kASPointLat,
             @keypath(ASPointModel.new, longitude)    : kASPointLon,
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

@end
