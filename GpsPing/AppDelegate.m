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
    // Override point for customization after application launch.
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.5451 green:0.7647 blue:0.2902 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:
        @{
            NSForegroundColorAttributeName: [UIColor whiteColor],
            NSFontAttributeName: [UIFont fontWithName:@"Roboto-Regular" size:20.0f]
        }];
    [self setDefaultTrackDuration];
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

@end
