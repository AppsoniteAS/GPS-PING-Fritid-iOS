//
//  ASPointOfInterestModel.m
//  GpsPing
//
//  Created by Maks Niagolov on 2/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASPointOfInterestModel.h"
#import <extobjc.h>
#import "AGGeoValueTransformer.h"

#import <CocoaLumberjack.h>
static DDLogLevel ddLogLevel               = DDLogLevelDebug;

NSString* const kASPOILat          = @"lat";
NSString* const kASPOILon          = @"lon";
NSString* const kASPOIName         = @"name";
NSString* const kASPOIId           = @"id";
NSString* const kASPOIUserId       = @"user_id";

@implementation ASPointOfInterestModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @keypath(ASPointOfInterestModel.new, identificator)        : kASPOIId,
              @keypath(ASPointOfInterestModel.new, latitude)             : kASPOILat,
              @keypath(ASPointOfInterestModel.new, userId)               : kASPOIUserId,
              @keypath(ASPointOfInterestModel.new, name)                 : kASPOIName,
              @keypath(ASPointOfInterestModel.new, longitude)            : kASPOILon
              };
}

+ (NSValueTransformer *) identificatorJSONTransformer {
    return [self integerTransformer];
}

+ (NSValueTransformer *) userIdJSONTransformer {
    return [self integerTransformer];
}

+ (NSValueTransformer<MTLTransformerErrorHandling> *)integerTransformer {
    return [MTLValueTransformer
            transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
                if ([value isKindOfClass:[NSString class]]) {
                    return @([value integerValue]);
                }
                
                return value;
            } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
                return value;
            }];
}

+ (NSValueTransformer *)longitudeJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NSStringFromClass([AGGeoValueTransformer class])];
}

+ (NSValueTransformer *)latitudeJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NSStringFromClass([AGGeoValueTransformer class])];
}

@end
