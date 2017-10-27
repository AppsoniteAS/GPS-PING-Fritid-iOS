//
//  ASPointModel.h
//  GpsPing
//
//  Created by Pavel Ivanov on 28/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ASPointModel : MTLModel<MTLJSONSerializing>
@property (nonatomic) NSNumber  *longitude;
@property (nonatomic) NSNumber  *latitude;
@property (nonatomic) NSNumber  *heading;

@property (nonatomic) NSNumber  *speed;

@property (nonatomic        ) NSDate   *timestamp;
@property (nonatomic        ) NSDate   *creationTime;
@end
