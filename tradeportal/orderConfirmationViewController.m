//
//  orderConfirmationViewController.m
//  tradeportal
//
//  Created by Nagarajan Sathish on 20/10/14.
//
//

#import "orderConfirmationViewController.h"
#import "orderEntryViewController.h"
#import "DataModel.h"
#import "OrderBookViewController.h"

@interface orderConfirmationViewController ()
@property (strong, nonatomic) NSURLConnection *conn;
@property (strong, nonatomic) NSMutableData *buffer;
@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSString *parseURL;
@property(strong,nonatomic)NSString *dataFound;
@property(nonatomic)CGFloat amt;
@end

@implementation orderConfirmationViewController


@synthesize conn,parser,buffer,parseURL,orderEntry;


@synthesize orderPrice,clientAccount,shortName,stockCode,qty,totalAmount,currency,type,routeDest;
@synthesize orderPriceValue,clientAccountValue,shortNameValue,stockCodeValue,qtyValue,totalAmountValue,currencyValue,typeValue,routeDestValue,side,exchange,orderType,exchangeRate,timeInForce,currencyCode,spinner,amt;
DataModel *dm;
NSString *userID;

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.navigationItem.title = @"Order Confirmation";
    ////    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]init];
    ////    backButton.title = @"Back";
    //    self.navigationItem.leftBarButtonItem.title = @"Back";
    userID = dm.userID;
    clientAccount.text = clientAccountValue;
    stockCode.text = stockCodeValue;
    shortName.text = shortNameValue;
    qty.text = qtyValue;
    orderPrice.text = orderPriceValue;
    currency.text = currencyValue;
    type.text = typeValue;
    routeDest.text = routeDestValue;
    orderType=@"2";
    timeInForce=@"0";
    currencyCode=@"702";
    
    amt = [orderPriceValue floatValue]*[qtyValue integerValue];
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc]init];
    [fmt setMaximumFractionDigits:2];
    [fmt setMinimumIntegerDigits:1];
    totalAmount.text = [fmt stringFromNumber:[NSNumber numberWithFloat:amt]];
    if ([typeValue isEqualToString:@"BUY"]) {
        type.textColor = iGREEN;
    }else if ([typeValue isEqualToString:@"SELL"]){
        type.textColor = iRED;
    }
    self.password.delegate = self;
    //[self initBackBtn];
}


-(void)initBackBtn
{
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backBtnPressed)];
    self.navigationItem.leftBarButtonItem = backBtn;
}

-(void)backBtnPressed
{
    //write your code to prepare popview
    [self.navigationController popViewControllerAnimated:NO];
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35f];
    CGRect frame = self.view.frame;
    frame.origin.y = -100;
    [self.view setFrame:frame];
    [UIView commitAnimations];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [ UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35f];
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    [self.view setFrame:frame];
    [UIView commitAnimations];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmPassword:(id)sender {
    NSString *password = self.password.text;
    if(password == nil){
        UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:@"Please enter user password!" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [toast show];
        int duration = 1.5;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [toast dismissWithClickedButtonIndex:0 animated:YES];
        });

    }
    else{
        NSString *soapRequest = [NSString stringWithFormat:
                                 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                 "<soap:Body>"
                                 "<CheckUserPwd xmlns=\"http://OMS/\">"
                                 "<strUserID>%@</strUserID>"
                                 "<strPwd>%@</strPwd>"
                                 "</CheckUserPwd>"
                                 "</soap:Body>"
                                 "</soap:Envelope>",userID,password];
        //NSLog(@"SoapRequest is %@" , soapRequest);
        NSURL *url =[NSURL URLWithString:@"http://192.168.174.109/oms/ws_rsoms.asmx?op=CheckUserPwd"];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://OMS/CheckUserPwd" forHTTPHeaderField:@"SOAPAction"];
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

- (IBAction)cancelOrder:(id)sender {
    [orderEntry reloadData];
    [self.navigationController popViewControllerAnimated:YES];
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
    //NSLog(@"\n\nSoap Response is %@",theXML);
    [buffer setData:[theXML dataUsingEncoding:NSUTF8StringEncoding]];
    self.parser =[[NSXMLParser alloc]initWithData:buffer];
    [parser setDelegate:self];
    [parser parse];
    [spinner stopAnimating];
}

-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict {
    
    if ([elementName isEqualToString:@"z:row"]) {
        NSInteger result = [[attributeDict objectForKey:@"RESULT"] integerValue];
        if (result == 1) {
            //success
            [self newOrder];
        }else if (result == -1){
            //Exception occurs while checking password
        }
        else if(result== 0){
            //Invalid password
        }
        else{
            //NSLog(@"default error msg");
        }
    }
    if ([elementName isEqualToString:@"CheckUserPwdResult"]) {
        _dataFound = @"checkUser";
    }
    if ([elementName isEqualToString:@"NewOrderResult"]) {
        _dataFound = @"newOrder";
    }
}

- (void) parser:(NSXMLParser *) parser foundCharacters:(NSString *) string {
    NSString *msg=@"";
    //NSLog(@"%@",string);
    if([_dataFound isEqualToString:@"newOrder"]){
        
        if ([string isEqualToString:@"S"]) {
            msg = @"Order Successfully Made!";
            OrderBookViewController *vc = (OrderBookViewController *)[[self.tabBarController viewControllers]objectAtIndex:1];
            [orderEntry reloadData];
            [[[[[self tabBarController]tabBar]items]objectAtIndex:1] setBadgeValue:@"1"];
            [self.tabBarController setSelectedViewController:vc];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            
            if([[string substringToIndex:1] isEqualToString:@"E"]){
                //NSLog(@"E error");
                msg = @"User has logged on elsewhere!";
                [self dismissViewControllerAnimated:YES completion:nil];
                [[self navigationController]popToRootViewControllerAnimated:YES];
            }
            else{
                msg = string;
            }
        }
        _dataFound=@"";
    }
    if ([_dataFound isEqualToString:@"checkUser"]) {
        if ([[string substringToIndex:1] isEqualToString:@"R"]) {
            msg = @"Incorrect Password. \n Try again...";
        }
        else if ([[string substringToIndex:1] isEqualToString:@"E"]) {
            msg = @"Some Technical Error. \n Please Try again...";
        }
        
    }
    if (![msg isEqualToString:@""]) {
        
        UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [toast show];
        int duration = 1.5;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [toast dismissWithClickedButtonIndex:0 animated:YES];
        });
    }
}

-(void)newOrder{
    NSString *soapRequest = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                             "<soap:Body>"
                             "<NewOrder xmlns=\"http://OMS/\">"
                             "<UserSession>%@</UserSession>"
                             "<TradeAccID>%@</TradeAccID>"
                             "<Symbol>%@</Symbol>"
                             "<Qty>%d</Qty>"
                             "<Price>%f</Price>"
                             "<Side>%@</Side>"
                             "<OrderType>%@</OrderType>"
                             "<TradeOfficer>%@</TradeOfficer>"
                             "<Exchange>%@</Exchange>"
                             "<TimeInForce>%@</TimeInForce>"
                             "<SettlementCurr>%@</SettlementCurr>"
                             "<SpecialInstruction></SpecialInstruction>"
                             "<UpdateBy>%@</UpdateBy>"
                             "<ExchRate>%@</ExchRate>"
                             "<StockCurrency>%@</StockCurrency>"
                             "<StockLocation>%@</StockLocation>"
                             "<ForceOrderStatus>%d</ForceOrderStatus>"
                             "<ISIN_Code></ISIN_Code>"
                             "<ExtraCare></ExtraCare>"
                             "<Strategy></Strategy>"
                             "<VWAP_Start_Time></VWAP_Start_Time>"
                             "<VWAP_End_Time></VWAP_End_Time>"
                             "<Would_Quantity></Would_Quantity>"
                             "<Would_Price></Would_Price>"
                             "<ExpireDate></ExpireDate>"
                             "<AlPercent>%f</AlPercent>"
                             "<AlAuction></AlAuction>"
                             "<AlRelLimit>%f</AlRelLimit>"
                             "<AlBenchMark></AlBenchMark>"
                             "</NewOrder>"
                             "</soap:Body>"
                             "</soap:Envelope>",dm.sessionID,clientAccountValue,stockCodeValue,[qtyValue intValue],[orderPriceValue floatValue],side,orderType,userID,exchange,timeInForce,currencyCode,userID,exchangeRate,currencyCode,exchange,1,0.0,0.0];
    //NSLog(@"SoapRequest is %@" , soapRequest);
    NSURL *url =[NSURL URLWithString:@"http://192.168.174.109/oms_portal/ws_rsoms.asmx?op=NewOrder"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://OMS/NewOrder" forHTTPHeaderField:@"SOAPAction"];
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

@end
