//
//  ASSimpleTrackerCell.m
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/5/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import "ASSimpleTrackerCell.h"

@implementation ASSimpleTrackerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageViewIcon.layer.cornerRadius = self.imageViewIcon.frame.size.width/2;
    self.imageViewIcon.layer.borderWidth = 2.0;
    self.imageViewIcon.layer.borderColor = [UIColor colorWithRed:0.5451 green:0.7647 blue:0.2902 alpha:1.0].CGColor;
}

- (void)handleByTracker:(ASTrackerModel *)tracker{
    self.tracker = tracker;
    self.labelName.text = tracker.trackerName;

    
    self.imageViewIcon.image = [UIImage imageNamed:tracker.trackerType];

}

@end
