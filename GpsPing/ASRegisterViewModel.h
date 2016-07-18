//
//  ASRegisterViewModel.h
//  GpsPing
//
//  Created by Maks Niagolov on 1/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

@interface ASRegisterViewModel : NSObject

@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* email;

@property (strong, nonatomic) NSString* phoneCode;
@property (strong, nonatomic) NSString* phoneNumber;

@property (strong, nonatomic) NSString* fullName;

@property (strong, nonatomic) NSString* address;
@property (strong, nonatomic) NSString* city;
@property (strong, nonatomic) NSString* country;
@property (strong, nonatomic) NSString* zipCode;

@property (strong, nonatomic) NSString* password;
@property (strong, nonatomic) NSString* confirmPassword;

@property (readonly, nonatomic) RACCommand* submit;

@end
