//
//  ASMapDetailsView.h
//  GpsPing
//
//  Created by Pavel Ivanov on 29/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASModel.h"

@interface ASMapDetailsView : UIView

@property (nonatomic) IBOutlet UILabel *labelTrackerName;
@property (nonatomic) IBOutlet UILabel *labelOwnerName;
@property (nonatomic) IBOutlet UIImageView *imaeViewOwnerIcon;

@property (nonatomic) IBOutlet UILabel *labelTrackerNumber;
@property (nonatomic) IBOutlet UILabel *labelImei;
@property (nonatomic) IBOutlet UILabel *labelLogTime;

@property (nonatomic) IBOutlet UILabel *labelLatitude;
@property (nonatomic) IBOutlet UILabel *labelLongitude;
@property (nonatomic) IBOutlet UILabel *labelGrsm;

@property (nonatomic) IBOutlet UILabel *labelPOILatitude;
@property (nonatomic) IBOutlet UILabel *labelPOILongitude;
@property (nonatomic) IBOutlet UILabel *labelPOIGrsm;

@property (nonatomic) IBOutlet UIView *viewLeftColumn;
@property (nonatomic) IBOutlet UIView *viewRightColumn;
@property (nonatomic) IBOutlet UIView *viewPOILeftColumn;
@property (nonatomic) IBOutlet UIView *viewPOIRightColumn;

-(void)configWithOwner:(ASFriendModel*)owner
               tracker:(ASDeviceModel*)deviceModel
                 point:(ASPointModel*)pointModel
                 color:(UIColor*)color;
-(void)configWithPOI:(ASPointOfInterestModel*)poi withOwner:(ASFriendModel*)owner;

@end
