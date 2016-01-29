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

@interface ASDeviceModel : MTLModel<MTLJSONSerializing>

@property (nonatomic        ) NSArray  *points;

@property (nonatomic) NSNumber  *longitude;
@property (nonatomic) NSNumber  *latitude;
@property (nonatomic        ) NSDate   *lastDate;
@property (nonatomic        ) NSDate   *lastUpdate;
@property (nonatomic        ) NSString *name;
@property (nonatomic        ) NSString *trackerNumber;
@property (nonatomic        ) NSString *imei;

@end
