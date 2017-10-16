//
//  ASTrackerModel.h
//  GpsPing
//
//  Created by Pavel Ivanov on 19/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>
#import <ReactiveCocoa.h>


static NSString * const kASTrackerTypeTkStar      = @"TK_STAR";
static NSString * const kASTrackerTypeAnywhere    = @"TK_ANYWHERE";

static NSString * const kASTrackerTypeTkStarPet   = @"TK_STAR_PET";
static NSString * const kASTrackerTypeTkStarBike  = @"TK_STAR_BIKE";
static NSString * const kASTrackerTypeTkBike      = @"TK_BIKE";

static NSString * const kASTrackerTypeTkS1        = @"S1";
static NSString * const kASTrackerTypeTkA9        = @"A9";

static NSString * const kASTrackerTypeTk909        = @"TK909";



static NSString * const kASTrackerTypeLK209       = @"LK209";
static NSString * const kASTrackerTypeVT600       = @"VT600";
static NSString * const kASTrackerTypeLK330       = @"LK330";

static NSString * const kASSignalMetricTypeSeconds   = @"Seconds";
static NSString * const kASSignalMetricTypeMinutes   = @"Minutes";

static NSString * const kASUserDefaultsTrackersKey   = @"kASUserDefaultsTrackersKey";

@interface ASTrackerModel : MTLModel <MTLJSONSerializing>

//@property (nonatomic        ) NSString  *trackerId;
@property (nonatomic        ) NSString  *trackerName;
@property (nonatomic        ) NSString  *trackerNumber;
@property (nonatomic        ) NSString  *imeiNumber;
@property (nonatomic        ) NSString  *trackerType;
@property (nonatomic, assign) BOOL      isChoosed;
@property (nonatomic, assign) BOOL      isRunning;
@property (nonatomic, assign) BOOL      isGeofenceStarted;
@property (nonatomic, assign) BOOL      dogInStand;

@property (nonatomic, assign) BOOL      bikeLedLightIsOn;
@property (nonatomic, assign) BOOL      bikeShockAlarmIsOn;
@property (nonatomic, assign) BOOL      bikeFlashAlarmIsOn;
@property (nonatomic, assign) BOOL      dogSleepModeIsOn;


@property (nonatomic, assign) NSInteger signalRate;
@property (nonatomic        ) NSNumber  *signalRateInSeconds;
@property (nonatomic        ) NSString  *signalRateMetric;
@property (nonatomic        ) NSString  *geofenceYards;

@property (nonatomic, strong) NSString *trackerPhoneNumber;
@property (nonatomic, strong) NSString *imageId;

+(instancetype)initTrackerWithName:(NSString *)name
                            number:(NSString *)number
                              imei:(NSString *)imei
                              type:(NSString *)type
                         isChoosed:(BOOL)isChoosed
                         isRunning:(BOOL)isRunning;

+(NSArray*)getTrackersFromUserDefaults;
+(void)clearTrackersInUserDefaults;
+(ASTrackerModel *)getChoosedTracker;
+(void)removeTrackerWithNumber:(NSString*)trackerNumber;

-(void)saveInUserDefaults;

-(RACSignal*)getSmsTextsForActivation;
-(NSString*)getSmsTextsForTrackerUpdate;
-(NSString*)getSmsTextsForTrackerLaunch:(BOOL)isOn;
+(NSString*)getSmsTextsForGeofenceLaunch:(BOOL)turnOn
                                distance:(NSString*)distance;

+(NSString*)getSmsTextsForBikeLedLightForMode:(BOOL)turnOn;
+(NSString*)getSmsTextsForBikeShockAlarmForMode:(BOOL)turnOn;
+(NSString*)getSmsTextsForBikeFlashAlarm;

+(NSString*)getSmsTextForSleepMode:(BOOL)on;
+(NSString*)getSmsTextForCheckBattery;
-(RACSignal*)getSmsTextsForNewServer;
@end
