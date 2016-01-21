//
//  ASTrackerModel.m
//  GpsPing
//
//  Created by Pavel Ivanov on 19/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASTrackerModel.h"
#import <extobjc.h>
#import <CocoaLumberjack.h>
static DDLogLevel ddLogLevel = DDLogLevelDebug;

NSString* const kASTrackerName      = @"name";
NSString* const kASTrackerNumber    = @"number";
NSString* const kASTrackerImei      = @"imei";
NSString* const kASTrackerType      = @"type";
NSString* const kASTrackerIsChoosed = @"choosed";
NSString* const kASTrackerDogInStand = @"doginstand";
NSString* const kASTrackerSignalRate = @"rate";
NSString* const kASTrackerSignalRateMetric = @"metric";

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
    model.signalRate = 1;
    model.signalRateMetric = kASSignalMetricTypeSeconds;
    return model;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
                @keypath(ASTrackerModel.new, trackerName)       : kASTrackerName,
                @keypath(ASTrackerModel.new, trackerNumber)     : kASTrackerNumber,
                @keypath(ASTrackerModel.new, imeiNumber)        : kASTrackerImei,
                @keypath(ASTrackerModel.new, trackerType)       : kASTrackerType,
                @keypath(ASTrackerModel.new, isChoosed)         : kASTrackerIsChoosed,
                @keypath(ASTrackerModel.new, dogInStand)        : kASTrackerDogInStand,
                @keypath(ASTrackerModel.new, signalRate)        : kASTrackerSignalRate,
                @keypath(ASTrackerModel.new, signalRateMetric)  : kASTrackerSignalRateMetric
              };
}

+(NSArray*)getTrackersFromUserDefaults {
    NSArray *trackers = [[NSUserDefaults standardUserDefaults]
                            arrayForKey:kASUserDefaultsTrackersKey];
    if (!trackers) {
        return @[];
    }
    
    NSError *error;
    NSArray *result = [MTLJSONAdapter modelsOfClass:[ASTrackerModel class] fromJSONArray:trackers error:&error];
    if (error) {
        DDLogError(@"Error reading trackers: %@", error);
        return nil;
    }
    
    return result;
}

+(void)removeTrackerWithNumber:(NSString*)trackerNumber
{
    NSArray * trackers = [ASTrackerModel getTrackersFromUserDefaults];
    NSMutableArray *trackers_m = trackers.mutableCopy;
    for (ASTrackerModel *tracker in trackers_m) {
        if ([tracker.trackerNumber isEqualToString:trackerNumber]) {
            [trackers_m removeObject:tracker];
            break;
        }
    }

    NSError *error;
    NSArray *jsonToSave = [MTLJSONAdapter JSONArrayFromModels:trackers_m
                                                        error:&error];
    [[NSUserDefaults standardUserDefaults] setObject:jsonToSave
                                              forKey:kASUserDefaultsTrackersKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)saveInUserDefaults {
    NSArray * trackers = [ASTrackerModel getTrackersFromUserDefaults];
    NSMutableArray *trackers_m = trackers.mutableCopy;
    BOOL trackerWasChanged = NO;
    for (ASTrackerModel *tracker in trackers_m) {
        if ([tracker.trackerNumber isEqualToString:self.trackerNumber]) {
//            [trackers_m removeObject:tracker];
            trackers_m[[trackers_m indexOfObject:tracker]] = self;
            trackerWasChanged = YES;
            break;
        }
    }
    
    if (!trackerWasChanged) {
        [trackers_m addObject:self];
    }
    
    NSError *error;
    NSArray *jsonToSave = [MTLJSONAdapter JSONArrayFromModels:trackers_m
                                                        error:&error];
    [[NSUserDefaults standardUserDefaults] setObject:jsonToSave
                                              forKey:kASUserDefaultsTrackersKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
