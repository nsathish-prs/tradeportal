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

@implementation AppDelegate

@synthesize window = _window,timer,conn,parser,parseURL,buffer;
DataModel *dm;
BOOL resultFound;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dm = [[DataModel alloc]init];
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"applicationWillResignActive");
    self.window.hidden = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(reset) userInfo:nil repeats:NO];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)reset{
    dm.sessionID=@"";
    //dm.userID=@"";
    dm.password=@"";
    self.window.rootViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil]instantiateInitialViewController];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSString *soapRequest = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                             "<soap:Body>"
                             "<ChkSession xmlns=\"http://OMS/\">"
                             "<UserSession>%@</UserSession>"
                             "</ChkSession>"
                             "</soap:Body>"
                             "</soap:Envelope>", dm.sessionID];
    //NSLog(@"SoapRequest is %@" , soapRequest);
    NSURL *url =[NSURL URLWithString:@"http://192.168.174.109/oms/ws_rsoms.asmx?op=ChkSession"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://OMS/ChkSession" forHTTPHeaderField:@"SOAPAction"];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapRequest length]];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapRequest dataUsingEncoding:NSUTF8StringEncoding]];
    
    conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (conn) {
        buffer = [NSMutableData data];
    }
    
}

-(void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *) response {
    [buffer setLength:0];
}
-(void) connection:(NSURLConnection *) connection didReceiveData:(NSData *) data {
    [buffer appendData:data];
}
-(void) connection:(NSURLConnection *) connection didFailWithError:(NSError *) error {
    
}

-(void) connectionDidFinishLoading:(NSURLConnection *) connection {
    //NSLog(@"\n\nDone with bytes %lu", (unsigned long)[buffer length]);
    NSMutableString *theXML =
    [[NSMutableString alloc] initWithBytes:[buffer mutableBytes]
                                    length:[buffer length]
                                  encoding:NSUTF8StringEncoding];
    [theXML replaceOccurrencesOfString:@"&lt;"
                            withString:@"<" options:0
                                 range:NSMakeRange(0, [theXML length])];
    [theXML replaceOccurrencesOfString:@"&gt;"
                            withString:@">" options:0
                                 range:NSMakeRange(0, [theXML length])];
    NSLog(@"\n\nSoap Response is %@",theXML);
    [buffer setData:[theXML dataUsingEncoding:NSUTF8StringEncoding]];
    self.parser =[[NSXMLParser alloc]initWithData:buffer];
    [parser setDelegate:self];
    [parser parse];
}

-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict {
    
    if([elementName isEqualToString:@"ChkSessionResult"]){
        resultFound=NO;
    }
    
    
}

- (void) parser:(NSXMLParser *) parser foundCharacters:(NSString *) string {
    NSString *msg;
    BOOL flag=FALSE;
    if(!resultFound){
        if([[string substringToIndex:1] isEqualToString:@"R"]){
            //NSLog(@"R error");
            msg = @"Some Technical Error...\nPlease Try again...";
            flag=TRUE;
        }
        else if([[string substringToIndex:1] isEqualToString:@"E"]){
            //NSLog(@"E error");
            msg = @"User has logged on elsewhere!";
            flag=TRUE;
        }
        if (flag) {
            [self reset];
            UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [toast show];
            int duration = 1.5;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
            
        }
        resultFound=YES;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive\n%lu",(unsigned long)[dm.userID length]);
    self.window.hidden = NO;
    [timer invalidate];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    if ([dm.userID length]>0) {
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"User Authentication" message:@"Enter Password" delegate:self cancelButtonTitle:@"Enter" otherButtonTitles:@"Exit", nil];
//        alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
//        [alertView textFieldAtIndex:0].text = dm.userID;
//        [alertView textFieldAtIndex:0].userInteractionEnabled = NO;
//        [alertView textFieldAtIndex:1].placeholder = @"Password";
//        alertView.tag = 0;
//        [[alertView textFieldAtIndex:1] becomeFirstResponder];
//        [alertView show];
//    }
    
    
    
}

//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    NSLog(@"%ld\t%li",(long)alertView.tag,(long)buttonIndex);
//    if (alertView.tag == 0) {
//        if (buttonIndex == 0) {
//            if (!([[alertView textFieldAtIndex:0].text isEqualToString:dm.userID]
//                  &&[[alertView textFieldAtIndex:1].text isEqualToString:dm.password])) {
//                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"User Authentication" message:@"Password Incorrect\nRe-Enter Correct Password" delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Exit", nil];
//                alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
//                [alertView textFieldAtIndex:0].text = dm.userID;
//                [alertView textFieldAtIndex:0].userInteractionEnabled = NO;
//                [alertView textFieldAtIndex:1].placeholder = @"Password";
//                [[alertView textFieldAtIndex:1] becomeFirstResponder];
//                alertView.tag = 0;
//                [alertView show];
//            }
//        }
//        else{
//            exit(0);
//        }
//    }
//}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"applicationWillTerminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
