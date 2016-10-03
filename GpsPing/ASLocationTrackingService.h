//
//  ASLocationTrackingService.h
//  GpsPing
//
//  Created by Pavel Ivanov on 03/10/2016.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"
#import <Objection/Objection.h>
#import <extobjc.h>

@interface ASLocationTrackingService : NSObject
@property (nonatomic, assign) BOOL isServiceRunning;
-(void)startLocationTracking;
-(void)stopLocationTracking;
@end
