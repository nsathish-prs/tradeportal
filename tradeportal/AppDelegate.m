//
//  AppDelegate.m
//  tradeportal
//
//  Created by Nagarajan Sathish on 8/10/14.
//  Copyright (c) 2014 IFIS Asia Pte Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "OrderBookViewController.h"
#import "DataModel.h"
#import "Reachability.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <Parse/Parse.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation AppDelegate{
    UIViewController *rootView;
}

@synthesize window = _window,timer,conn,parser,parseURL,buffer,url,hostReachability,internetReachability,wifiReachability,privacyScreen;
DataModel *dm;
BOOL resultFound;
UITabBarController *tabbar;
UIImageView *imageView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dm = [[DataModel alloc]init];
    [Parse setApplicationId:@"2mVs11lyRGq8ysIeCsMUGu9NQNyfZih9kkcNEOQQ"
                  clientKey:@"uwwZohVdr9XUBu7fWad3s6U6gYxyGXbEAFAytJiK"];
    
    
    //Device List
    dm.deviceDict = [[NSMutableDictionary alloc]init];
    
    PFQuery *query1 = [PFQuery queryWithClassName:@"DeviceList"];
    NSArray *objects = [query1 findObjects];
    for (PFObject *object in objects) {
        [dm.deviceDict setObject:object.objectId forKey:[NSString stringWithFormat:@"%@",object[@"TR_Code"]]];
    }
    
    
    
    //Notification
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    
    // Network     //Change the host name here to change the server you want to monitor.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
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
    //    NSLog(@"%@",dm.serviceURL);
    rootView = self.window.rootViewController;
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    dm.currentInstallation = [PFInstallation currentInstallation];
    [dm.currentInstallation setDeviceTokenFromData:deviceToken];
    dm.currentInstallation.channels = @[ @"" ];
    [dm.currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    //    NSLog(@"%@",userInfo);
    if ([userInfo objectForKey:@"id"]) {
        [[userInfo objectForKey:@"id"]intValue];
    }
    if ([userInfo objectForKey:@"aps"]) {
        //        NSString *msg = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        //        UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        //        [toast show];
        //        int duration = 1.5;
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //            [toast dismissWithClickedButtonIndex:0 animated:YES];
        //        });
    }
    if ([[userInfo objectForKey:@"id"]intValue]==1){
        //    NSLog(@"SelectedIndex: %lu",(unsigned long)((UITabBarController*)dm.tabBarController).selectedIndex);
        tabbar = (UITabBarController*)((UITabBarController*)dm.tabBarController).selectedViewController;
        //    NSLog(@"Tabbar: %@",tabbar.viewControllers[0]);
        if (((UITabBarController*)dm.tabBarController).selectedIndex != 1) {
            [[[[[tabbar tabBarController]tabBar]items]objectAtIndex:1]setBadgeValue:[NSString stringWithFormat:@"%d", [[[[[[tabbar tabBarController]tabBar]items]objectAtIndex:1]badgeValue]intValue]+1]];
        }
        else{
            [tabbar.viewControllers[0] reloadTableData];
        }
    }
    //    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    self.window.hidden = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(reset) userInfo:nil repeats:NO];
    [application ignoreSnapshotOnNextApplicationLaunch];
    imageView = [[UIImageView alloc]initWithFrame:[self.window frame]];
    [imageView setImage:[UIImage imageNamed:@"IFIS_Logo_2014_new_launch"]];
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] lastObject];
    [mainWindow addSubview:imageView];
    [[[[[tabbar tabBarController]tabBar]items]objectAtIndex:1]setBadgeValue:NULL];
    
    application.applicationIconBadgeNumber = 0;
    dm.currentInstallation.badge=0;
    [dm.currentInstallation saveInBackground];
    //    [self.window addSubview:imageView];
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
    if (!application.applicationIconBadgeNumber == 0) {
        [[[[[tabbar tabBarController]tabBar]items]objectAtIndex:1]setBadgeValue:[NSString stringWithFormat:@"%ld",(long)application.applicationIconBadgeNumber]];
    }
    application.applicationIconBadgeNumber = 0;
    dm.currentInstallation.badge=0;
    [dm.currentInstallation saveInBackground];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //    NSLog(@"applicationDidBecomeActive\n%lu",(unsigned long)[dm.userID length]);
    if(imageView != nil) {
        [imageView removeFromSuperview];
        imageView = nil;
    }
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
    //    NSLog(@"%d",netStatus);
    switch (netStatus)
    {
        case NotReachable:
        {
            msg = @"No Network";
            UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [toast show];
            int duration = 1.5;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
            dm.wifi = @"No Network";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
            //            NSLog(@"No Access");
            break;
        }
            
        case ReachableViaWWAN:        {
            //                        NSLog(@"Reachable WWAN");
            CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
            CTCarrier *carrier = [netinfo subscriberCellularProvider];
            //            NSLog(@"Carrier Name: %@", [carrier carrierName]);
            dm.wifi = [carrier carrierName];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
            break;
        }
        case ReachableViaWiFi:        {
            
            //            NSLog(@"Reachable WIFI");
            dm.wifi = [[NSString alloc]init];
            dm.wifi = [self fetchSSIDInfo];
            msg = [NSString stringWithFormat:@"Connected to %@",dm.wifi];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
            
            //            UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            //            [toast show];
            //            int duration = 1.5;
            //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //                [toast dismissWithClickedButtonIndex:0 animated:YES];
            //            });
            break;
        }
    }
}

- (id)fetchSSIDInfo
{
    NSArray *ifs = (__bridge NSArray *)(CNCopySupportedInterfaces());
    id info = nil;
    BOOL flag=false;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        //        NSLog(@"%@",[info objectForKey:@"SSID"]);
        flag=true;
    }
    if (flag) {
        return [info objectForKey:@"SSID"];
    } else {
        return @"SIM";
    }
    
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
