//
//  ASWhiteMapDetailsView.h
//  GpsPing
//
//  Created by Юджин Топсекретович on 9/28/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASModel.h"
#import "ASMapDetailsButton.h"

@interface ASTrackerDetailsView : UIView

@property (nonatomic) IBOutlet UILabel *labelTrackerName;
//@property (nonatomic) IBOutlet UILabel *labelOwnerName;
//@property (nonatomic) IBOutlet UIImageView *imaeViewOwnerIcon;

//@property (nonatomic) IBOutlet UILabel *labelTrackerNumber;
//@property (nonatomic) IBOutlet UILabel *labelImei;
@property (nonatomic) IBOutlet UILabel *labelLogTime;

//@property (nonatomic) IBOutlet UILabel *labelLatitude;
//@property (nonatomic) IBOutlet UILabel *labelLongitude;
@property (nonatomic) IBOutlet UILabel *labelGrsm;
@property (nonatomic) IBOutlet UILabel *labelDistance;
@property (nonatomic) IBOutlet UILabel *labelDistanceTravelled;
@property (nonatomic) IBOutlet UILabel *labelSpeed;


@property (nonatomic) IBOutlet UILabel *labelBatteryLevel;
@property (nonatomic) IBOutlet UIImageView *imageViewBattery;

@property (nonatomic) IBOutlet UIImageView *imageViewGSM;
@property (nonatomic) IBOutlet UIImageView *imageViewGPS;
@property (nonatomic) IBOutlet ASMapDetailsButton *btnMap;
@property (nonatomic) IBOutlet ASMapDetailsButton *btnEdit;
@property (nonatomic) IBOutlet UIImageView *profileImageView;
@property (nonatomic) IBOutlet UIButton *callBtn;

@property (nonatomic) IBOutlet UIView *separator1;
@property (nonatomic) IBOutlet UIView *separator2;
@property (nonatomic) IBOutlet UIView *separator3;

//@property (nonatomic) IBOutlet UILabel *labelPOILatitude;
//@property (nonatomic) IBOutlet UILabel *labelPOILongitude;
//@property (nonatomic) IBOutlet UILabel *labelPOIGrsm;

//@property (nonatomic) IBOutlet UIView *viewLeftColumn;
//@property (nonatomic) IBOutlet UIView *viewRightColumn;
//@property (nonatomic) IBOutlet UIView *viewPOILeftColumn;
//@property (nonatomic) IBOutlet UIView *viewPOIRightColumn;

-(void)configWithOwner:(ASFriendModel*)owner
               tracker:(ASDeviceModel*)deviceModel
                 point:(ASPointModel*)pointModel
                 color:(UIColor*)color;

@end
