//
//  ASAddFriendModel.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/29/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASAddFriendModel.h"
#import <extobjc.h>

@implementation ASAddFriendModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @keypath(ASAddFriendModel.new, userName)          : @"username",
              @keypath(ASAddFriendModel.new, userId)            : @"id",
              @keypath(ASAddFriendModel.new, displayName)       : @"displayname",
              @keypath(ASAddFriendModel.new, firstName)         : @"first_name",
              @keypath(ASAddFriendModel.new, lastName)          : @"last_name",
              @keypath(ASAddFriendModel.new, email)             : @"email"
              };
}

@end
