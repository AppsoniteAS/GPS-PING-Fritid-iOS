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
#import "ASUserProfileModel.h"
#import "AGApiController.h"

#import <Objection/Objection.h>
#include <netdb.h>
#include <arpa/inet.h>

#define ipAddress @"54.77.4.166" // @"52.19.58.234"

static DDLogLevel ddLogLevel               = DDLogLevelDebug;

NSString* const kASTrackerName        = @"name";
NSString* const kASTrackerNumber      = @"tracker_number";
NSString* const kASTrackerImei        = @"imei_number";
NSString* const kASTrackerType        = @"type";
NSString* const kASTrackerIsChoosed   = @"choosed";
NSString* const kASTrackerDogInStand  = @"check_for_stand";
NSString* const kASTrackerSignalRate  = @"reciver_signal_repeat_time";
NSString* const kASTrackerId          = @"tracker_id";
NSString* const kASIsRunning          = @"isRunning";
NSString* const kASIsGeofenceRunning  = @"isGeofenceRunning";
NSString* const kASGeofenceYards      = @"geofenceYards";
NSString* const kASBikeLedLightIsOn   = @"kASBikeLedLightIsOn";
NSString* const kASBikeFlashAlarmIsOn = @"kASBikeFlashAlarmIsOn";
NSString* const kASBikeShockAlarmIsOn = @"kASBikeShockAlarmIsOn";
NSString* const kASDogSleepModeIsOn   = @"kASDogSleepModeIsOn";

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
    model.signalRate = 60;
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
              @keypath(ASTrackerModel.new, isRunning)          : kASIsRunning,
              @keypath(ASTrackerModel.new, isGeofenceStarted)  : kASIsGeofenceRunning,
              @keypath(ASTrackerModel.new, geofenceYards)      : kASGeofenceYards,
               @keypath(ASTrackerModel.new, bikeLedLightIsOn)      : kASBikeLedLightIsOn,
               @keypath(ASTrackerModel.new, bikeFlashAlarmIsOn)      : kASBikeFlashAlarmIsOn,
               @keypath(ASTrackerModel.new, bikeShockAlarmIsOn)      : kASBikeShockAlarmIsOn,
               @keypath(ASTrackerModel.new, dogSleepModeIsOn)      : kASDogSleepModeIsOn
              };
}

+ (NSValueTransformer *)trackerTypeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *trackerType, BOOL *success, NSError *__autoreleasing *error) {
        if (trackerType == nil) {
            return kASTrackerTypeTkStarPet;
        }
        if ([trackerType isEqualToString:kASTrackerTypeTkBike]){
            return kASTrackerTypeTkStarBike;
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
    if (signalRateInSeconds.integerValue == 0) {
        signalRateInSeconds = @(60);
    }
    
    if (signalRateInSeconds.integerValue > 60) {
        self.signalRate = signalRateInSeconds.integerValue/60;
        self.signalRateMetric = kASSignalMetricTypeMinutes;
    } else {
        self.signalRate = signalRateInSeconds.integerValue;
        self.signalRateMetric = kASSignalMetricTypeSeconds;
    }
}

+(NSArray*)getTrackersFromUserDefaults {
    NSData *data = [[NSUserDefaults standardUserDefaults]
                            objectForKey:kASUserDefaultsTrackersKey];
    NSArray *trackers = [NSArray new];
    if ([data isKindOfClass:[NSArray class]]) {
        trackers = [data copy];
    } else {
        trackers = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
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
    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:jsonToSave];
    [[NSUserDefaults standardUserDefaults] setObject:dataSave
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
    
    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:filtered];
    [[NSUserDefaults standardUserDefaults] setObject:dataSave
                                              forKey:kASUserDefaultsTrackersKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(RACSignal*)getSmsTextsForActivation {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        struct hostent *host_entry = gethostbyname("fritid.gpsping.no");
        char *buff;
        buff = inet_ntoa(*((struct in_addr *)host_entry->h_addr_list[0]));
        
        buff = [ipAddress UTF8String];
        
        
        if (buff == NULL) {
            NSError *error = [NSError buildError:^(MRErrorBuilder *builder) {
                builder.domain = @"ASGpsPingErrorDomain";
                builder.localizedDescription = NSLocalizedString(@"Could not resolve Traccar's IP address", nil);
            }];
            
            [subscriber sendError:error];
            return nil;
        }
        
        NSArray *result;
        ASUserProfileModel *profileModel = [ASUserProfileModel loadSavedProfileInfo];

        NSString *phoneCode = [[profileModel.phoneCode componentsSeparatedByCharactersInSet:
                [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                componentsJoinedByString:@""];

        phoneCode = [NSString stringWithFormat:@"%@%@", @"00", phoneCode];
        
        if ([self.trackerType isEqualToString:kASTrackerTypeTkStarPet]) {
            result = @[[NSString stringWithFormat:@"admin123456 %@%@", phoneCode, profileModel.phoneNumber],
                       @"apn123456 internet.ts.m2m",
                       [NSString stringWithFormat: @"adminip123456 %@ 5013", ipAddress],
                       @"sleep123456 off"];
        }  else if ([self.trackerType isEqualToString:kASTrackerTypeLK209] || [self.trackerType isEqualToString:kASTrackerTypeLK330]) {
            ASUserProfileModel *profileModel = [ASUserProfileModel loadSavedProfileInfo];
            
            NSString *phoneCode = [[profileModel.phoneCode componentsSeparatedByCharactersInSet:
                                    [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                   componentsJoinedByString:@""];
            NSString *phoneNumber = profileModel.phoneNumber;
            
            if (!phoneCode || !phoneNumber) {
                NSError *error = [NSError buildError:^(MRErrorBuilder *builder) {
                    builder.domain = @"ASGpsPingErrorDomain";
                    builder.localizedDescription = NSLocalizedString(@"Please add phone number in settings", nil);
                }];
                
                [subscriber sendError:error];
                return nil;
            }
            
            result = @[[NSString stringWithFormat:@"admin123456 00%@%@", phoneCode, phoneNumber],
                       @"apn123456 internet.ts.m2m",
                       [NSString stringWithFormat:@"adminip123456 %s 5013", buff],
                       @"gprs123456"];
        } else if ([self.trackerType isEqualToString:kASTrackerTypeVT600]) {
            result = @[@"W000000,010,internet.ts.m2m",
                       [NSString stringWithFormat:@"W000000,012,%s,5009", buff],
                       @"W000000,013,1"];
        }  else if ([self.trackerType isEqualToString:kASTrackerTypeTkS1]) {
            result = @[@"pw,123456,apn,internet.ts.m2m,,,23820#",
                       [NSString stringWithFormat:@"pw,123456,ip,%s,5093#", buff]];
        } else {
            result = @[[NSString stringWithFormat:@"admin123456 %@%@", phoneCode, profileModel.phoneNumber],
                       @"apn123456 internet.ts.m2m",
                       [NSString stringWithFormat: @"adminip123456 %@ 5093", ipAddress],
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
        if ([self.trackerType isEqualToString:kASTrackerTypeVT600]) {
            return @"W000000,013,0";
        } else if ([self.trackerType isEqualToString:kASTrackerTypeLK209] || [self.trackerType isEqualToString:kASTrackerTypeLK330]) {
            return @"gpsloc123456,1";
        }
        else if ([self.trackerType isEqualToString:kASTrackerTypeTkS1]) {
            return @"pw,123456,upload,000#";
        }
        return @"nogprs123456";
    }
    
    if ([self.trackerType isEqualToString:kASTrackerTypeTkStar] ||
        [self.trackerType isEqualToString:kASTrackerTypeTkStarPet] ||
        [self.trackerType isEqualToString:kASTrackerTypeTkStarBike]) {
        return @"gprs123456";
    } else  if (
                [self.trackerType isEqualToString:kASTrackerTypeLK209] ||
                [self.trackerType isEqualToString:kASTrackerTypeLK330]) {
        NSInteger timeHours = self.signalRate / 60;
        
        return [NSString stringWithFormat:@"DW005,%02d", (int) timeHours];
    } else if ([self.trackerType isEqualToString:kASTrackerTypeVT600]) {
        NSInteger signalRate = self.signalRate;
        if ([self.signalRateMetric isEqualToString:kASSignalMetricTypeMinutes]) {
            signalRate *= 60;
        }
        
        if (signalRate <= 10) {
            signalRate = 10;
        }
        
        return [NSString stringWithFormat:@"W00000,014,%05d", (int) signalRate / 10];
    } else if ([self.trackerType isEqualToString:kASTrackerTypeTkS1]) {
        return [NSString stringWithFormat:@"pw,123456,upload,%03d#", (int) self.signalRate];
    } else {
        NSString *rateMetric = [self.signalRateMetric isEqualToString:kASSignalMetricTypeMinutes] ?
        @"m" : @"s";
        return [NSString stringWithFormat:@"T%03d%@***n123456",
                              (int)self.signalRate,
                              rateMetric];
    }
}

-(NSString*)getSmsTextsForTrackerUpdate
{
    NSInteger signalRate = self.signalRate;
    if ([self.signalRateMetric isEqualToString:kASSignalMetricTypeMinutes]){
        signalRate *= 60;
    }
    
    return [NSString stringWithFormat:@"Upload123456 %03d", (int)signalRate];
}

+(NSString*)getSmsTextsForGeofenceLaunch:(BOOL)turnOn
                                distance:(NSString*)distance
{
    if (turnOn) {
         return [@"move123456 " stringByAppendingString:distance];
    } else {
        return @"move123456 0";
    }
}

+(NSString*)getSmsTextsForBikeLedLightForMode:(BOOL)turnOn
{
    if (turnOn) {
        return @"Led123456 on";
    } else {
        return @"Led123456 off";
    }
}

+(NSString*)getSmsTextsForBikeShockAlarmForMode:(BOOL)turnOn
{
    if (turnOn) {
        return @"shock123456";
    } else {
        return @"sleep123456 time";
    }
}

+(NSString*)getSmsTextsForBikeFlashAlarm
{
   return @"LED123456 shock";
}

+(NSString*)getSmsTextForSleepMode:(BOOL)on {
    if (on) {
        return @"sleep123456";
    } else {
        return @"sleep123456 off";
    }
}

+(NSString*)getSmsTextForCheckBattery {
    return @"G123456#";
}

-(NSString *)trackerPhoneNumber {
    AGApiController *ctl = [[JSObjection defaultInjector] getObject:AGApiController.class];
    NSString *code = ctl.userProfile.phoneCode;
    
    if ([code isEqual:@"358"]) {
        @try {
            NSString *clearString = [self.trackerNumber substringFromIndex:2];
            return [NSString stringWithFormat:@"+%@", clearString];
        } @catch(NSException *ex) {
            DDLogError(@"Error while creating trackerPhoneNumber, reason: %@", ex.reason);
        }
    }
    
    return self.trackerNumber;
}

@end
