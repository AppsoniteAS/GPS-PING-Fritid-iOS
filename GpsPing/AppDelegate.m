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
#import <SVProgressHUD.h>
#import <Objection/Objection.h>
#import "ASGeofenceViewController.h"
#import "ASDisplayOptionsViewController.h"
#import "UIStoryboard+ASHelper.h"
#import "ASFriendsListViewController.h"

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
        _registrationKey = @"onRegistrationCompleted";
        _messageKey = @"onMessageReceived";
        [self initializeLogginig];
        [self initializeDependencyInjection];
    }
    return self;
}

-(void)initializeLogginig {
    setenv("XcodeColors", "YES", 0);
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    DDLogDebug(@"Logging initialized");
}

- (void)initializeDependencyInjection {
    JSObjectionInjector* injector = [JSObjection createInjector];
    [JSObjection setDefaultInjector:injector];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configUI];
    [self initUserDefaults];
    [self configPushes:application];
//    NSDictionary *userInfo = [launchOptions valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
//    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
//    
//    if(apsInfo) {
//        [self handlePush];
//    }
    
    for (NSString *fontFamilyName in [UIFont familyNames]) {
        for (NSString *fontName in [UIFont fontNamesForFamilyName:fontFamilyName]) {
            NSLog(@"Family: %@    Font: %@", fontFamilyName, fontName);
        }
    }
    
    return YES;
}

-(void)configUI {
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.5451 green:0.7647 blue:0.2902 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{
       NSForegroundColorAttributeName: [UIColor whiteColor],
       NSFontAttributeName: [UIFont fontWithName:@"Roboto-Regular" size:20.0f]
       }];
}

-(void)configPushes:(UIApplication*)application {
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
//        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert];
    }
    
    GCMConfig *gcmConfig = [GCMConfig defaultConfig];
    gcmConfig.receiverDelegate = (id)self;
    [[GCMService sharedInstance] startWithConfig:gcmConfig];
    // [END start_gcm_service]
    __weak typeof(self) weakSelf = self;
    // Handler for registration token request
    _registrationHandler = ^(NSString *registrationToken, NSError *error){
        if (registrationToken != nil) {
            weakSelf.registrationToken = registrationToken;
            DDLogDebug(@"Registration Token: %@", registrationToken);
            //            [weakSelf subscribeToTopic];
            NSDictionary *userInfo = @{@"registrationToken":registrationToken};
            [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                                object:nil
                                                              userInfo:userInfo];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:registrationToken forKey:kASUserDefaultsKeyPushToken];
            [defaults synchronize];

        } else {
            DDLogDebug(@"Registration to GCM failed with error: %@", error.localizedDescription);
            NSDictionary *userInfo = @{@"error":error.localizedDescription};
            [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                                object:nil
                                                              userInfo:userInfo];
        }
    };
}

-(void)initUserDefaults {
    [self setDefaultTrackDuration];
}

-(void)setDefaultTrackDuration {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *duration = [defaults objectForKey:kTrackingDurationKey];
    
    if (!duration) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@(10) forKey:kTrackingDurationKey];
        [defaults synchronize];
    }
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    [self registerNotificationToken:deviceToken];
    //    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    //    [notificationCenter postNotificationName:kAGPushNotificationRegistred object:nil userInfo:nil];
    // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
    GGLInstanceIDConfig *instanceIDConfig = [GGLInstanceIDConfig defaultConfig];
    instanceIDConfig.delegate = (id)self;
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
    if ( application.applicationState != UIApplicationStateActive ) {
        [self handlePush];
    }
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

-(void)handlePush {
    ASFriendsListViewController* pvc = [[UIStoryboard connectStoryboard] instantiateInitialViewController];
    UINavigationController *navVC = [[UINavigationController alloc]initWithRootViewController:pvc];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeFriends)];
    pvc.navigationItem.leftBarButtonItem = item;
    [self.window.rootViewController presentViewController:navVC animated:YES completion:NULL];
}

-(void)closeFriends {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
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
