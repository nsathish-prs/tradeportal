//
//  LoginViewController.m
//  tradeportal
//
//  Created by Nagarajan Sathish on 8/10/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "DataModel.h"
#import "ChangeServiceViewController.h"


@interface LoginViewController (){
    NSURLConnection *conn;
    BOOL dataFound;
    BOOL resultFound;
    
    NSString *name;
    NSString *password;
    NSString *sessionID;
}


@end

@implementation LoginViewController

DataModel *dm;
@synthesize uname1,upwd,buffer,parser,conn,error,spinner1,parseURL;

#pragma mark - View Delegates

- (void)viewDidLoad
{
    [super viewDidLoad];
    dm.accountList = [[NSMutableArray alloc]init];
    dm.accountDict = [[NSMutableDictionary alloc]init];
    

}

-(void)viewWillAppear:(BOOL)animated{
    self.view.alpha = 1.0f;
    [super viewWillAppear:animated];
    
}

#pragma mark - TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [uname1 resignFirstResponder];
    [upwd resignFirstResponder];
    return YES;
}

#pragma mark - Invoke Login Service

-(IBAction)login:(id)sender{
    name = uname1.text;
    password = upwd.text;
    dm.userID = name;
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyz$-~#@ABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:30];
    for (NSUInteger i = 0U; i < 30; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    sessionID = s;
    //NSLog(@"%@",sessionID);
    BOOL flag=TRUE;
    if([name isEqualToString:@""]){
        uname1.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Enter Username" attributes:@{NSForegroundColorAttributeName: iERROR}];
        flag=FALSE;
    }
    if([password isEqualToString:@""]){
        upwd.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Enter Password" attributes:@{NSForegroundColorAttributeName: iERROR}];
        
        flag = FALSE;
    }
    if(flag){
        parseURL = @"login";
        
        NSString *soapRequest = [NSString stringWithFormat:
                                 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                 "<soap:Body>"
                                 "<AuthenticateUser xmlns=\"http://OMS/\">"
                                 "<strUserID>%@</strUserID>"
                                 "<strPwd>%@</strPwd>"
                                 "<strUserSession>%@</strUserSession>"
                                 "</AuthenticateUser>"
                                 "</soap:Body>"
                                 "</soap:Envelope>", name,password,sessionID];
        //        NSLog(@"\nSoapRequest is %@" , soapRequest);
        NSString *urls = [NSString stringWithFormat:@"%@%s",dm.serviceURL,"op=AuthenticateUser"];
        NSURL *url =[NSURL URLWithString:urls];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://OMS/AuthenticateUser" forHTTPHeaderField:@"SOAPAction"];
        NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapRequest length]];
        [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapRequest dataUsingEncoding:NSUTF8StringEncoding]];
        
        conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
        //        spinner1.hidesWhenStopped=YES;
        [spinner1 startAnimating];
        
        if (conn) {
            buffer = [NSMutableData data];
        }

    }
}

#pragma mark - Invoke Account List Service

-(void)loadAccountListfor:(NSString *)user withSession:(NSString *)session{
    parseURL = @"accountList";
    NSString *soapRequest = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                             "<soap:Body>"
                             "<GetTradeAccount xmlns=\"http://OMS/\">"
                             "<UserSession>%@</UserSession>"
                             "<UserID>%@</UserID>"
                             "</GetTradeAccount>"
                             "</soap:Body>"
                             "</soap:Envelope>",session,user];
    //    NSLog(@"SoapRequest is %@" , soapRequest);
    NSString *urls = [NSString stringWithFormat:@"%@%s",dm.serviceURL,"op=GetTradeAccount"];
    NSURL *url =[NSURL URLWithString:urls];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://OMS/GetTradeAccount" forHTTPHeaderField:@"SOAPAction"];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapRequest length]];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapRequest dataUsingEncoding:NSUTF8StringEncoding]];
    [dm.accountList removeAllObjects];
    [dm.accountDict removeAllObjects];
    
    conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (conn) {
        buffer = [NSMutableData data];
    }
}

#pragma mark - Connection Delegates

-(void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *) response {
    [buffer setLength:0];
}
-(void) connection:(NSURLConnection *) connection didReceiveData:(NSData *) data {
    [buffer appendData:data];
}
-(void) connection:(NSURLConnection *) connection didFailWithError:(NSError *) error {
    UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:@"Connection Error..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [toast show];
    int duration = 1.5;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toast dismissWithClickedButtonIndex:0 animated:YES];
    });
    [spinner1 stopAnimating];
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
    //    NSLog(@"\n\nSoap Response is %@",theXML);
    [buffer setData:[theXML dataUsingEncoding:NSUTF8StringEncoding]];
    self.parser =[[NSXMLParser alloc]initWithData:buffer];
    [parser setDelegate:self];
    [parser parse];
    [spinner1 stopAnimating];
}

#pragma mark - XML Parser

-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict {
    
    if ([parseURL isEqualToString:@"accountList"]) {
        if([elementName isEqualToString:@"GetTradeAccountResult"]){
            ////NSLog(@"%@",[attributeDict description]);
            resultFound=NO;
        }
        if ([elementName isEqualToString:@"z:row"]) {
            [dm.accountDict setValue:[attributeDict objectForKey:@"TRADE_ACC_ID"] forKey:[attributeDict objectForKey:@"TRADE_ACC_NAME"]];
            dm.accountList =[[[dm.accountDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
        }
        
    }
    else{
        
        
        if([elementName isEqualToString:@"AuthenticateUserResult"]){
            ////NSLog(@"%@",[attributeDict description]);
            resultFound=NO;
        }
        if ([elementName isEqualToString:@"z:row"]) {
//            NSString* result = [attributeDict objectForKey:@"RESULT"];
//            NSLog(@"%@",result);
            resultFound=YES;
            dm.userID=name;
            dm.password=password;
            dm.sessionID = sessionID;
            upwd.text=@"";
            dm.accountList = [[NSMutableArray alloc]init];
            dm.accountDict = [[NSMutableDictionary alloc]init];
            [self loadAccountListfor:dm.userID withSession:dm.sessionID];
            dm.currentInstallation.channels = @[ @"" , dm.userID ];
            [dm.currentInstallation saveInBackground];
            [self performSegueWithIdentifier:@"ifisPortal" sender:self];
        }
    }
    
}

- (void) parser:(NSXMLParser *) parser foundCharacters:(NSString *) string {
    NSString *msg;
    BOOL flag=FALSE;
    if(!resultFound){
        if([[string substringToIndex:1] isEqualToString:@"R"]){
            //NSLog(@"R error");
            msg = @"Invalid Username or Password";
            flag=TRUE;
        }
        else if([[string substringToIndex:1] isEqualToString:@"E"]){
            //NSLog(@"E error");
            msg = @"Connection Error";
            flag=TRUE;
        }
        if (flag) {
            
            UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [toast show];
            int duration = 1.5;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
            [spinner1 stopAnimating];
            
        }
        resultFound=YES;
    }
}

-(void) parser:(NSXMLParser *) parser didEndElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName{
}

-(void)dismissView{
    
}
#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([[segue identifier] isEqualToString:@"changeService"]) {
            
            ChangeServiceViewController *vc = (ChangeServiceViewController *)segue.destinationViewController;
            vc.settings = self;
        }
    }
}


@end
