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
#import "ASAttributesModel.h"
#import "ASLocationTrackingService.h"

@interface ASTrackerDetailsView()
@property (nonatomic) IBOutlet UILabel *labelLastSeenHeader;
@property (nonatomic) IBOutlet UILabel *labelGrsmHeader;
@property (nonatomic) IBOutlet UILabel *labelSpeedHeader;
@property (nonatomic) IBOutlet UILabel *labelDistanceHeader;
@property (nonatomic) IBOutlet UILabel *labelTravelledHeader;
@property (nonatomic) IBOutlet UILabel *labelSignalStrengthHeader;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@end;

@implementation ASTrackerDetailsView

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.btnMap setEnabled:true];
    [self.btnEdit setEnabled:true];
    self.profileImageView.layer.cornerRadius = 22.0;
    [self.profileImageView.layer setMasksToBounds:true];
    self.profileImageView.layer.borderWidth = 2;
    self.profileImageView.layer.borderColor = [UIColor colorWithRed:139/255.0 green:195/255.0 blue:74/255.0 alpha:1.0].CGColor;
    

   self.labelLastSeenHeader.text = NSLocalizedString(@"tracker_last_seen", nil);
  // self.labelGrsmHeader.text = NSLocalizedString(@"tracker_GRMS", nil);
   self.labelSpeedHeader.text = NSLocalizedString(@"tracker_speed", nil);
   self.labelDistanceHeader.text = NSLocalizedString(@"tracker_distance", nil);
   self.labelTravelledHeader.text = NSLocalizedString(@"tracker_distance_travelled", nil);
   self.labelSignalStrengthHeader.text = NSLocalizedString(@"tracker_signal_strength", nil);
    
    [self.btnMap setTitle:NSLocalizedString(@"tabbar_map", nil) forState:UIControlStateNormal];
    [self.btnMap setTitle:NSLocalizedString(@"tabbar_map", nil) forState:UIControlStateSelected];
    [self.btnEdit setTitle:NSLocalizedString(@"tracker_edit", nil) forState:UIControlStateNormal];
    [self.btnEdit setTitle:NSLocalizedString(@"tracker_edit", nil) forState:UIControlStateSelected];

    
    self.numberFormatter = [[NSNumberFormatter alloc]init];
    self.numberFormatter.locale = [NSLocale currentLocale];// this ensures the right separator behavior
    self.numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    [self.numberFormatter setUsesGroupingSeparator:NO];
}

-(void)configWithOwner:(ASFriendModel*)owner
               tracker:(ASDeviceModel*)deviceModel
                 point:(ASPointModel*)pointModel
                 color:(UIColor*)color
                trackerType:(NSString*)type{
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
    
    NSString* tracker = [type stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([tracker isEqualToString:kASTrackerTypeTkS1] || [tracker isEqualToString:kASTrackerTypeD79]){
        self.callBtn.enabled = YES;
        [self.callBtn setAlpha:1];
    }else{
        self.callBtn.enabled = NO;
        [self.callBtn setAlpha:0];
    }
    
    
    if (pointModel) {
        self.labelLogTime.text   = [dateFormatter stringFromDate:pointModel.timestamp];
        self.labelSpeed.text =  [self handleSpeed: pointModel.speed];
        self.labelDistance.text =  [self handleDistanceForLat:pointModel.latitude forLon:pointModel.longitude]; // [self handleDistance: pointModel.distance];
        self.labelDistanceTravelled.text = [self handleDistance:pointModel.totalDistance ];
       // [self handleSignalGPS:pointModel.gps andGPRS:pointModel.gsm];
        [self handleBattery:deviceModel.battery];
//        if (!pointModel.battery && pointModel.power){
//            [self handlePower:pointModel.power];
//        }
    } else {
        self.labelSpeed.text =  [self handleSpeed: deviceModel.speed];
        self.labelDistance.text = [self handleDistanceForLat:deviceModel.latitude forLon:deviceModel.longitude]; //[self handleDistance: deviceModel.distance];
        self.labelDistanceTravelled.text = [self handleDistance:deviceModel.totalDistance ];
        //[self handleSignalGPS:deviceModel.gps andGPRS:deviceModel.gsm];
        [self handleBattery:deviceModel.battery];
        
//        if (!deviceModel.battery && deviceModel.power){
//            [self handlePower:deviceModel.power];
//        }
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


- (void) handleBattery: (NSNumber*) battery{
    if (battery){
        NSInteger v = [battery integerValue];
        if (v > 10  && v <= 33){
            self.imageViewBattery.image = [UIImage imageNamed: @"battery-25"];
        } else if (v > 33  && v <= 66){
            self.imageViewBattery.image = [UIImage imageNamed: @"battery-50"];
        } else if (v > 66  && v <= 95){
            self.imageViewBattery.image = [UIImage imageNamed: @"battery-75"];
        } else if (v > 95  && v <= 100){
            self.imageViewBattery.image = [UIImage imageNamed: @"battery-100"];
        } else if (v >= 0 && v <= 10){
            self.imageViewBattery.image = [UIImage imageNamed: @"battery-0"];
        }
        self.labelBatteryLevel.text = [NSString stringWithFormat: @"%ld%%", (long)v];
    } else {
        self.imageViewBattery.image = [UIImage imageNamed: @"battery-0"];
        self.labelBatteryLevel.text = @"0%";
    }
}


- (void) handlePower: (NSNumber*) power{
    if (power){
        NSInteger v = [power integerValue];
        NSInteger s = 0;
        if (v == 1){
            self.imageViewBattery.image = [UIImage imageNamed: @"battery-25"];
            s = 25;
        } else if (v == 2 || v == 3){
            self.imageViewBattery.image = [UIImage imageNamed: @"battery-50"];
            s = 50;
        } else if (v == 4){
            self.imageViewBattery.image = [UIImage imageNamed: @"battery-75"];
            s = 75;
        } else if (v > 4){
            self.imageViewBattery.image = [UIImage imageNamed: @"battery-100"];
            s = 100;
        } else if (v== 0){
            self.imageViewBattery.image = [UIImage imageNamed: @"battery-0"];
            s = 0;
        }
        self.labelBatteryLevel.text = [NSString stringWithFormat: @"%ld%%", (long)s];
    } else {
        self.imageViewBattery.image = [UIImage imageNamed: @"battery-0"];
        self.labelBatteryLevel.text = @"0%";
    }
}

- (void) handleSignalGPS: (NSNumber*) gps  andGPRS: (NSNumber*) gsm{
    if (gps){
        NSInteger s = [gps integerValue];
        if (s >= 0 && s <= 5){
            self.imageViewGPS.image = [UIImage imageNamed: [NSString stringWithFormat: @"signal-%ld", (long) s]];
        }
    } else {
        self.imageViewGPS.image = [UIImage imageNamed: @"signal-0"];
    }
    
    if (gsm){
        NSInteger s = [gsm integerValue];
        if (s >= 0 && s <= 5){
            self.imageViewGSM.image = [UIImage imageNamed: [NSString stringWithFormat: @"signal-%ld", (long) s]];
        }
    } else {
        self.imageViewGSM.image = [UIImage imageNamed: @"signal-0"];
    }
    
}

- (NSString*) handleDistanceForLat: (NSNumber*) lat forLon: (NSNumber*)lon {
    if (!lat || !lon || !self.me){
        return [self handleDistance:nil];
    }
    
    CLLocation* target = [[CLLocation alloc] initWithLatitude:[lat floatValue] longitude:[lon floatValue]];
    CLLocationDistance distance = [self.me distanceFromLocation:target];
    return [self handleDistance:@(distance)];
}

- (NSString*) handleDistance: (NSNumber*) value{
    if (!value){
        return NSLocalizedString(@"No data", nil);
    }
    CGFloat v = [value floatValue];
    if (v < 1000){
        return [NSString stringWithFormat:@"%.02f m", v];
    } else {
        return [NSString stringWithFormat:@"%.02f km", v/1000.0];
    }
}

- (NSString*) handleSpeed: (NSNumber*) value{
    if (!value){
        return NSLocalizedString(@"No data", nil);
    }
    CGFloat v = [value floatValue];
    return [NSString stringWithFormat:@"%.02f km/h", v];

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
