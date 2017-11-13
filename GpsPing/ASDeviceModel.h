//
//  ASDeviceModel.h
//  GpsPing
//
//  Created by Pavel Ivanov on 27/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mantle/Mantle.h>
#import <CoreLocation/CoreLocation.h>
#import "ASAttributesModel.h"

@interface ASDeviceModel : MTLModel<MTLJSONSerializing>

@property (nonatomic , strong       ) NSArray  *points;

@property (nonatomic, strong) NSNumber  *longitude;
@property (nonatomic, strong) NSNumber  *latitude;
@property (nonatomic, strong) NSNumber  *trackDistance;

@property (nonatomic , strong       ) NSDate   *lastDate;
@property (nonatomic , strong       ) NSDate   *lastUpdate;
@property (nonatomic , strong       ) NSString *name;
@property (nonatomic , strong       ) NSString *trackerNumber;
@property (nonatomic , strong       ) NSString *imei;
@property (nonatomic, strong ) NSString *imageId;

//@property (nonatomic, strong) ASAttributesModel  *attributes;
@property (nonatomic, strong) NSNumber  *gps;
@property (nonatomic, strong) NSNumber  *gsm;
@property (nonatomic, strong) NSNumber  *heading;

@property (nonatomic, strong) NSNumber  *speed;
@property (nonatomic, strong        ) NSNumber  *  power;


@property (nonatomic, strong        ) NSNumber  *  battery;
@property (nonatomic , strong        ) NSString  *ipAddress;
@property (nonatomic , strong        ) NSNumber  *distance;
@property (nonatomic , strong        ) NSNumber  *totalDistance;

@end
