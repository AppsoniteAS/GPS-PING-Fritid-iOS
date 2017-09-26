//
//  AGApiController.m
//  Gps Ping
//
//  Created by Pavel Ivanov on 02/07/15.
//  Copyright (c) 2015 Appgranula. All rights reserved.
//

#import "AGApiController.h"
#import "RACSignal+BackendHelpers.h"
#import "ASTrackerModel.h"
#import "ASPointOfInterestModel.h"
#import <Mantle.h>
#import "ASFriendModel.h"
#import "ASDeviceModel.h"
#import "ASAddFriendModel.h"
#import "AppDelegate.h"

#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelDebug;

#define BASE_URL_PRODUCTION @"https://fritid.gpsping.no/api"
//#define BASE_URL_LOCAL      @"http://appgranula.mooo.com/api/"
//#define BASE_URL_LOCAL      @"http://192.168.139.201/api/"
//#define BASE_URL_LOCAL      @"https://industri.gpsping.no/api/"
//#define BASE_URL_LOCAL @"http://54.77.4.166/api/"
#define BASE_URL_LOCAL @"https://fritid.gpsping.no/api"

#define requestMethod @"GET"

NSString* AGGpsPingBackendError                     = @"AGGpsPingBackendError";

NSInteger AGOpteumBackendResponseCodeSuccess       = 1;
NSInteger AGOpteumBackendResponseCodeNotAuthorized = -1;
NSInteger AGOpteumBackendResponseCodePhoneBlocked  = -4;

NSString *kASUserDefaultsKeyUsername = @"";
NSString *kASUserDefaultsKeyPassword = @"";
NSString *kASUserDefaultsKeyResetAll = @"reset_all";

NSString *kASDidLoginNotification    = @"kASDidLoginNotification";
NSString *kASDidLogoutNotification   = @"kASDidLogoutNotification";
NSString *kASDidRegisterNotification = @"kASDidRegisteredNotification";

@interface AGApiController()

@property (nonatomic, strong) id<AGApplicationConfigurationDelegate> configuration;
@property (strong, nonatomic) AFHTTPRequestOperationManager *httpRequestOperationManager;
@property (strong, nonatomic) AFNetworkReachabilityManager  *reachabilityManager;
@property (nonatomic, strong) NSUserDefaults *prefs;
@property (nonatomic, strong) NSDictionary *errorsDictionary;

@end

@implementation AGApiController

objection_register_singleton(AGApiController);
objection_initializer(initWithConfiguration:);

-(instancetype)initWithConfiguration:(id<AGApplicationConfigurationDelegate>)configuration {
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    self = [super init];

    if (self) {
        self.httpRequestOperationManager = [AFHTTPRequestOperationManager new];

        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        AFHTTPResponseSerializer *xmlSerializer  = [AFHTTPResponseSerializer serializer];
        xmlSerializer.acceptableContentTypes     = [NSSet setWithObjects:@"text/xml", nil];
        
        AFCompoundResponseSerializer *compoundSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, xmlSerializer]];
        
        self.httpRequestOperationManager.responseSerializer = compoundSerializer;
        
//        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//        [securityPolicy setValidatesDomainName:NO];
//        [securityPolicy setAllowInvalidCertificates:YES];
//        self.httpRequestOperationManager.securityPolicy = securityPolicy;
        
#ifdef AG_DEBUG_MODE
        self.baseUrl = [NSURL URLWithString:BASE_URL_LOCAL];
#else
        self.baseUrl = [NSURL URLWithString:BASE_URL_PRODUCTION];
#endif
        [self setupReachabilityManager];
    }
    
    return self;
}

- (void)setupReachabilityManager {
    self.reachabilityManager = [AFNetworkReachabilityManager managerForDomain:self.baseUrl.host];
    RAC(self, isReachableViaWWAN) = [[[RACObserve(self.reachabilityManager, networkReachabilityStatus)
                                map:^id(NSNumber* value) {
                                    return @(value.integerValue == AFNetworkReachabilityStatusReachableViaWWAN);
                                }] distinctUntilChanged] doNext:^(NSNumber* x) {
                                    DDLogVerbose(@"Backend reachability status via WWAN is: %@", x.boolValue ? @"YES": @"NO");
                                }];
    [self.reachabilityManager startMonitoring];
}

#pragma mark - Registration & Auth

-(RACSignal *)getNonce
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    return [self performHttpRequestWithAttempts:requestMethod resource:@"get_nonce" parameters:@{@"controller":@"user", @"method":@"register"}];
}

-(RACSignal *)registerUser:(ASNewUserModel*)newUser
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *newUserDictionary = [MTLJSONAdapter JSONDictionaryFromModel:newUser error:nil];
    return [[self performHttpRequestWithAttempts:requestMethod
                                       resource:@"user/register/"
                                     parameters:newUserDictionary] doNext:^(id x) {
        [[NSUserDefaults standardUserDefaults] setObject:newUser.username
                                                  forKey:kASUserDefaultsKeyUsername];
        [[NSUserDefaults standardUserDefaults] setObject:newUser.password
                                                  forKey:kASUserDefaultsKeyPassword];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

-(RACSignal *)authUser:(NSString*)userName password:(NSString*)password
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    @weakify(self)
    return [[[[[self performHttpRequestWithAttempts:requestMethod
                                          resource:@"user/generate_auth_cookie"
                                        parameters:@{@"username":userName,
                                                     @"password":password,
                                                     @"seconds":@"999999999"}] unpackObjectOfClass:[ASUserProfileModel class]] deliverOnMainThread] doNext:^(ASUserProfileModel* profile)
            {
                @strongify(self);
                self.userProfile = profile;
                [ASUserProfileModel saveProfileInfoLocally:profile];
            }] flattenMap:^RACStream *(id value) {
                ASUserProfileModel *profile = [ASUserProfileModel loadSavedProfileInfo];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *pushToken = [defaults objectForKey:kASUserDefaultsKeyPushToken];
                
                if (!profile.cookie || !pushToken) {
                    DDLogDebug(@"No push notification token found or cookie is missing; abort push registration");
                    return [RACSignal return:nil];
                }
                
                [[self registerForPushes] subscribeNext:^(id x) {
                    ;
                }];
                
                return [RACSignal return:value];
            }];
}

-(RACSignal *)logout {
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    self.userProfile = nil;

    [ASUserProfileModel removeLocallyProfileInfo];
    [ASTrackerModel clearTrackersInUserDefaults];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kASDidLogoutNotification object:nil];
    
    return [RACSignal empty];
}

-(RACSignal*)fetchProfile {
    return [[self performHttpRequestWithAttempts:requestMethod
                                        resource:@"user/get_user_meta/"
                                      parameters:@{@"cookie":self.userProfile.cookie
                                                   }] deliverOnMainThread];
}

-(RACSignal*)submitUserMetaData:(ASUserProfileModel *)profile {
    NSParameterAssert(profile);
    return [[[[[[[self performHttpRequestWithAttempts:requestMethod
                                             resource:@"user/update_user_meta/"
                                           parameters:@{@"cookie":profile.cookie,
                                                        @"meta_key":@"last_name",
                                                        @"meta_value":profile.lastname
                                                        }
                  ] flattenMap:^RACStream *(id x) {
        return [self performHttpRequestWithAttempts:requestMethod
                                           resource:@"user/update_user_meta/"
                                         parameters:@{@"cookie":profile.cookie,
                                                      @"meta_key":@"first_name",
                                                      @"meta_value":profile.firstname
                                                      }];
    }]  flattenMap:^RACStream *(id x) {
        return [self performHttpRequestWithAttempts:requestMethod
                                           resource:@"user/update_user_meta/"
                                         parameters:@{@"cookie":profile.cookie,
                                                      @"meta_key":@"m_address",
                                                      @"meta_value":profile.address
                                                      }];
    }]  flattenMap:^RACStream *(id x) {
        return [self performHttpRequestWithAttempts:requestMethod
                                           resource:@"user/update_user_meta/"
                                         parameters:@{@"cookie":profile.cookie,
                                                      @"meta_key":@"m_city",
                                                      @"meta_value":profile.city
                                                      }];
    }]  flattenMap:^RACStream *(id x) {
        return [self performHttpRequestWithAttempts:requestMethod
                                           resource:@"user/update_user_meta/"
                                         parameters:@{@"cookie":profile.cookie,
                                                      @"meta_key":@"m_country",
                                                      @"meta_value":profile.country
                                                      }];
    }]  flattenMap:^RACStream *(id x) {
        return [self performHttpRequestWithAttempts:requestMethod
                                           resource:@"user/update_user_meta/"
                                         parameters:@{@"cookie":profile.cookie,
                                                      @"meta_key":@"m_zipcode",
                                                      @"meta_value":profile.zipCode
                                                      }];
    }] deliverOnMainThread];
}

#pragma mark - Tracker

-(RACSignal *)bindTrackerImei:(NSString*)imei
                      number:(NSString*)number
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *params = @{
                             @"imei":imei,
                             @"lastdig":number
                             };
    params = [self addAuthParamsByUpdatingParams:params];
    return [self performHttpRequestWithAttempts:requestMethod
                                       resource:@"tracker/bind_tracker"
                                     parameters:params];
}

-(RACSignal *)bindTrackerImei:(NSString*)imei
                       number:(NSString*)number
                         type:(NSString*) type
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *params = @{
                             @"imei":imei,
                             @"lastdig":number,
                             @"type": type
                             };
    params = [self addAuthParamsByUpdatingParams:params];
    return [self performHttpRequestWithAttempts:requestMethod
                                       resource:@"tracker/bind_tracker"
                                     parameters:params];
}

-(RACSignal *)getTrackers
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    return [[self performHttpRequestWithAttempts:requestMethod
                                       resource:@"tracker/get_trackers"
                                     parameters:[self addAuthParamsByUpdatingParams:@{}]] flattenMap:^RACStream *(id value) {
        DDLogDebug(@"%@", value);
        NSError *error;
        NSArray *trackersArray = [MTLJSONAdapter modelsOfClass:[ASTrackerModel class] fromJSONArray:value[@"trackers"] error:&error];
        return [RACSignal return:trackersArray];
    }];
}

-(RACSignal *)updateTracker:(NSString*)name
                  trackerId:(NSString*)trackerId
                 repeatTime:(CGFloat)repeatTime
              checkForStand:(BOOL)checkForStand
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSString *checkForStandString;
    if (checkForStand) {
        checkForStandString = @"true";
    } else {
        checkForStandString = @"false";
    }
    NSDictionary *params = @{@"name":name,
                             @"imei_number":trackerId,
                             @"reciver_signal_repeat_time":@(repeatTime),
                             @"check_for_stand":checkForStandString};
    params = [self addAuthParamsByUpdatingParams:params];
    return [self performHttpRequestWithAttempts:requestMethod
                                       resource:@"tracker/update_tracker"
                                     parameters:params];
}

-(RACSignal *)removeTrackerByImei:(NSString*)imei
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    return [self performHttpRequestWithAttempts:requestMethod
                                       resource:@"tracker/remove_tracker"
                                     parameters:[self addAuthParamsByUpdatingParams:@{@"imei_number":imei}]];
}

#pragma mark - POI
-(RACSignal *)getPOI
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    return [[self performHttpRequestWithAttempts:requestMethod
                                        resource:@"poi/get/"
                                      parameters:[self addAuthParamsByUpdatingParams:@{}]] flattenMap:^RACStream *(id value) {
        DDLogDebug(@"%@", value);
        NSError *error;
        NSArray* arrayJSON = value[@"poi"];
        NSArray *poisArray = [MTLJSONAdapter modelsOfClass:[ASPointOfInterestModel class] fromJSONArray:arrayJSON error:&error];
        return [RACSignal return:poisArray];
    }];
}

-(RACSignal *)addPOI:(NSString*)name
            latitude:(CGFloat)latitude
           longitude:(CGFloat)longitude
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *params = @{@"name":name,
                             @"lat":@(latitude),
                             @"lon":@(longitude)};
    params = [self addAuthParamsByUpdatingParams:params];
    return [self performHttpRequestWithAttempts:requestMethod
                                       resource:@"poi/add"
                                     parameters:params];
}

-(RACSignal *)updatePOI:(NSString*)name
                     id:(NSInteger)identificator
               latitude:(CGFloat)latitude
              longitude:(CGFloat)longitude
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *params = @{@"name":name,
                             @"id":@(identificator),
                             @"lat":@(latitude),
                             @"lon":@(longitude)};
    params = [self addAuthParamsByUpdatingParams:params];
    return [self performHttpRequestWithAttempts:requestMethod
                                       resource:@"poi/update"
                                     parameters:params];
}

-(RACSignal *)removePOIWithId:(NSUInteger)identificator
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    return [self performHttpRequestWithAttempts:requestMethod
                                       resource:@"poi/remove"
                                     parameters:[self addAuthParamsByUpdatingParams:@{@"id":@(identificator)}]];
}

#pragma mark - Friends

-(RACSignal *)getFriends
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *params = [self addAuthParamsByUpdatingParams:@{}];
    return [[self performHttpRequestWithAttempts:requestMethod
                                       resource:@"friends/get"
                                     parameters:params] map:^id(NSDictionary *value) {
        NSArray *friendsJSON = value[@"friends"];
        NSError *error;
        NSArray *friendsArray = [MTLJSONAdapter modelsOfClass:[ASFriendModel class]
                                                fromJSONArray:friendsJSON
                                                        error:&error];
        NSArray *requestsJSON = value[@"requests"];
        NSArray *requestsArray = [MTLJSONAdapter modelsOfClass:[ASAddFriendModel class]
                                                fromJSONArray:requestsJSON
                                                        error:&error];
        NSMutableArray *array = [NSMutableArray arrayWithArray: friendsArray];
        [array addObjectsFromArray: requestsArray];
        return array;
    }];
}

-(RACSignal *)addFriendWithId:(NSString*)friendId
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *params = @{@"id":friendId};
    params = [self addAuthParamsByUpdatingParams:params];
    return [self performHttpRequestWithAttempts:requestMethod
                                       resource:@"friends/add"
                                     parameters:params];
}

-(RACSignal *)removeFriendWithId:(NSString*)friendId
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *params = @{@"id":friendId};
    params = [self addAuthParamsByUpdatingParams:params];
    return [self performHttpRequestWithAttempts:requestMethod
                                       resource:@"friends/remove"
                                     parameters:params];
}

-(RACSignal *)searchFriendWithQueryString:(NSString*)queryString
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *params = @{@"q":queryString};
    params = [self addAuthParamsByUpdatingParams:params];
    return [[self performHttpRequestWithAttempts:requestMethod
                                       resource:@"friends/search"
                                     parameters:params] map:^id(NSDictionary *value) {
        NSArray *usersJSON = value[@"users"];
        NSError *error;
        NSArray *usersArray = [MTLJSONAdapter modelsOfClass:[ASAddFriendModel class]
                                              fromJSONArray:usersJSON
                                                      error:&error];
        return usersArray;
    }];

    
}

-(RACSignal *)setSeeingTracker:(BOOL)isSeeing friendId:(NSString*)friendId
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *params = @{@"id"                 :friendId,
                             @"is_seeing_trackers" :isSeeing?@"true":@"false"};
    params = [self addAuthParamsByUpdatingParams:params];
    return [self performHttpRequestWithAttempts:requestMethod
                                       resource:@"friends/set_seeing_trackers"
                                     parameters:params];
}

-(RACSignal *)confirmFriendshipWithFriendId:(NSString*)friendId
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *params = @{@"id":friendId};
    params = [self addAuthParamsByUpdatingParams:params];
    return [self performHttpRequestWithAttempts:requestMethod
                                       resource:@"friends/confirm"
                                     parameters:params];
}

-(RACSignal *)declineFriendshipWithFriendId:(NSString*)friendId
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *params = @{@"id":friendId};
    params = [self addAuthParamsByUpdatingParams:params];
    return [self performHttpRequestWithAttempts:requestMethod
                                       resource:@"friends/confirm"
                                     parameters:params];
}

#pragma mark - Tracking

-(RACSignal *)getTrackingPointsFrom:(NSDate*)from
                                 to:(NSDate*)to
                           friendId:(NSNumber*)friendId
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *params = @{@"from":@(from.timeIntervalSince1970),
                             @"to":@(to.timeIntervalSince1970)};
    ///
//    friendId = @(8042);
    ///
    
    if (friendId) {
        params = [params mtl_dictionaryByAddingEntriesFromDictionary:@{@"id":friendId}];
    }
    
    params = [self addAuthParamsByUpdatingParams:params];
    return [[self performHttpRequestWithAttempts:requestMethod
                                       resource:@"tracker/get_points"
                                     parameters:params] map:^id(id value) {
        DDLogVerbose(@"%@", value);
        NSMutableArray *resultArray = @[].mutableCopy;
        for (NSDictionary *userDictionary in value[@"users"]) {
            NSError *error;
            NSArray *devicesArray = [MTLJSONAdapter modelsOfClass:[ASDeviceModel class]
                                                    fromJSONArray:userDictionary[@"devices"]
                                                            error:&error];
            
            ASFriendModel *friendModel = [MTLJSONAdapter modelOfClass:[ASFriendModel class]
                                                   fromJSONDictionary:userDictionary[@"user"]
                                                                error:&error];
            friendModel.devices = devicesArray;
            [resultArray addObject:friendModel];
        }
        
//        NSError *error;
//        NSArray *resultArray = [MTLJSONAdapter modelsOfClass:[ASFriendModel class] fromJSONArray:value[@"users"] error:&error];
        return resultArray;
    }];
}

-(RACSignal *)sendUserPosition:(CLLocationCoordinate2D)coordinate {
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *params = @{@"lat":@(coordinate.latitude),
                             @"lon":@(coordinate.longitude)};
    params = [self addAuthParamsByUpdatingParams:params];
    return [self performHttpRequestWithAttempts:@"GET"
                                       resource:@"tracker/add_position/"
                                     parameters:params];
}

#pragma mark - Pushes

-(RACSignal *)registerForPushes
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSString *uid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *pushToken = [defaults objectForKey:kASUserDefaultsKeyPushToken];
    NSString *cookie = [ASUserProfileModel loadSavedProfileInfo].cookie;
    if (cookie && uid && pushToken) {
        NSDictionary *params = @{@"cookie":cookie,
                                 @"uuid":uid,
                                 @"push_id":pushToken
                                 };
        params = [self addAuthParamsByUpdatingParams:params];
        return [self performHttpRequestWithAttempts:requestMethod
                                           resource:@"friends/register_gcm"
                                         parameters:params];
    } else {
        NSString* message = [NSString stringWithFormat:@"Bad push regist registration params: cookie = %@, uuid = %@, push_id = %@", cookie, uid, pushToken];
        DDLogError(@"%@", message);
        return [RACSignal error:[NSError buildError:^(MRErrorBuilder *builder) {
            builder.localizedDescription = message;
        }]];
    }
}

#pragma mark - Private methods

-(NSDictionary *)addAuthParamsByUpdatingParams:(NSDictionary*)params
{
    return [params mtl_dictionaryByAddingEntriesFromDictionary:@{@"cookie":self.userProfile.cookie}];
}

-(RACSignal*)performHttpRequestWithAttempts:(NSString*)method resource:(NSString*)resource parameters:(NSDictionary*)params
{
    return [self _performEndurantHttpRequest:method resource:resource parameters:params tries:3];
}

-(RACSignal*)performHttpRequest:(NSString*)method resource:(NSString*)resource parameters:(NSDictionary*)params
{
    return [self _performEndurantHttpRequest:method resource:resource parameters:params tries:-1];
}

-(RACSignal*)_performEndurantHttpRequest:(NSString*)method resource:(NSString*)resource parameters:(NSDictionary*)params tries:(NSInteger) tries
{
    RACSignal* signal = [self _performHttpRequest:method
                                         resource:resource
                                       parameters:params];
    if (tries >= 0) {
        signal = [signal retry:tries];
    }
    
    return [signal flattenMap:^RACStream *(id response) {
        DDLogDebug(@"!! %@ %@", NSStringFromClass([response class]), response);
        if ([response isKindOfClass:[NSDictionary class]] && [response[@"status"] isEqualToString:@"error"]) {
            NSError *error = [NSError buildError:^(MRErrorBuilder *builder) {
                 builder.domain = AGGpsPingBackendError;
                 builder.localizedDescription = response[@"error"];
             }];
            if (([response[@"code"] integerValue] == 5) || ([response[@"code"] integerValue] == 211)) {
                [self logout];
            }

             return [RACSignal error:error];
        }
        
        return [RACSignal return:response];
//         if (code && ![code isEqualToNumber:@(AGOpteumBackendResponseCodeSuccess)]) {
//             NSError *error = [NSError buildError:^(MRErrorBuilder *builder) {
//                 builder.domain = AGOpteumBackendError;
//                 builder.code   = code.integerValue;
//                 builder.localizedDescription =
//                    response[@"m"] ?: [self getErrorDescriptionForCode:code];
//             }];
//
//             return [RACSignal error:error];
//         }
    }];
}

-(RACSignal*)_performHttpRequest:(NSString*)method resource:(NSString*)resource parameters:(NSDictionary*)params
{
    DDLogDebug(@"%s, resource: %@", __PRETTY_FUNCTION__, resource);
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        NSError *error;
        
        NSString* apiServer       = self.baseUrl.absoluteString;
        NSURLComponents* url      = [NSURLComponents componentsWithString:apiServer];
        url.path = [url.path stringByAppendingPathComponent:resource];
        AFHTTPRequestOperationManager* manager = self.httpRequestOperationManager;
        
        NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:method
                                                                          URLString:url.URL.absoluteString
                                                                         parameters:params
                                                                              error:&error];
        
        DDLogDebug(@"API request: %@", request);
        DDLogVerbose(@"API request params: %@", params);
        AFHTTPRequestOperation* operation =
        [manager HTTPRequestOperationWithRequest:request
                                         success:^(AFHTTPRequestOperation *operation, id response)
         {
             DDLogVerbose(@"API response: %@", response);
             [subscriber sendNext:response];
             [subscriber sendCompleted];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             DDLogError(@"AFHTTPRequestOperation failure, error: %@", error);
             DDLogDebug(@"API response: %@", operation.response);
             [subscriber sendError:error];
         }];
        
        [operation start];
        
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }];
}

@end
