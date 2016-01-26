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
static DDLogLevel ddLogLevel               = DDLogLevelDebug;

NSString* const kASTrackerName             = @"name";
NSString* const kASTrackerNumber           = @"tracker_number";
NSString* const kASTrackerImei             = @"imei_number";
NSString* const kASTrackerType             = @"type";
NSString* const kASTrackerIsChoosed        = @"choosed";
NSString* const kASTrackerDogInStand       = @"check_for_stand";
NSString* const kASTrackerSignalRate       = @"reciver_signal_repeat_time";
NSString* const kASTrackerId               = @"tracker_id";

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
             @keypath(ASTrackerModel.new, trackerName)         : kASTrackerName,
              @keypath(ASTrackerModel.new, trackerNumber)      : kASTrackerNumber,
              @keypath(ASTrackerModel.new, imeiNumber)         : kASTrackerImei,
              @keypath(ASTrackerModel.new, trackerType)        : kASTrackerType,
              @keypath(ASTrackerModel.new, isChoosed)          : kASTrackerIsChoosed,
              @keypath(ASTrackerModel.new, dogInStand)         : kASTrackerDogInStand,
              @keypath(ASTrackerModel.new, signalRateInSeconds): kASTrackerSignalRate,
//              @keypath(ASTrackerModel.new, trackerId)          : kASTrackerId
              };
}

-(NSNumber *)signalRateInSeconds
{
    if ([self.signalRateMetric isEqualToString:kASSignalMetricTypeSeconds]) {
        return @(self.signalRate);
    } else {
        return @(self.signalRate*60);
    }
}

-(void)setSignalRateInSeconds:(NSNumber *)signalRateInSeconds
{
    if (signalRateInSeconds.integerValue > 60) {
        self.signalRate = signalRateInSeconds.integerValue/60;
        self.signalRateMetric = kASSignalMetricTypeMinutes;
    } else {
        self.signalRate = signalRateInSeconds.integerValue;
        self.signalRateMetric = kASSignalMetricTypeSeconds;
    }
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

-(NSArray*)getSmsTextsForActivation {
    NSArray *result;
    if ([self.trackerType isEqualToString:kASTrackerTypeAnywhere]) {
        result = @[@"Begin123456",
                   @"gprs123456",
                   @"apn123456 netcom",
                   @"adminip123456 46.137.82.251 5000",
                   @"sleep123456 off"];
    } else {
        result = @[@"Begin123456",
                   @"gprs123456",
                   @"apn123456 netcom",
                   @"adminip123456 46.137.82.251 5013",
                   @"sleep123456 off"];
    }
    
    return result;
}

-(NSString*)getSmsTextsForTrackerLaunch:(BOOL)isOn
{
    if ([self.trackerType isEqualToString:kASTrackerTypeTkStar]) {
        NSInteger signalRate = self.signalRate;
        if ([self.signalRateMetric isEqualToString:kASSignalMetricTypeMinutes]){
            signalRate *= 60;
        }
        
        return [NSString stringWithFormat:@"Upload123456 %03d", (int)signalRate];
    } else {
        NSString *rateMetric = [self.signalRateMetric isEqualToString:kASSignalMetricTypeMinutes] ?
        @"m" : @"s";
        return [NSString stringWithFormat:@"T%03d%@***n123456",
                              (int)self.signalRate,
                              rateMetric];
    }
}

-(NSArray*)getSmsTextsForGeofenceLaunch:(BOOL)isOn
{
    return @[];
}

@end
