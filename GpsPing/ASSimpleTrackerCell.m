//
//  ASSimpleTrackerCell.m
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/5/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import "ASSimpleTrackerCell.h"
#import <YYWebImage.h>
#import "ASS3Manager.h"
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@implementation ASSimpleTrackerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageViewIcon.layer.cornerRadius = self.imageViewIcon.frame.size.width/2;
    self.imageViewIcon.layer.borderWidth = 2.0;
    self.imageViewIcon.layer.borderColor = [UIColor colorWithRed:0.5451 green:0.7647 blue:0.2902 alpha:1.0].CGColor;
}

- (void)handleByTracker:(ASTrackerModel *)tracker{
    @weakify(self)
    self.tracker = tracker;
    self.labelName.text = tracker.trackerName;

    
    if (self.tracker.imageId){
        [self.imageViewIcon yy_setImageWithURL:[ [ASS3Manager sharedInstance] getURLByImageIdentifier: self.tracker.imageId ] placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            if (from == YYWebImageFromDiskCache) {
                @strongify(self)
                DDLogDebug(@"load from disk cache");
            }
        }];
    } else{
        self.imageViewIcon.image = [UIImage imageNamed:tracker.trackerType];
    }
}

@end
