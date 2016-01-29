//
//  ASLastPointAnnotation.h
//  GpsPing
//
//  Created by Pavel Ivanov on 28/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ASModel.h"
#import "ASDevicePointAnnotation.h"

@interface ASLastPointAnnotation : ASDevicePointAnnotation

//@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
//@property (nonatomic) ASPointModel *pointObject;

- (id)initWithLocation:(CLLocationCoordinate2D)coord;

@end