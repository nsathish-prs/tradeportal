//
//  LoginViewController.m
//  tradeportal
//
//  Created by intern on 8/10/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "DataModel.h"

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
@synthesize uname,pwd,buffer,parser,conn,error;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dm = [[DataModel alloc]init];
    uname.delegate = self;
    pwd.delegate = self;
    }

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [uname resignFirstResponder];
    [pwd resignFirstResponder];
    return YES;
}

- (void)viewDidUnload
{
    //    [btnSelect release];
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(IBAction)login:(id)sender{
    name = uname.text;
    password = pwd.text;
    sessionID = @"string";
    NSLog(@"%@ , %@",name,password);
    BOOL flag=TRUE;
    if([name isEqualToString:@""]){
        uname.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Enter Username" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:200.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f]}];
        flag=FALSE;
    }
    if([password isEqualToString:@""]){
        pwd.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Enter Password" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:200.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f]}];

        flag = FALSE;
    }
    if(flag){
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
        NSLog(@"SoapRequest is %@" , soapRequest);
        NSURL *url =[NSURL URLWithString:@"http://192.168.174.109/oms/ws_rsoms.asmx?op=AuthenticateUser"];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://OMS/AuthenticateUser" forHTTPHeaderField:@"SOAPAction"];
        NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapRequest length]];
        [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapRequest dataUsingEncoding:NSUTF8StringEncoding]];
        
        conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
        if (conn) {
            self.buffer = [NSMutableData data];
        }
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
    NSLog(@"\n\nDone with bytes %lu", (unsigned long)[buffer length]);
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
    
    if([elementName isEqualToString:@"AuthenticateUserResult"]){
        //NSLog(@"%@",[attributeDict description]);
        resultFound=NO;
    }
    if ([elementName isEqualToString:@"z:row"]) {
        //        NSString* result = [attributeDict objectForKey:@"RESULT"];
        //        NSLog(@"%@",result);
        resultFound=YES;
        dm.userID=name;
        dm.password=password;
        dm.sessionID = sessionID;
        [self performSegueWithIdentifier:@"ifisPortal" sender:self];
    }
    
    
}

- (void) parser:(NSXMLParser *) parser foundCharacters:(NSString *) string {
    NSString *msg;
    BOOL flag=FALSE;
    if(!resultFound){
        if([[string substringToIndex:1] isEqualToString:@"R"]){
            NSLog(@"R error");
            msg = @"Invalid Username or Password";
            flag=TRUE;
        }
        else if([[string substringToIndex:1] isEqualToString:@"E"]){
            NSLog(@"E error");
            msg = @"Connection Error";
                        flag=TRUE;
        }
        if (flag) {
            
        UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [toast show];
        int duration = 1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [toast dismissWithClickedButtonIndex:0 animated:YES];
        });
        
        }
        resultFound=YES;
    }
}

-(void) parser:(NSXMLParser *) parser didEndElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName{
}



@end
