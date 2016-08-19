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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle  = NSDateFormatterShortStyle;
    dateFormatter.timeStyle  = NSDateFormatterShortStyle;
    if (deviceModel) {
        self.labelTrackerNumber.text = deviceModel.trackerNumber;
        self.labelImei.text = deviceModel.imei;
        self.labelTrackerName.text = deviceModel.name;
        self.labelLogTime.text = [dateFormatter stringFromDate:deviceModel.lastDate];
    }
    
    if (pointModel) {
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
    self.viewLeftColumn.hidden = NO;
    self.viewRightColumn.hidden = NO;
    self.viewPOILeftColumn.hidden = YES;
    self.viewPOIRightColumn.hidden = YES;
}

-(void)configWithPOI:(ASPointOfInterestModel*)poi withOwner:(ASFriendModel*)owner color:(UIColor*)color {
    self.labelTrackerName.text = poi.name;
    self.labelOwnerName.text = [NSString stringWithFormat:@"%@ (%@)",owner.userName, owner.userId];
    self.imaeViewOwnerIcon.image = [UIImage getUserAnnotationImageWithColor:color];
    self.labelPOILatitude.text  = [NSString stringWithFormat:@"%.06f", poi.latitude.doubleValue];
    self.labelPOILongitude.text = [NSString stringWithFormat:@"%.06f", poi.longitude.doubleValue];
    CLLocationCoordinate2D location;
    location.latitude = poi.latitude.doubleValue;
    location.longitude = poi.longitude.doubleValue;
    self.labelPOIGrsm.text = [MGRS MGRSfromCoordinate:location];
    self.viewLeftColumn.hidden = YES;
    self.viewRightColumn.hidden = YES;
    self.viewPOILeftColumn.hidden = NO;
    self.viewPOIRightColumn.hidden = NO;
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
