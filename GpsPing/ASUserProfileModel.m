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
                 @keypath(ASUserProfileModel.new, firstname):           @"user.firstname",
                 @keypath(ASUserProfileModel.new, lastname):            @"user.lastname",
                 @keypath(ASUserProfileModel.new, cookie):              @"cookie",
                 @keypath(ASUserProfileModel.new, cookieName):          @"cookie_name"
                 };
}

-(id)initWithCoder:(NSCoder *)coder{
    self = [super init];
    if (self) {
        self.username       = [coder decodeObjectForKey:@keypath(self, username)];
        self.email  = [coder decodeObjectForKey:@keypath(self, email)];
        self.firstname   = [coder decodeObjectForKey:@keypath(self, firstname)];
        self.lastname = [coder decodeObjectForKey:@keypath(self, lastname)];
        self.cookie   = [coder decodeObjectForKey:@keypath(self, cookie)];
        self.cookieName = [coder decodeObjectForKey:@keypath(self, cookieName)];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.username forKey:@keypath(self, username)];
    [coder encodeObject:self.email forKey:@keypath(self, email)];
    [coder encodeObject:self.firstname forKey:@keypath(self, firstname)];
    [coder encodeObject:self.lastname forKey:@keypath(self, lastname)];
    [coder encodeObject:self.cookie forKey:@keypath(self, cookie)];
    [coder encodeObject:self.cookieName forKey:@keypath(self, cookieName)];
}

+ (void)saveProfileInfoLocally:(ASUserProfileModel *)profile {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:profile];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:@"profile_info"];
    [defaults synchronize];
    
}

+ (ASUserProfileModel *)loadSavedProfileInfo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"profile_info"];
    ASUserProfileModel *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

+ (void)removeLocallyProfileInfo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"profile_info"];
    [defaults synchronize];
}

@end