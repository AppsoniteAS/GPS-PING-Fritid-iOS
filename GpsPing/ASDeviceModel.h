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

@property (nonatomic        ) NSArray  *points;

@property (nonatomic) NSNumber  *longitude;
@property (nonatomic) NSNumber  *latitude;
@property (nonatomic) NSNumber  *trackDistance;

@property (nonatomic        ) NSDate   *lastDate;
@property (nonatomic        ) NSDate   *lastUpdate;
@property (nonatomic        ) NSString *name;
@property (nonatomic        ) NSString *trackerNumber;
@property (nonatomic        ) NSString *imei;
@property (nonatomic, strong ) NSString *imageId;

@property (nonatomic) ASAttributesModel  *attributes;
@property (nonatomic) NSNumber  *gps;
@property (nonatomic) NSNumber  *gsm;
@property (nonatomic) NSNumber  *heading;

@property (nonatomic) NSNumber  *speed;

@end
