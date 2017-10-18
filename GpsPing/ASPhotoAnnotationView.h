//
//  ASPhotoAnnotationView.h
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/18/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ASPinMainView.h"

@interface ASPhotoAnnotationView : MKAnnotationView
@property (strong, nonatomic) ASPinMainView* marker;
@end
