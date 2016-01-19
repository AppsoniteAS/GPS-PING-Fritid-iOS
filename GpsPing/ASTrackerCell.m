//
//  ASTrackerCell.m
//  GpsPing
//
//  Created by Pavel Ivanov on 19/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASTrackerCell.h"

@implementation ASTrackerCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib
{
    self.trackerImage.layer.cornerRadius = self.trackerImage.frame.size.width/2;
    self.trackerImage.layer.borderWidth = 2.0;
    self.trackerImage.layer.borderColor = [UIColor colorWithRed:0.5451 green:0.7647 blue:0.2902 alpha:1.0].CGColor;
}

-(void)updateWithModel:(id)model
{
    
}

@end
