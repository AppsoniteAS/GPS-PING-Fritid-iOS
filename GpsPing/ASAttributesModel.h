//
//  ASAttributesModel.h
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/27/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ASAttributesModel : MTLModel <MTLJSONSerializing>
@property (nonatomic        ) NSNumber  *battery;
@property (nonatomic        ) NSString  *ipAddress;
@property (nonatomic        ) NSNumber  *distance;
@property (nonatomic        ) NSNumber  *totalDistance;
@end
