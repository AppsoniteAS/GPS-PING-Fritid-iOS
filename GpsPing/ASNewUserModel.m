//
//  ASNewUserModel.m
//  GpsPing
//
//  Created by Pavel Ivanov on 18/07/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASNewUserModel.h"

@implementation ASNewUserModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{     @keypath(ASNewUserModel.new, username):   @"username",
                  @keypath(ASNewUserModel.new, password):   @"user_pass",
                  @keypath(ASNewUserModel.new, email):      @"email",
                  @keypath(ASNewUserModel.new, phoneCode):  @"Phone_pref",
                  @keypath(ASNewUserModel.new, phoneNumber):@"Phone_num",
                   
                  @keypath(ASNewUserModel.new, firstname):  @"first_name",
                  @keypath(ASNewUserModel.new, lastname):   @"last_name",
                  @keypath(ASNewUserModel.new, displayName):@"display_name",
                  @keypath(ASNewUserModel.new, nonce):      @"nonce",
                   
                  @keypath(ASNewUserModel.new, address):    @"m_address",
                  @keypath(ASNewUserModel.new, city):       @"m_city",
                  @keypath(ASNewUserModel.new, country):    @"m_country",
                  @keypath(ASNewUserModel.new, zipCode):    @"m_zipcode"
                  };
}

-(NSString *)firstname {
    return [self.fullName extractFirstName];
}

-(NSString *)lastname {
    return [self.fullName extractLastName];
}

@end
