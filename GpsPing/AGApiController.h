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
#import "ASNewUserModel.h"
#import "ASTrackerModel.h"
extern NSString* AGGpsPingBackendError;

extern NSString *kASUserDefaultsKeyUsername;
extern NSString *kASUserDefaultsKeyPassword;

extern NSString *kASDidLoginNotification;
extern NSString *kASDidLogoutNotification;
extern NSString *kASDidRegisterNotification;
extern NSString *kASUserDefaultsKeyResetAll;
@protocol AGApplicationConfigurationDelegate

@property (readonly) NSString* backendBaseURL;

@end

@interface AGApiController : NSObject
@property (readonly) BOOL isReachableViaWWAN;
@property (nonatomic, strong) ASUserProfileModel *userProfile;
@property (nonatomic, strong) NSURL *baseUrl;

#pragma mark - Auth

-(RACSignal *)getNonce;

-(RACSignal *)registerUser:(ASNewUserModel*)newUser;

-(RACSignal *)authUser:(NSString*)userName password:(NSString*)password;
-(RACSignal *)logout;
-(RACSignal*)submitUserMetaData:(ASUserProfileModel *)profile;
-(RACSignal*)fetchProfile;

#pragma mark - Tracker
-(RACSignal *)bindTrackerImei:(NSString*)imei
                       number:(NSString*)number;
-(RACSignal *)bindTrackerImei:(NSString*)imei
                       number:(NSString*)number
                         type:(NSString*) type;
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
#pragma mark - Tracking
-(RACSignal *)getTrackingPointsFrom:(NSDate*)from
                                 to:(NSDate*)to
                           friendId:(NSNumber*)friendId;
-(RACSignal *)getTrackingPointsFrom:(NSDate*)from
                                 to:(NSDate*)to
                           friendId:(NSNumber*)friendId
                                for: (ASTrackerModel*) trackerModel;
-(RACSignal *)sendUserPosition:(CLLocationCoordinate2D)coordinate;

#pragma mark - POI
-(RACSignal *)getPOI;
-(RACSignal *)addPOI:(NSString*)name
            latitude:(CGFloat)latitude
           longitude:(CGFloat)longitude;
-(RACSignal *)updatePOI:(NSString*)name
                     id:(NSInteger)identificator
               latitude:(CGFloat)latitude
              longitude:(CGFloat)longitude;
-(RACSignal *)removePOIWithId:(NSUInteger)identificator;

#pragma mark - Pushes

-(RACSignal *)registerForPushes;

@end
