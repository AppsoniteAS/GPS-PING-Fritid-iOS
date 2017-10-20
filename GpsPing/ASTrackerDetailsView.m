//
//  ASWhiteMapDetailsView.m
//  GpsPing
//
//  Created by Юджин Топсекретович on 9/28/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import "ASTrackerDetailsView.h"
#import "UIImage+ASAnnotations.h"
#import "MGRS.h"
#import <YYWebImage.h>
#import "ASS3Manager.h"

@implementation ASTrackerDetailsView

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.btnMap setEnabled:true];
    [self.btnEdit setEnabled:true];
    self.profileImageView.layer.cornerRadius = 22.0;
    [self.profileImageView.layer setMasksToBounds:true];
    self.profileImageView.layer.borderWidth = 2;
    self.profileImageView.layer.borderColor = [UIColor colorWithRed:139/255.0 green:195/255.0 blue:74/255.0 alpha:1.0].CGColor;
}

-(void)configWithOwner:(ASFriendModel*)owner
               tracker:(ASDeviceModel*)deviceModel
                 point:(ASPointModel*)pointModel
                 color:(UIColor*)color {
    if (owner && !deviceModel && !pointModel){
        self.labelTrackerName.text = owner.userName;
        self.profileImageView.image = [UIImage getUserAnnotationImageWithColor:color];
    }
    
   // self.labelOwnerName.text = owner.userName;
  //  self.imaeViewOwnerIcon.image = [UIImage getUserAnnotationImageWithColor:color];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle  = NSDateFormatterShortStyle;
    dateFormatter.timeStyle  = NSDateFormatterShortStyle;
    if (deviceModel) {
        [self.widthImage setConstant:44];
        [self layoutIfNeeded];
        //self.labelTrackerNumber.text = deviceModel.trackerNumber;
       // self.labelImei.text = deviceModel.imei;
        self.labelTrackerName.text = deviceModel.name;
        self.labelLogTime.text = [dateFormatter stringFromDate:deviceModel.lastDate];
        if (deviceModel.imageId){
            [self.profileImageView yy_setImageWithURL:[ [ASS3Manager sharedInstance] getURLByImageIdentifier: deviceModel.imageId ]placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                if (from == YYWebImageFromDiskCache) {
                }
            }];
        } else{
            [self.widthImage setConstant:0];
            [self layoutIfNeeded];
        }
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

    
    
}




-(void)configCoordinateLabelsWithLatitude:(double)latitude
                                longitude:(double)longitude {
    
   // self.labelLatitude.text  = [NSString stringWithFormat:@"%.06f", latitude];
   // self.labelLongitude.text = [NSString stringWithFormat:@"%.06f", longitude];
    CLLocationCoordinate2D location;
    location.latitude = latitude;
    location.longitude = longitude;
    self.labelGrsm.text = [MGRS MGRSfromCoordinate:location];
}

@end
