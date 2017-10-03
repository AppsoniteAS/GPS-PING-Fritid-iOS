//
//  ASPOIDetailsView.m
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/1/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import "ASPOIDetailsView.h"
#import "UIImage+ASAnnotations.h"
#import "MGRS.h"

@implementation ASPOIDetailsView

-(void)configWithPOI:(ASPointOfInterestModel*)poi
           withOwner:(ASFriendModel*)owner
               color:(UIColor*)color{
    self.labelTrackerName.text = poi.name;
    self.labelOwnerName.text = [NSString stringWithFormat:@"%@ (%@)",owner.userName, owner.userId];
    self.imaeViewOwnerIcon.image = [UIImage getUserAnnotationImageWithColor:color];
    self.labelPOILatitude.text  = [NSString stringWithFormat:@"%.06f", poi.latitude.doubleValue];
    self.labelPOILongitude.text = [NSString stringWithFormat:@"%.06f", poi.longitude.doubleValue];
    CLLocationCoordinate2D location;
    location.latitude = poi.latitude.doubleValue;
    location.longitude = poi.longitude.doubleValue;
    self.labelPOIGrsm.text = [MGRS MGRSfromCoordinate:location];

    self.viewPOILeftColumn.hidden = NO;
    self.viewPOIRightColumn.hidden = NO;
}
@end
