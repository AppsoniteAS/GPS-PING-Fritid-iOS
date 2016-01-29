//
//  ASFriendAnnotation.h
//  GpsPing
//
//  Created by Pavel Ivanov on 28/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ASModel.h"

@interface ASFriendAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic) UIColor *annotationColor;
@property (nonatomic) ASFriendModel *userObject;


- (id)initWithLocation:(CLLocationCoordinate2D)coord;

@end