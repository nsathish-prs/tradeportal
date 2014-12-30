//
//  DataModel.m
//  tradeportal
//
//  Created by Nagarajan Sathish on 21/10/14.
//
//

#import "DataModel.h"
#import <Parse/Parse.h>

@implementation DataModel

@synthesize userID,password,sessionID,fromView,toView,ip,domain,protocol,service,serviceURL,accountDict,accountList,notificationFlag,tabBarController;


-(void)resetService{
    ip = @"118.189.2.46";  //192.168.174.109 //
    domain =  @":10901"; //7010 //10901
    protocol = @"http";
    service = @"oms_portal/ws_rsOMS.asmx?";

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"TradePortal.plist"]; //3
    
    NSMutableDictionary *url = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    [url setObject:[NSString stringWithString:ip] forKey:@"ip"];
    [url setObject:[NSString stringWithString:domain] forKey:@"domain"];
    [url setObject:[NSString stringWithString:protocol] forKey:@"protocol"];
    [url setObject:[NSString stringWithString:service] forKey:@"service"];
    
    [url writeToFile: path atomically:YES];
}
@end
