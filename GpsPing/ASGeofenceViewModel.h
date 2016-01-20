//
//  ASGeofenceViewModel.h
//  GpsPing
//
//  Created by Maks Niagolov on 1/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

@interface ASGeofenceViewModel : NSObject
@property (strong, nonatomic  ) NSString      *yards;
@property (strong, nonatomic  ) NSString      *phoneNumber;
@property (readonly, nonatomic) RACCommand    *submit;
@end
