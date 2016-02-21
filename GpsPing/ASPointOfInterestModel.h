//
//  ASPointOfInterestModel.h
//  GpsPing
//
//  Created by Maks Niagolov on 2/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ASPointOfInterestModel : MTLModel<MTLJSONSerializing>
@property (nonatomic) NSNumber  *longitude;
@property (nonatomic) NSNumber  *latitude;
@property (nonatomic) NSString  *name;
@property (nonatomic) NSNumber  *identificator;
@property (nonatomic) NSNumber  *userId;
@end
