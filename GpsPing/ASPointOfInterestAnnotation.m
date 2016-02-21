//
//  ASPointOfInterestAnnotation.m
//  GpsPing
//
//  Created by Maks Niagolov on 2/21/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASPointOfInterestAnnotation.h"

@implementation ASPointOfInterestAnnotation
@synthesize coordinate;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    
    return self;
}
@end
