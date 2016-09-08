//
//  ASUserProfileModel.h
//  GpsPing
//
//  Created by Maks Niagolov on 1/24/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"

extern NSString *kASUserDefaultsDidShowIntro;

@interface ASUserProfileModel : MTLModel<MTLJSONSerializing>

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *email;

@property (strong, nonatomic) NSString *phoneCode;
@property (strong, nonatomic) NSString *phoneNumber;

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *zipCode;

@property (strong, nonatomic) NSString *firstname;
@property (strong, nonatomic) NSString *lastname;
@property (strong, nonatomic) NSString *cookie;
@property (strong, nonatomic) NSString *cookieName;

+ (void)saveProfileInfoLocally:(ASUserProfileModel *)profile;
+ (ASUserProfileModel *)loadSavedProfileInfo;
+ (void)removeLocallyProfileInfo;

@end