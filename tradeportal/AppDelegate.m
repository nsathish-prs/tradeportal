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

@implementation AppDelegate

@synthesize window = _window,timer,conn,parser,parseURL,buffer,url,hostReachability,internetReachability,wifiReachability,privacyScreen;
DataModel *dm;
BOOL resultFound;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dm = [[DataModel alloc]init];
    
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
    //    NSLog(@"%@",dm.serviceURL);
    
    return YES;
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
    self.window.rootViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil]instantiateInitialViewController];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    }

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //    NSLog(@"applicationDidBecomeActive\n%lu",(unsigned long)[dm.userID length]);
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
