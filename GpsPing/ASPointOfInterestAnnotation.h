//
//  ASPointOfInterestAnnotation.h
//  GpsPing
//
//  Created by Maks Niagolov on 2/21/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ASModel.h"

@interface ASPointOfInterestAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic) UIColor *annotationColor;
@property (nonatomic) ASPointOfInterestModel *poiObject;


- (id)initWithLocation:(CLLocationCoordinate2D)coord;

@end
