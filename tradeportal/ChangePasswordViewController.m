//
//  ChangePasswordViewController.m
//  tradeportal
//
//  Created by Nagarajan Sathish on 4/11/14.
//
//

#import "ChangePasswordViewController.h"
#import "DataModel.h"

@interface ChangePasswordViewController ()

@property (strong, nonatomic) NSMutableData *buffer;
@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSString *parseURL;
@property (strong, nonatomic) NSURLConnection *conn;

@end

@implementation ChangePasswordViewController
DataModel *dm;

@synthesize spinner,userID,password,nPassword,cPassword,buffer,parser,parseURL,conn,settings;
bool dataFound=NO;

#pragma mark - View Delegates

- (void)viewDidLoad {
    self.view.backgroundColor=[UIColor clearColor];
    settings.view.alpha=0.5f;
    [super viewDidLoad];
    userID.text = dm.userID;
}

#pragma mark - TextField Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - Invoke Change password Service

- (IBAction)changePassword:(id)sender {
    BOOL flag=TRUE;
    if([userID.text isEqualToString:@""]){
        userID.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Enter User ID" attributes:@{NSForegroundColorAttributeName: iERROR}];
        flag=FALSE;
    }
    if([password.text isEqualToString:@""]){
        password.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Enter Password" attributes:@{NSForegroundColorAttributeName: iERROR}];
        
        flag = FALSE;
    }
    if([nPassword.text isEqualToString:@""]){
        nPassword.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Enter New Password" attributes:@{NSForegroundColorAttributeName: iERROR}];
        flag=FALSE;
    }
    if([cPassword.text isEqualToString:@""]){
        cPassword.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Re-Enter New Password" attributes:@{NSForegroundColorAttributeName: iERROR}];
        
        flag = FALSE;
    }
    if(![cPassword.text isEqualToString:nPassword.text]){
        cPassword.text=@"";
        cPassword.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Re-Enter New Password" attributes:@{NSForegroundColorAttributeName: iERROR}];
        
        flag = FALSE;
    }
    
    if(flag){
        NSString *soapRequest = [NSString stringWithFormat:
                                 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                 "<soap:Body>"
                                 "<ChangeUserPwd xmlns=\"http://OMS/\">"
                                 "<PUserID>%@</PUserID>"
                                 "<POrgPwd>%@</POrgPwd>"
                                 "<PNewPwd>%@</PNewPwd>"
                                 "</ChangeUserPwd>"
                                 "</soap:Body>"
                                 "</soap:Envelope>",userID.text,password.text,nPassword.text];
        //NSLog(@"SoapRequest is %@" , soapRequest);
        NSString *urls = [NSString stringWithFormat:@"%@%s",dm.serviceURL,"op=ChangeUserPwd"];
        NSURL *url =[NSURL URLWithString:urls];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://OMS/ChangeUserPwd" forHTTPHeaderField:@"SOAPAction"];
        NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapRequest length]];
        [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapRequest dataUsingEncoding:NSUTF8StringEncoding]];
        
        conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
        spinner.hidesWhenStopped=YES;
        [spinner startAnimating];
        
        if (conn) {
            buffer = [NSMutableData data];
        }
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
    //NSLog(@"\n\nSoap Response is %@",theXML);
    [buffer setData:[theXML dataUsingEncoding:NSUTF8StringEncoding]];
    self.parser =[[NSXMLParser alloc]initWithData:buffer];
    [parser setDelegate:self];
    [parser parse];
    [spinner stopAnimating];
}


#pragma mark - XML Parser Delegates

-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict {
    
    if ([elementName isEqualToString:@"ChangeUserPwdResult"]) {
        dataFound = YES;
    }
}

- (void) parser:(NSXMLParser *) parser foundCharacters:(NSString *) string {
    NSString *msg;
    bool flag = false;
    if(dataFound){
        if([[string substringToIndex:1] isEqualToString:@"R"]){
            //NSLog(@"R error");
            msg = @"Invalid Password";
            flag=TRUE;
        }
        else if([[string substringToIndex:1] isEqualToString:@"E"]){
            //NSLog(@"E error");
            msg = @"Invalid Password";
            flag=TRUE;
            [self.tabBarController popoverPresentationController];
        }
        if ([string isEqualToString:@"S"]) {
            msg = @"Password Changed Successfully!";
            [self dismissView:self];
            flag = TRUE;
        }
        if (flag) {
            
            UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [toast show];
            int duration = 1.5;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
            
        }
        dataFound=YES;
    }
}

-(void) parser:(NSXMLParser *) parser didEndElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName{
}

#pragma mark - Dismiss View

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    settings.view.alpha = 1.0f;
}
@end
