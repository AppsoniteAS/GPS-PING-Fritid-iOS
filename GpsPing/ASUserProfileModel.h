//
//  ASUserProfileModel.h
//  GpsPing
//
//  Created by Maks Niagolov on 1/24/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"

@interface ASUserProfileModel : MTLModel<MTLJSONSerializing>

@property (strong, nonatomic) NSString   *username;
@property (strong, nonatomic) NSString   *email;
@property (strong, nonatomic) NSString   *firstname;
@property (strong, nonatomic) NSString   *lastname;
@property (strong, nonatomic) NSString   *cookie;
@property (strong, nonatomic) NSString   *cookieName;

+ (void)saveProfileInfoLocally:(ASUserProfileModel *)profile;
+ (ASUserProfileModel *)loadSavedProfileInfo;
+ (void)removeLocallyProfileInfo;

@end