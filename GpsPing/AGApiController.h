//
//  AGApiController.h
//  GpsPing
//
//  Created by Pavel Ivanov on 02/07/15.
//  Copyright (c) 2015 Appgranula. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ErrorKit/ErrorKit.h>
#import <AFNetworking/AFNetworking.h>
#import "ReactiveCocoa.h"
#import <Objection/Objection.h>
#import <extobjc.h>
#import "ASUserProfileModel.h"

extern NSString* AGOpteumBackendError;
extern NSString* AGRhythmMobileError;

extern NSInteger AGRhythmMobileErrorOrderAlreadyExists;

extern NSInteger AGOpteumBackendResponseCodeSuccess;
extern NSInteger AGOpteumBackendResponseCodeNotAuthorized;
extern NSInteger AGOpteumBackendResponseCodePhoneBlocked;

extern NSString *kASUserDefaultsKeyUsername;
extern NSString *kASUserDefaultsKeyPassword;

@protocol AGApplicationConfigurationDelegate

@property (readonly) NSString* backendBaseURL;

@end

@interface AGApiController : NSObject

@property (nonatomic, strong) ASUserProfileModel *userProfile;
@property (nonatomic, strong) NSURL *baseUrl;

#pragma mark - Auth

-(RACSignal *)getNonce;
-(RACSignal *)registerUser:(NSString*)userName email:(NSString*)email password:(NSString*)password nonce:(NSString*)nonce;
-(RACSignal *)authUser:(NSString*)userName password:(NSString*)password;
-(RACSignal *)logout;
-(RACSignal*)submitUserMetaData:(ASUserProfileModel *)profile;
-(RACSignal*)fetchProfile;

#pragma mark - Tracker
-(RACSignal *)addTracker:(NSString*)name
                    imei:(NSString*)imei 
                  number:(NSString*)number
              repeatTime:(CGFloat)repeatTime
                    type:(NSString*)type
           checkForStand:(BOOL)checkForStand;
-(RACSignal *)getTrackers;
-(RACSignal *)updateTracker:(NSString*)name
                  trackerId:(NSString*)trackerId
                 repeatTime:(CGFloat)repeatTime
              checkForStand:(BOOL)checkForStand;
-(RACSignal *)removeTrackerByImei:(NSString*)imei;
#pragma mark - Friends
-(RACSignal *)getFriends;
-(RACSignal *)addFriendWithId:(NSString*)friendId;
-(RACSignal *)removeFriendWithId:(NSString*)friendId;
-(RACSignal *)searchFriendWithQueryString:(NSString*)queryString;
-(RACSignal *)setSeeingTracker:(BOOL)isSeeing friendId:(NSString*)friendId;
-(RACSignal *)confirmFriendshipWithFriendId:(NSString*)friendId;
-(RACSignal *)declineFriendshipWithFriendId:(NSString*)friendId;

@end
