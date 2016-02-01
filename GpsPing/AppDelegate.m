//
//  AppDelegate.m
//  GpsPing
//
//  Created by Pavel Ivanov on 18/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "AppDelegate.h"
#import <UIAlertView+ErrorKit.h>
#import <CocoaLumberjack.h>
#import <CoreLocation/CoreLocation.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <SVProgressHUD.h>
#import <Objection/Objection.h>

#import <CrashlyticsLogger.h>

DDLogLevel ddLogLevel = DDLogLevelError;

@interface AppDelegate ()
@property(nonatomic, strong) void (^registrationHandler)
(NSString *registrationToken, NSError *error);
@property(nonatomic, strong) NSString* registrationToken;

@end

@implementation AppDelegate

-(instancetype)init {
    self = [super init];
    if (self) {
        [self initializeLogginig];
        [self initializeDependencyInjection];

    }
    return self;
}

-(void)initializeLogginig {
    setenv("XcodeColors", "YES", 0);
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[CrashlyticsLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    DDLogDebug(@"Logging initialized");
}

- (void)initializeDependencyInjection {
    JSObjectionInjector* injector = [JSObjection createInjector];
    [JSObjection setDefaultInjector:injector];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _registrationKey = @"onRegistrationCompleted";
    _messageKey = @"onMessageReceived";
    // Override point for customization after application launch.
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.5451 green:0.7647 blue:0.2902 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:
        @{
            NSForegroundColorAttributeName: [UIColor whiteColor],
            NSFontAttributeName: [UIFont fontWithName:@"Roboto-Regular" size:20.0f]
        }];
    [self setDefaultTrackDuration];
    
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    _gcmSenderID = [[[GGLContext sharedInstance] configuration] gcmSenderID];

    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:notificationSettings];
        [application registerForRemoteNotifications];
    } else {
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeSound|
         UIRemoteNotificationTypeAlert];
    }
    
    GCMConfig *gcmConfig = [GCMConfig defaultConfig];
    gcmConfig.receiverDelegate = self;
    [[GCMService sharedInstance] startWithConfig:gcmConfig];
    // [END start_gcm_service]
    __weak typeof(self) weakSelf = self;
    // Handler for registration token request
    _registrationHandler = ^(NSString *registrationToken, NSError *error){
        if (registrationToken != nil) {
            weakSelf.registrationToken = registrationToken;
            NSLog(@"Registration Token: %@", registrationToken);
//            [weakSelf subscribeToTopic];
            NSDictionary *userInfo = @{@"registrationToken":registrationToken};
            [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                                object:nil
                                                              userInfo:userInfo];
        } else {
            NSLog(@"Registration to GCM failed with error: %@", error.localizedDescription);
            NSDictionary *userInfo = @{@"error":error.localizedDescription};
            [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                                object:nil
                                                              userInfo:userInfo];
        }
    };

    return YES;
}

-(void)setDefaultTrackDuration {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"tracking_duration"];
    NSString *duration = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    
    if (!duration) {
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:@"15 minutes"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:encodedObject forKey:@"tracking_duration"];
        [defaults synchronize];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    [self registerNotificationToken:deviceToken];
    //    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    //    [notificationCenter postNotificationName:kAGPushNotificationRegistred object:nil userInfo:nil];
    NSString *uid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
    GGLInstanceIDConfig *instanceIDConfig = [GGLInstanceIDConfig defaultConfig];
    instanceIDConfig.delegate = self;
    // Start the GGLInstanceID shared instance with the that config and request a registration
    // token to enable reception of notifications
    [[GGLInstanceID sharedInstance] startWithConfig:instanceIDConfig];
    _registrationOptions = @{kGGLInstanceIDRegisterAPNSOption:deviceToken,
                             kGGLInstanceIDAPNSServerTypeSandboxOption:@YES};
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:_gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:_registrationOptions
                                                      handler:_registrationHandler];
}

//- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
//    DDLogError(@"Error in registration for push. Error: %@", err);
////    [[[CustomAlertView alloc] initWithTitle:@"Ошибка при регистрации для нотификаций" error:err] show];
//    //    self.apiController.deviceTokenForPush = nil;
//    //    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//    //    [notificationCenter postNotificationName:kAGPushNotificationFailedToRegister object:nil userInfo:nil];
//}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Registration for remote notification failed with error: %@", error.localizedDescription);
    // [END receive_apns_token_error]
    NSDictionary *userInfo = @{@"error" :error.localizedDescription};
    [[NSNotificationCenter defaultCenter] postNotificationName:_registrationKey
                                                        object:nil
                                                      userInfo:userInfo];
}

// [START ack_message_reception]
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Notification received: %@", userInfo);
    // This works only if the app started the GCM service
    [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
    // Handle the received message
    // [START_EXCLUDE]
    [[NSNotificationCenter defaultCenter] postNotificationName:_messageKey
                                                        object:nil
                                                      userInfo:userInfo];
    // [END_EXCLUDE]
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    NSLog(@"Notification received: %@", userInfo);
    // This works only if the app started the GCM service
    [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
    // Handle the received message
    // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
    // [START_EXCLUDE]
    [[NSNotificationCenter defaultCenter] postNotificationName:_messageKey
                                                        object:nil
                                                      userInfo:userInfo];
    handler(UIBackgroundFetchResultNoData);
    // [END_EXCLUDE]
}

-(void) registerNotificationToken: (NSData *) deviceToken {
//    NSString* tokenString = [deviceToken.description stringByReplacingOccurrencesOfString:@" " withString:@""];
//    tokenString = [tokenString stringByReplacingOccurrencesOfString:@"<" withString:@""];
//    tokenString = [tokenString stringByReplacingOccurrencesOfString:@">" withString:@""];
    
//    self.apiController.deviceTokenForPush = tokenString;
//    [[self.apiController setNewPushId:tokenString] subscribeNext:^(id x) {
//        DDLogDebug(@"Push notificaiton setted up. Token = %@", tokenString);
//    } error:^(NSError *error) {
//        DDLogError(@"Cannot set push notificaiton token. Error: %@", error);
//    }];
}


@end
