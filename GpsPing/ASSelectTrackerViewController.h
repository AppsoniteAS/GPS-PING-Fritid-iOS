//
//  ASSelectTracker.h
//  GpsPing
//
//  Created by Pavel Ivanov on 22/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DTTableViewManager/DTTableViewManager.h>
#import "ASTrackerModel.h"

@class ASSelectTrackerViewController;

@protocol ASSelectTrackerProtocol <NSObject>

-(void)selectTracker:(ASSelectTrackerViewController*)controller trackerChoosed:(ASTrackerModel*)trackerModel;

@end

@interface ASSelectTrackerViewController : DTTableViewController

@property(nonatomic, weak) id<ASSelectTrackerProtocol> delegate;

+(instancetype)initialize;

@end
