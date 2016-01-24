//
//  ASMainViewModel.h
//  GpsPing
//
//  Created by Maks Niagolov on 1/24/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGApiController.h"

@interface ASMainViewModel : NSObject
@property (nonatomic, strong) AGApiController   *apiController;
@end
