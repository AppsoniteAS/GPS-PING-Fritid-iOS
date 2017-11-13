//
//  ASAttributesModel.m
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/27/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import "ASAttributesModel.h"
#import <extobjc.h>


#import <CocoaLumberjack.h>
static DDLogLevel ddLogLevel               = DDLogLevelDebug;

NSString* const kASAttributesBattery          = @"battery";
//NSString* const kASAttributesPower          = @"power";
//NSString* const kASAttributesIngnition          = @"ignition";

NSString* const kASAttributesIP          = @"ip";
NSString* const kASAttributesDistance    = @"distance";
NSString* const kASAttributesTotalDistance = @"totalDistance";

@implementation ASAttributesModel


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @keypath(ASAttributesModel.new, battery)     : kASAttributesBattery,
            //  @keypath(ASAttributesModel.new, power)    : kASAttributesPower,
              //@keypath(ASAttributesModel.new, ignition)     : kASAttributesIngnition,
              @keypath(ASAttributesModel.new, distance)    : kASAttributesDistance,
              @keypath(ASAttributesModel.new, totalDistance)     : kASAttributesTotalDistance,
              @keypath(ASAttributesModel.new, ipAddress)    : kASAttributesIP};
}

@end
