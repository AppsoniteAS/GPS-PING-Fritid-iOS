//
//  ASNewUserModel.h
//  GpsPing
//
//  Created by Pavel Ivanov on 18/07/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <ReactiveCocoa.h>
#import "NSString+ASNameComponents.h"

@interface ASNewUserModel : MTLModel<MTLJSONSerializing>
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

@property (strong, nonatomic) NSString *email;

@property (strong, nonatomic) NSString *phoneCode;
@property (strong, nonatomic) NSString *phoneNumber;

@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *firstname;
@property (strong, nonatomic) NSString *lastname;
@property (strong, nonatomic) NSString *nonce;
@property (strong, nonatomic) NSString *displayName;

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *zipCode;

@end
