//
//  ASPOIDetailsView.h
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/1/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASModel.h"

@interface ASPOIDetailsView : UIView
-(void)configWithPOI:(ASPointOfInterestModel*)poi
           withOwner:(ASFriendModel*)owner
               color:(UIColor*)color;
@end
