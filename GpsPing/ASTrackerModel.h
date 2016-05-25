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
static NSString * const kASTrackerTypeTkStarPet   = @"TK_STAR_PET";
static NSString * const kASTrackerTypeAnywhere    = @"TK_ANYWHERE";
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
@property (nonatomic, assign) NSInteger signalRate;
@property (nonatomic        ) NSNumber  *signalRateInSeconds;
@property (nonatomic        ) NSString  *signalRateMetric;
@property (nonatomic        ) NSString  *geofenceYards;

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
-(NSString*)getSmsTextsForTrackerLaunch:(BOOL)isOn;
-(NSString*)getSmsTextsForGeofenceLaunchWithDistance:(NSString*)distance;

@end
