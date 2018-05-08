//
//  ASTrackerConfigurationViewController.h
//  GpsPing
//
//  Created by Pavel Ivanov on 20/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASTrackerModel.h"
#import "ASTrackersViewController.h"

@interface ASTrackerConfigurationViewController : UITableViewController
@property (nonatomic) ASTrackerModel *trackerObject;
@property (weak, nonatomic) id<ASTrackersViewControllerProtocol> delegate;

+(instancetype)initializeWithTrackerModel:(ASTrackerModel *)trackerModel;
//+ (instancetype)initialize;
@end
