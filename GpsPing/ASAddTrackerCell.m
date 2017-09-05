//
//  ASAddTrackerCell.m
//  GpsPing
//
//  Created by Юджин Топсекретович on 9/5/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import "ASAddTrackerCell.h"
#import "UIColor+ASColor.h"

@interface ASAddTrackerCell()
@property (strong, nonatomic) NSString* trackerName;

@end

@implementation ASAddTrackerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.btnTracker.layer.cornerRadius = self.btnTracker.frame.size.width/2; //168
    self.btnTracker.layer.borderColor = [UIColor as_darkestBlueColor].CGColor;
    self.btnTracker.layer.borderWidth = 5.0f;
}


- (void) handleBtTrackerName: (NSString*) trackerName{
    [self.btnTracker setImage:[UIImage imageNamed:trackerName] forState:UIControlStateNormal];
    [self.btnTracker setImage:[UIImage imageNamed:trackerName] forState:UIControlStateSelected];
    [self.btnTracker setImage:[UIImage imageNamed:trackerName] forState:UIControlStateHighlighted];
    self.trackerName = trackerName;
}

- (IBAction)pressedBtnTracker:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectTracker:)]){
        [self.delegate didSelectTracker:self.trackerName];
    }
}

@end
