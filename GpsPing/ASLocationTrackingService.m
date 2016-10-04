//
//  ASLocationTrackingService.m
//  GpsPing
//
//  Created by Pavel Ivanov on 03/10/2016.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASLocationTrackingService.h"
#import "AGApiController.h"
#import <MMPReactiveCoreLocation/MMPReactiveCoreLocation.h>

@interface ASLocationTrackingService()
@property (nonatomic, strong) AGApiController   *apiController;
@property (nonatomic, strong) RACSubject *stopSignal;
@property (nonatomic, strong) MMPReactiveCoreLocation *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, assign) BOOL canMakeRequest;


@end

@implementation ASLocationTrackingService

objection_register_singleton(ASLocationTrackingService);
objection_requires(@keypath(ASLocationTrackingService.new, apiController))

-(void)awakeFromObjection {
    [super awakeFromObjection];
    self.isServiceRunning = NO;
    self.canMakeRequest = YES;
    self.stopSignal = [RACSubject subject];
    self.locationManager = [MMPReactiveCoreLocation service];
}

-(void)startLocationTracking {
    if (self.isServiceRunning) return;
    
    [[self.locationManager locations] subscribeNext:^(CLLocation *location) {
         if (location.coordinate.latitude == self.lastLocation.coordinate.latitude &&
             location.coordinate.longitude == self.lastLocation.coordinate.longitude) {
             return;
         }
         
         self.lastLocation = location;
        if (self.canMakeRequest) {
            self.canMakeRequest = NO;
            [[self.apiController sendUserPosition:location.coordinate] subscribeNext:^(id x) {
                self.canMakeRequest = YES;
            } error:^(NSError *error) {
                self.canMakeRequest = YES;
            }];
        }
     }];
    
    self.isServiceRunning = YES;
}

-(void)stopLocationTracking {
    if (!self.isServiceRunning) return;
    [self.locationManager stop];
    self.isServiceRunning = NO;
}

@end
