//
//  ASAddFriendModel.h
//  GpsPing
//
//  Created by Maks Niagolov on 1/29/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface ASAddFriendModel : MTLModel<MTLJSONSerializing>

@property (nonatomic) NSNumber *userId;
@property (nonatomic) NSString *userName;
@property (nonatomic) NSString *displayName;
@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *email;

@end
