//
//  ASMapDetailsView.m
//  GpsPing
//
//  Created by Pavel Ivanov on 29/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASMapDetailsView.h"
#import "UIImage+ASAnnotations.h"

@implementation ASMapDetailsView

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.cornerRadius = 2.0;
}

-(void)configWithOwner:(ASFriendModel*)owner
               tracker:(ASDeviceModel*)deviceModel
                 point:(ASPointModel*)pointModel
                 color:(UIColor*)color {
    self.labelOwnerName.text = owner.userName;
    self.imaeViewOwnerIcon.image = [UIImage getUserAnnotationImageWithColor:color];
    
    if (deviceModel) {
        self.labelTrackerNumber.text = deviceModel.trackerNumber;
        self.labelImei.text = deviceModel.imei;
        self.labelTrackerName.text = deviceModel.name;
    }
    
    if (pointModel) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle  = NSDateFormatterShortStyle;
        dateFormatter.timeStyle  = NSDateFormatterShortStyle;
        self.labelLogTime.text   = [dateFormatter stringFromDate:pointModel.timestamp];
        self.labelLatitude.text  = [NSString stringWithFormat:@"%.06f", pointModel.latitude.doubleValue];
        self.labelLongitude.text = [NSString stringWithFormat:@"%.06f", pointModel.longitude.doubleValue];
    } else {
        self.labelLatitude.text  = [NSString stringWithFormat:@"%.06f", owner.latitude.doubleValue];
        self.labelLongitude.text = [NSString stringWithFormat:@"%.06f", owner.longitude.doubleValue];
    }
}

@end
