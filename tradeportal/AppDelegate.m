//
//  AppDelegate.m
//  tradeportal
//
//  Created by Nagarajan Sathish on 8/10/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "OrderBookViewController.h"
#import "DataModel.h"
#import "Reachability.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <Parse/Parse.h>

@implementation AppDelegate{
    UIViewController *rootView;
}

@synthesize window = _window,timer,conn,parser,parseURL,buffer,url,hostReachability,internetReachability,wifiReachability,privacyScreen;
DataModel *dm;
BOOL resultFound;
PFInstallation *currentInstallation;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dm = [[DataModel alloc]init];
    
    //Push
    
    [Parse setApplicationId:@"HU0qn8GzJtEcd8yG3jAIJladASf26G4XyG7HdGQ9"
                  clientKey:@"VnTO5C3p5p1NPMIZlmN1N72qCw6rl3jR9SzmHMbL"];
    
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    // Network
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Change the host name here to change the server you want to monitor.
    NSString *remoteHostName = @"www.google.com";
    
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    // URL
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"TradePortal.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"TradePortal" ofType:@"plist"]; //5
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
    
    url = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    BOOL oldIP= [url objectForKey:@"ip"]!=nil;
    if (!oldIP) {
        [dm resetService];
        url = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    }
    //load from savedStock example int value
    dm.serviceURL = [NSString stringWithFormat:@"%@://%@%@/%@",[url objectForKey:@"protocol"],[url objectForKey:@"ip"],[url objectForKey:@"domain"],[url objectForKey:@"service"]];
//        NSLog(@"%@",dm.serviceURL);
    
    rootView = self.window.rootViewController;
    
//    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder" message:notification.alertBody delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
    }
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[@""];
    [currentInstallation saveInBackground];
//    NSLog(@"%@",currentInstallation);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    self.window.hidden = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(reset) userInfo:nil repeats:NO];
    [application ignoreSnapshotOnNextApplicationLaunch];
}

- (void)reset{
    UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:@"Session Expired..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [toast show];
    int duration = 1.5;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toast dismissWithClickedButtonIndex:0 animated:YES];
    });
    dm.sessionID=@"";
    //dm.userID=@"";
    dm.password=@"";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil]instantiateInitialViewController];
    }
    else{
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil]instantiateInitialViewController];
    }
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
        application.applicationIconBadgeNumber = 0;
    currentInstallation.badge = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    self.window.hidden = NO;
    [timer invalidate];
}

- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}


- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    NSString *msg;
    
    
    switch (netStatus)
    {
        case NotReachable:        {
            msg = @"No Network Access";
            UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [toast show];
            int duration = 1.5;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
            
            //            NSLog(@"No Access");
            break;
        }
            
        case ReachableViaWWAN:        {
            //            NSLog(@"Reachable WWAN");
            break;
        }
        case ReachableViaWiFi:        {
            
            //            NSLog(@"Reachable WIFI");
            msg = [NSString stringWithFormat:@"Connected to %@",[self fetchSSIDInfo]];
            UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [toast show];
            int duration = 1.5;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
            break;
        }
    }
    
    
}

- (id)fetchSSIDInfo
{
    NSArray *ifs = (__bridge NSArray *)(CNCopySupportedInterfaces());
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        //        NSLog(@"%@",[info objectForKey:@"SSID"]);
    }
    return [info objectForKey:@"SSID"];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
