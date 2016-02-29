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
#import "Underscore.h"
#import <ErrorKit/ErrorKit.h>

#include <netdb.h>
#include <arpa/inet.h>

static DDLogLevel ddLogLevel               = DDLogLevelDebug;

NSString* const kASTrackerName             = @"name";
NSString* const kASTrackerNumber           = @"tracker_number";
NSString* const kASTrackerImei             = @"imei_number";
NSString* const kASTrackerType             = @"type";
NSString* const kASTrackerIsChoosed        = @"choosed";
NSString* const kASTrackerDogInStand       = @"check_for_stand";
NSString* const kASTrackerSignalRate       = @"reciver_signal_repeat_time";
NSString* const kASTrackerId               = @"tracker_id";
NSString* const kASIsRunning               = @"isRunning";

@implementation ASTrackerModel

+(instancetype)initTrackerWithName:(NSString *)name
                            number:(NSString *)number
                              imei:(NSString *)imei
                              type:(NSString *)type
                         isChoosed:(BOOL)isChoosed
                         isRunning:(BOOL)isRunning {
    ASTrackerModel *model = [[ASTrackerModel alloc] init];
    model.trackerName = name;
    model.imeiNumber = imei;
    model.trackerNumber = number;
    model.trackerType = type;
    model.isChoosed = isChoosed;
    model.signalRate = 50;
    model.signalRateMetric = kASSignalMetricTypeSeconds;
    model.isRunning = isRunning;
    return model;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @keypath(ASTrackerModel.new, trackerName)        : kASTrackerName,
              @keypath(ASTrackerModel.new, trackerNumber)      : kASTrackerNumber,
              @keypath(ASTrackerModel.new, imeiNumber)         : kASTrackerImei,
              @keypath(ASTrackerModel.new, trackerType)        : kASTrackerType,
              @keypath(ASTrackerModel.new, isChoosed)          : kASTrackerIsChoosed,
              @keypath(ASTrackerModel.new, dogInStand)         : kASTrackerDogInStand,
              @keypath(ASTrackerModel.new, signalRateInSeconds): kASTrackerSignalRate,
              @keypath(ASTrackerModel.new, isRunning)          : kASIsRunning
              };
}

+ (NSValueTransformer *)trackerTypeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *trackerType, BOOL *success, NSError *__autoreleasing *error) {
        if (trackerType == nil) {
            return kASTrackerTypeAnywhere;
        }
        
        return trackerType;
    }];
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

+(ASTrackerModel *)getChoosedTracker
{
    NSArray *trackers = [ASTrackerModel getTrackersFromUserDefaults];
    for (ASTrackerModel *tracker in trackers) {
        if (tracker.isChoosed) {
            return tracker;
        }
    }
    
    return nil;
	
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

+(void)clearTrackersInUserDefaults
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kASUserDefaultsTrackersKey];
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
    if (error) {
        DDLogError(@"Error saving trackers: %@", error);
        return;
    }
    
    if (!jsonToSave) {
        DDLogError(@"Empty JSON while saving trackers");
    }

    NSArray* filtered = Underscore.array(jsonToSave).map(^NSDictionary *(NSDictionary *object) {
        return Underscore.rejectValues(object, Underscore.isNull);
    }).unwrap;
    
    [[NSUserDefaults standardUserDefaults] setObject:filtered
                                              forKey:kASUserDefaultsTrackersKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(RACSignal*)getSmsTextsForActivation {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        struct hostent *host_entry = gethostbyname("fritid.gpsping.no");
        char *buff;
        buff = inet_ntoa(*((struct in_addr *)host_entry->h_addr_list[0]));
        if (buff == NULL) {
            NSError *error = [NSError buildError:^(MRErrorBuilder *builder) {
                builder.domain = @"ASGpsPingErrorDomain";
                builder.localizedDescription = NSLocalizedString(@"Could not resolve Traccar's IP address", nil);
            }];
            
            [subscriber sendError:error];
            return nil;
        }
        
        NSArray *result;
        if ([self.trackerType isEqualToString:kASTrackerTypeAnywhere]) {
            result = @[@"Begin123456",
                       @"gprs123456",
                       @"apn123456 netcom",
                       [NSString stringWithFormat:@"adminip123456 %s 5000", buff],
                       @"sleep123456 off"];
        } else {
            result = @[@"Begin123456",
                       @"gprs123456",
                       @"apn123456 netcom",
                       [NSString stringWithFormat:@"adminip123456 %s 5013", buff],
                       @"sleep123456 off"];
        }

        
        [subscriber sendNext:result];
        [subscriber sendCompleted];
        return nil;
    }];
}

-(NSString*)getSmsTextsForTrackerLaunch:(BOOL)isOn
{
    if (!isOn) {
        return @"Notn123456";
    }
    
    if ([self.trackerType isEqualToString:kASTrackerTypeTkStar] ||
        [self.trackerType isEqualToString:kASTrackerTypeTkStarPet]) {
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

+(NSString*)getSmsTextsForGeofenceLaunch:(BOOL)turnOn
                             phoneNumber:(NSString*)userPhoneNumber
{
    if (turnOn) {
         return [@"admin123456 " stringByAppendingString:userPhoneNumber];
    } else {
        return @"move123456 0";
    }
}

@end
