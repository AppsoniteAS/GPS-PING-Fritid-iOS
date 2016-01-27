//
//  ASFriendModel.h
//  GpsPing
//
//  Created by Pavel Ivanov on 27/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ASFriendModel : MTLModel<MTLJSONSerializing>

@property (nonatomic) NSNumber *userId;
@property (nonatomic) NSString *userName;
@property (nonatomic) NSString *displayName;
@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *secondName;
@property (nonatomic) NSString *email;
@property (nonatomic) NSNumber *isSeeingTracker;
@property (nonatomic) NSNumber *confirmationStatus;

@property (nonatomic) NSString *fullName;

@end
