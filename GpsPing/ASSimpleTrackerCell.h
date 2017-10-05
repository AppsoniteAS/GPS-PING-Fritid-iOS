//
//  ASSimpleTrackerCell.h
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/5/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASTrackerModel.h"

@interface ASSimpleTrackerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;

@property (strong, nonatomic) ASTrackerModel* tracker;
- (void) handleByTracker: (ASTrackerModel*) tracker;

@end
