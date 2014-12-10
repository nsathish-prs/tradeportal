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
#import "TransitionDelegate.h"


@interface LoginViewController (){
    NSURLConnection *conn;
    BOOL dataFound;
    BOOL resultFound;
    
    NSString *name;
    NSString *password;
    NSString *sessionID;
}

@property (nonatomic, strong) TransitionDelegate *transitionController;

@end

@implementation LoginViewController

DataModel *dm;
@synthesize uname1,upwd,buffer,parser,conn,error,spinner1;
@synthesize transitionController;


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
    //uname.text = dm.userID;
    self.transitionController = [[TransitionDelegate alloc] init];
    
    }

-(void)viewWillAppear:(BOOL)animated{
    self.view.alpha = 1.0f;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [uname1 resignFirstResponder];
    [upwd resignFirstResponder];
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
        spinner1.hidesWhenStopped=YES;
        [spinner1 startAnimating];

            if (conn) {
                buffer = [NSMutableData data];
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
    UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:@"Connection Error..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [toast show];
    int duration = 1.5;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toast dismissWithClickedButtonIndex:0 animated:YES];
    });
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

-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict {
    
    if([elementName isEqualToString:@"AuthenticateUserResult"]){
        ////NSLog(@"%@",[attributeDict description]);
        resultFound=NO;
    }
    if ([elementName isEqualToString:@"z:row"]) {
        //        NSString* result = [attributeDict objectForKey:@"RESULT"];
        //        //NSLog(@"%@",result);
        resultFound=YES;
        dm.userID=name;
        dm.password=password;
        dm.sessionID = sessionID;
        upwd.text=@"";
        [self performSegueWithIdentifier:@"ifisPortal" sender:self];
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
        
        }
        resultFound=YES;
    }
}

-(void) parser:(NSXMLParser *) parser didEndElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName{
}

-(IBAction)buttonClicked:(UIButton*) button {
//    LoginViewController *lvc;
//    ChangePasswordViewController *cvc;
//    dm.toView=cvc;
//    dm.fromView = lvc;
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
//
//    vc.view.backgroundColor = [UIColor clearColor];
//    self.view.alpha = 0.5f;
//    [vc setTransitioningDelegate:transitionController];
//    vc.modalPresentationStyle= UIModalPresentationCustom;
//    [self presentViewController:vc animated:YES completion:nil];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"changeService"]) {
        
        ChangeServiceViewController *vc = (ChangeServiceViewController *)segue.destinationViewController;
        vc.settings = self;
    }
}


@end
