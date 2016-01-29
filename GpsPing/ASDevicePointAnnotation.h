//
//  ASDevicePointAnnotation.h
//  GpsPing
//
//  Created by Pavel Ivanov on 29/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASModel.h"
#import <MapKit/MapKit.h>

@interface ASDevicePointAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic) ASPointModel  *pointObject;
@property (nonatomic) ASDeviceModel *deviceObject;
@property (nonatomic) ASFriendModel *owner;
@property (nonatomic) UIColor       *annotationColor;

- (id)initWithLocation:(CLLocationCoordinate2D)coord;

@end
