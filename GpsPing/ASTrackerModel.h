//
//  ASTrackerModel.h
//  GpsPing
//
//  Created by Pavel Ivanov on 19/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

static NSString * const kASTrackerTypeTkStar      = @"trackerTkStar";
static NSString * const kASTrackerTypeTkStarPet   = @"trackerTkStarPet";
static NSString * const kASTrackerTypeAnywhere    = @"trackerAnywhere";

static NSString * const kASSignalMetricTypeSeconds   = @"Seconds";
static NSString * const kASSignalMetricTypeMinutes   = @"Minutes";

static NSString * const kASUserDefaultsTrackersKey   = @"kASUserDefaultsTrackersKey";

@interface ASTrackerModel : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *trackerName;
@property (nonatomic) NSString *trackerNumber;
@property (nonatomic) NSString *imeiNumber;
@property (nonatomic) NSString *trackerType;
@property (nonatomic, assign) BOOL isChoosed;
@property (nonatomic, assign) BOOL dogInStand;
@property (nonatomic, assign) NSInteger signalRate;
@property (nonatomic, assign) NSString *signalRateMetric;

+(instancetype)initTrackerWithName:(NSString *)name
                            number:(NSString *)number
                              imei:(NSString *)imei
                              type:(NSString *)type
                         isChoosed:(BOOL)isChoosed;

+(NSArray*)getTrackersFromUserDefaults;
+(void)removeTrackerWithNumber:(NSString*)trackerNumber;

-(void)saveInUserDefaults;
-(NSArray*)getSmsTextsForActivation;
-(NSString*)getSmsTextsForTrackerLaunch:(BOOL)isOn;
-(NSArray*)getSmsTextsForGeofenceLaunch:(BOOL)isOn;

@end
