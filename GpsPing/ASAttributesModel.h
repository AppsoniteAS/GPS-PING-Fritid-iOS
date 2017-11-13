//
//  ASAttributesModel.h
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/27/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ASAttributesModel : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong        ) NSNumber  *  battery;
@property (nonatomic , strong        ) NSString  *ipAddress;
@property (nonatomic , strong        ) NSNumber  *distance;
@property (nonatomic , strong        ) NSNumber  *totalDistance;
//@property (nonatomic , strong        ) NSNumber  *power;
//@property (nonatomic , strong        ) NSNumber  *ignition;
@end
