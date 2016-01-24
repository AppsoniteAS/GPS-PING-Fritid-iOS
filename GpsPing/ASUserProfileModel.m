//
//  ASUserProfileModel.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/24/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASUserProfileModel.h"
#import <CocoaLumberjack.h>
#import <ReactiveCocoa.h>

@implementation ASUserProfileModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{    @keypath(ASUserProfileModel.new, username):            @"user.username",
                 @keypath(ASUserProfileModel.new, email):               @"user.email",
                 @keypath(ASUserProfileModel.new, idNumber):            @"user.id",
                 @keypath(ASUserProfileModel.new, firstname):           @"user.firstname",
                 @keypath(ASUserProfileModel.new, lastname):            @"user.lastname"
                 };
}

@end