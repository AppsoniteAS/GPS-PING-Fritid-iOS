//
//  AGApiController.m
//  Taxi-Rhytm
//
//  Created by Pavel Ivanov on 02/07/15.
//  Copyright (c) 2015 Appgranula. All rights reserved.
//

#import "AGApiController.h"
#import "RACSignal+BackendHelpers.h"
#import "ASTrackerModel.h"
#import <Mantle.h>
#import <Underscore.h>

#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

#define BASE_URL_PRODUCTION @"http://109.120.158.225/"
//#define BASE_URL_LOCAL      @"http://appgranula.mooo.com/api/"
#define BASE_URL_LOCAL      @"http://192.168.139.201/api/"

NSString* AGOpteumBackendError                     = @"AGOpteumBackendError";
NSString* AGRhythmMobileError                      = @"AGRhythmMobileError";

NSInteger AGRhythmMobileErrorOrderAlreadyExists    = 101;

NSInteger AGOpteumBackendResponseCodeSuccess       = 1;
NSInteger AGOpteumBackendResponseCodeNotAuthorized = -1;
NSInteger AGOpteumBackendResponseCodePhoneBlocked  = -4;

NSString *kASUserDefaultsKeyUsername = @"";
NSString *kASUserDefaultsKeyPassword = @"";

#define XML_URL  @"passport.xml"
#define XML_URL2 @"driverlicense.xml"
#define XML_URL3 @"sts.xml"

//#define XML_DROPBOX_1 @"https://dl.dropboxusercontent.com/u/36183426/CantharisTemplates/driverlicense.xml"
//#define XML_DROPBOX_2 @"https://dl.dropboxusercontent.com/u/36183426/CantharisTemplates/passport.xml"
//#define XML_DROPBOX_3 @"https://dl.dropboxusercontent.com/u/36183426/CantharisTemplates/sts.xml"

@interface AGApiController()

@property (nonatomic, strong) id<AGApplicationConfigurationDelegate> configuration;
@property (strong, nonatomic) AFHTTPRequestOperationManager *httpRequestOperationManager;
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
        
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
        AFHTTPResponseSerializer *xmlSerializer = [AFHTTPResponseSerializer serializer];
        xmlSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", nil];
        
        AFCompoundResponseSerializer *compoundSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, xmlSerializer]];
        
        self.httpRequestOperationManager.responseSerializer = compoundSerializer;
        
#ifdef AG_DEBUG_MODE
        self.baseUrl = [NSURL URLWithString:BASE_URL_LOCAL];
#else
        self.baseUrl = [NSURL URLWithString:BASE_URL_PRODUCTION];
#endif
    }
    
    return self;
}

-(RACSignal *)getNonce
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    return [self performHttpRequestWithAttempts:@"GET" resource:@"get_nonce" parameters:@{@"controller":@"user", @"method":@"register"}];
}

-(RACSignal *)registerUser:(NSString*)userName email:(NSString*)email password:(NSString*)password nonce:(NSString*)nonce
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    return [[self performHttpRequestWithAttempts:@"GET"
                                       resource:@"user/register/"
                                     parameters:@{@"username":userName,
                                                  @"user_pass":password,
                                                  @"email":email,
                                                  @"display_name":userName,
                                                  @"nonce":nonce,
                                                  @"first_name":@"",
                                                  @"last_name":@""
                                                  }] doNext:^(id x) {
        [[NSUserDefaults standardUserDefaults] setObject:userName
                                                  forKey:kASUserDefaultsKeyUsername];
        [[NSUserDefaults standardUserDefaults] setObject:password
                                                  forKey:kASUserDefaultsKeyPassword];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

-(RACSignal *)authUser:(NSString*)userName password:(NSString*)password
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    @weakify(self)
    return [[[[self performHttpRequestWithAttempts:@"GET" resource:@"user/generate_auth_cookie" parameters:@{@"username":userName, @"password":password, @"seconds":@"999999999"
}] unpackObjectOfClass:[ASUserProfileModel class]] deliverOnMainThread] doNext:^(ASUserProfileModel* profile)
            {
                @strongify(self);
                self.userProfile = profile;
                [ASUserProfileModel saveProfileInfoLocally:profile];
            }];
}

-(RACSignal *)logout {
    self.userProfile = nil;
    [ASUserProfileModel removeLocallyProfileInfo];
    return [RACSignal empty];
}

-(RACSignal*)submitProfile:(ASUserProfileModel *)profile {
    NSParameterAssert(profile);
    
    NSError* error;
    NSDictionary *params = [MTLJSONAdapter JSONDictionaryFromModel:profile
                                                             error:&error];
    params = Underscore.dict(params)
    .rejectValues(Underscore.isNull)
    .rejectValues(^BOOL (id object) {
        return ([object isKindOfClass:[NSString class]] ? [object length] == 0 : NO);
    })
    .unwrap;
    if (error) {
        DDLogError(@"%@", error);
        return [RACSignal error:error];
    }
    
    return [[self performHttpRequestWithAttempts:@"PUT"
                                       resource:@"user/update_user_meta/"
                                     parameters:params] deliverOnMainThread];
}

#pragma mark - Tracker

-(RACSignal *)addTracker:(NSString*)name
                    imei:(NSString*)imei
                  number:(NSString*)number
              repeatTime:(CGFloat)repeatTime
                    type:(NSString*)type
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
                             @"imei_number":imei,
                             @"tracker_number":number,
                             @"reciver_signal_repeat_time":@(repeatTime),
                             @"check_for_stand":checkForStandString,
                             @"type":type};
    params = [self addAuthParamsByUpdatingParams:params];
    return [self performHttpRequestWithAttempts:@"GET"
                                       resource:@"tracker/add_tracker"
                                     parameters:params];
}

-(RACSignal *)getTrackers
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    return [[self performHttpRequestWithAttempts:@"GET"
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
    return [self performHttpRequestWithAttempts:@"GET"
                                       resource:@"tracker/update_tracker"
                                     parameters:params];
}

-(RACSignal *)removeTrackerByImei:(NSString*)imei
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    return [self performHttpRequestWithAttempts:@"GET"
                                       resource:@"tracker/remove_tracker"
                                     parameters:[self addAuthParamsByUpdatingParams:@{@"imei_number":imei}]];
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
