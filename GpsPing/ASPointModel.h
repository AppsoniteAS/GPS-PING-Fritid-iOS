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
@property (nonatomic) NSNumber  *longitude;
@property (nonatomic) NSNumber  *latitude;
@property (nonatomic) NSNumber  *heading;
@property (nonatomic) NSNumber  *gps;
@property (nonatomic) NSNumber  *gsm;

@property (nonatomic) NSNumber  *speed;
@property (nonatomic) ASAttributesModel  *attributes;

@property (nonatomic        ) NSDate   *timestamp;
@property (nonatomic        ) NSDate   *creationTime;
@end
