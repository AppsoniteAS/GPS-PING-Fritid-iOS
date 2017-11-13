//
//  ASPointModel.h
//  GpsPing
//
//  Created by Pavel Ivanov on 28/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "ASAttributesModel.h"

@interface ASPointModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, strong) NSNumber  *longitude;
@property (nonatomic, strong) NSNumber  *latitude;
@property (nonatomic, strong) NSNumber  *heading;
@property (nonatomic, strong) NSNumber  *gps;
@property (nonatomic, strong) NSNumber  *gsm;

@property (nonatomic, strong) NSNumber  *speed;
//@property (nonatomic, strong) ASAttributesModel  *attributes;

@property (nonatomic, strong        ) NSDate   *timestamp;
@property (nonatomic , strong       ) NSDate   *creationTime;

@property (nonatomic, strong        ) NSNumber  *  battery;
@property (nonatomic , strong        ) NSString  *ipAddress;
@property (nonatomic , strong        ) NSNumber  *distance;
@property (nonatomic , strong        ) NSNumber  *totalDistance;
@end
