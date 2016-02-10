//
//  ASMapDetailsView.m
//  GpsPing
//
//  Created by Pavel Ivanov on 29/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASMapDetailsView.h"
#import "UIImage+ASAnnotations.h"
#import "MGRS.h"

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
    }
    
    if (pointModel.longitude != 0 && pointModel.latitude != 0) {
        [self configCoordinateLabelsWithLatitude:pointModel.latitude.doubleValue
                                       longitude:pointModel.longitude.doubleValue];
    } else if (deviceModel.longitude != 0 && deviceModel.latitude != 0) {
        [self configCoordinateLabelsWithLatitude:deviceModel.latitude.doubleValue
                                       longitude:deviceModel.longitude.doubleValue];
    } else if (owner.longitude != 0 && owner.latitude != 0) {
        [self configCoordinateLabelsWithLatitude:owner.latitude.doubleValue
                                       longitude:owner.longitude.doubleValue];
    }
}

-(void)configCoordinateLabelsWithLatitude:(double)latitude
                                longitude:(double)longitude {
    
    self.labelLatitude.text  = [NSString stringWithFormat:@"%.06f", latitude];
    self.labelLongitude.text = [NSString stringWithFormat:@"%.06f", longitude];
    CLLocationCoordinate2D location;
    location.latitude = latitude;
    location.longitude = longitude;
    self.labelGrsm.text = [MGRS MGRSfromCoordinate:location];
}

@end
