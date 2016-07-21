//
//  ASTrackerConfigurationViewController.h
//  GpsPing
//
//  Created by Pavel Ivanov on 20/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASTrackerModel.h"

@interface ASTrackerConfigurationViewController : UIViewController
@property (nonatomic) ASTrackerModel *trackerObject;

+(instancetype)initializeWithTrackerModel:(ASTrackerModel *)trackerModel;

@end
