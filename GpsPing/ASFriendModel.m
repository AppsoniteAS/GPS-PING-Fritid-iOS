//
//  ASFriendModel.m
//  GpsPing
//
//  Created by Pavel Ivanov on 27/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASFriendModel.h"
#import "ASDeviceModel.h"

#import <extobjc.h>
#import <CocoaLumberjack.h>
static DDLogLevel ddLogLevel               = DDLogLevelDebug;

NSString* const kASFriendUserId           = @"id";
NSString* const kASFriendFirstName        = @"first_name";
NSString* const kASFriendSecondName       = @"last_name";
NSString* const kASFriendUsername         = @"username";
NSString* const kASFriendDisplayName      = @"displayname";
NSString* const kASFriendEmail            = @"email";
NSString* const kASFriendConfirmed        = @"confirmed";
NSString* const kASFriendIsSeeingTrackers = @"is_seeing_trackers";

NSString* const kASFriendLongitude  = @"lon";
NSString* const kASFriendLatitude   = @"lat";
NSString* const kASFriendDevices = @"devices";

@implementation ASFriendModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @keypath(ASFriendModel.new, userName) : kASFriendUsername,
            @keypath(ASFriendModel.new, userId) : kASFriendUserId,
            @keypath(ASFriendModel.new, displayName) : kASFriendDisplayName,
            @keypath(ASFriendModel.new, firstName) : kASFriendFirstName,
            @keypath(ASFriendModel.new, secondName) : kASFriendSecondName,
            @keypath(ASFriendModel.new, email)             : kASFriendEmail,
            @keypath(ASFriendModel.new, isSeeingTracker) : kASFriendIsSeeingTrackers,
            @keypath(ASFriendModel.new, confirmationStatus) : kASFriendConfirmed,
            @keypath(ASFriendModel.new, devices) : kASFriendDevices,
            @keypath(ASFriendModel.new, latitude) : kASFriendLatitude,
            @keypath(ASFriendModel.new, longitude) : kASFriendLongitude,
            };
}

+ (NSValueTransformer *)devicesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[ASDeviceModel class]];
}

@end
