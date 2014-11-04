//
//  OrderBookDetailsViewController.m
//  tradeportal
//
//  Created by Nagarajan Sathish on 27/10/14.
//
//

#import "OrderBookDetailsViewController.h"
#import "DataModel.h"
#import "OrderBookViewController.h"

@interface OrderBookDetailsViewController ()

@property (strong, nonatomic) NSMutableData *buffer;
@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSString *parseURL;
@property (strong, nonatomic) NSURLConnection *conn;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation OrderBookDetailsViewController

@synthesize order,refNo,clientAccount,stockCode,desc,exchange,orderType,status,orderQty,qtyFilled,orderPrice,avgPrice,orderDate,currency,options,edit,cancel,buffer,parser,parseURL,conn,spinner,orderBook;
DataModel *dm;
bool tag;
NSInteger qty ;
CGFloat price;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setGroupingSeparator:@","];
    [numberFormatter setGroupingSize:3];
    [numberFormatter setUsesGroupingSeparator:YES];
    [numberFormatter setDecimalSeparator:@"."];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:3];
    
    
    refNo.text = order.refNo;
    clientAccount.text = order.clientAccount;
    stockCode.text = order.stockCode;
    desc.text = order.desc;
    exchange.text = order.exchange;
    orderType.text = order.orderType;
    status.text = order.status;
    orderQty.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:[order.orderQty intValue]]];
    qtyFilled.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:[order.qtyFilled intValue]]];
    orderPrice.text = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[order.orderPrice doubleValue]]];
    avgPrice.text = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[order.avgPrice doubleValue]]];
    orderDate.text = [NSDateFormatter localizedStringFromDate:order.orderDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    currency.text = order.currency;
    
    
    if ([orderType.text isEqualToString:@"Buy"]) {
        orderType.textColor = iGREEN;
    }else if ([orderType.text isEqualToString:@"Sell"]){
        orderType.textColor = iRED;
    }
    
    if([order.status isEqualToString:@"Queue"]
       ||[order.status isEqualToString:@"Partially Filled"]
       ||[order.status isEqualToString:@"Changed"]
       ||[order.status isEqualToString:@"Part Changed"]){
        [options setHidden:NO];
        
    }
    
    
    spinner.center= CGPointMake( [UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
    UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
    [mainWindow addSubview:spinner];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)amendOrder:(id)sender {
    
    UIAlertView* amend = [[UIAlertView alloc] init];
    amend.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [amend setDelegate:self];
    [amend setTitle:@"Confirm to amend this order"];
    //[dialog setMessage:@" "];
    [amend addButtonWithTitle:@"Confirm"];
    [amend addButtonWithTitle:@"Cancel"];
    amend.tag = 1;
    
    UITextField *price = [amend textFieldAtIndex:0];
    [price setPlaceholder:@"Order Price"];
    [price setKeyboardType:UIKeyboardTypeDecimalPad];
    [price becomeFirstResponder];
    [price setBackgroundColor:[UIColor whiteColor]];
    
    UITextField *newQty = [amend textFieldAtIndex:1];
    [newQty setPlaceholder:@"New Order Qty."];
    [newQty setKeyboardType:UIKeyboardTypeNumberPad];
    [newQty setSecureTextEntry:FALSE];
    [newQty becomeFirstResponder];
    [newQty setBackgroundColor:[UIColor whiteColor]];
    
    [amend show];
}

- (IBAction)cancelOrder:(id)sender {
    UIAlertView* cancelOrder = [[UIAlertView alloc] init];
    cancelOrder.alertViewStyle = UIAlertViewStyleDefault;
    [cancelOrder setDelegate:self];
    //[cancelOrder setTitle:@"Change Order Qty."];
    [cancelOrder setMessage:@"Confirm to cancel this order"];
    [cancelOrder addButtonWithTitle:@"Confirm"];
    [cancelOrder addButtonWithTitle:@"Cancel"];
    cancelOrder.tag = 2;
    [cancelOrder show];
}

-(void)checkStatus{
    
    self.parseURL = @"checkStatus";
    NSString *soapRequest = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                             "<soap:Body>"
                             "<GetOrderStatus xmlns=\"http://OMS/\">"
                             "<UserSession>%@</UserSession>"
                             "<recID>%d</recID>"
                             "</GetOrderStatus>"
                             "</soap:Body>"
                             "</soap:Envelope>", dm.sessionID,[order.refNo intValue]];
    //NSLog(@"SoapRequest is %@" , soapRequest);
    NSURL *url =[NSURL URLWithString:@"http://192.168.174.109/oms_portal/ws_rsoms.asmx?op=GetOrderStatus"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://OMS/GetOrderStatus" forHTTPHeaderField:@"SOAPAction"];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapRequest length]];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapRequest dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    self.spinner.hidesWhenStopped=YES;
    [spinner startAnimating];
    if (conn) {
        buffer = [NSMutableData data];
    }
    
    
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%ld\t%li",(long)alertView.tag,(long)buttonIndex);
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            //confirm
            tag = true;
            qty = [[alertView textFieldAtIndex:1].text integerValue];
            price = [[alertView textFieldAtIndex:0].text floatValue];
            
            [self checkStatus];
            
        }
    }else if (alertView.tag == 2) {
        
        if (buttonIndex == 0) {
            //confirm
            tag = false;
            [self checkStatus];
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
    parser =[[NSXMLParser alloc]initWithData:buffer];
    [parser setDelegate:self];
    [parser parse];
    [spinner stopAnimating];
    
}

-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict {
    
    //parse the data
    if ([parseURL isEqualToString:@"cancelOrder"]) {
        
        if ([elementName isEqualToString:@"z:row"]) {
            OrderBookViewController *vc = (OrderBookViewController *)[[self.tabBarController viewControllers]objectAtIndex:1];
            [vc.view setNeedsDisplay];
            [orderBook reloadTableData];
            [self.tabBarController setSelectedViewController:vc];
            [self.navigationController popViewControllerAnimated:YES];
            //NSLog(@"");
        }
    }else if ([parseURL isEqualToString:@"amendOrder"]){
        if ([elementName isEqualToString:@"z:row"]) {
            OrderBookViewController *vc = (OrderBookViewController *)[[self.tabBarController viewControllers]objectAtIndex:1];
            [vc.view setNeedsDisplay];
            [orderBook reloadTableData];
            [self.tabBarController setSelectedViewController:vc];
            [self.navigationController popViewControllerAnimated:YES];
            //NSLog(@"");
        }
    }else if ([parseURL isEqualToString:@"checkStatus"]){
        if ([elementName isEqualToString:@"z:row"]) {
            if([[attributeDict objectForKey:@"ORDER_STATUS"] isEqualToString:@"0"]
               ||[[attributeDict objectForKey:@"ORDER_STATUS"] isEqualToString:@"1"]
               ||[[attributeDict objectForKey:@"ORDER_STATUS"] isEqualToString:@"5"]){
                if (tag) {
                    self.parseURL = @"amendOrder";
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                    [dateFormatter setDateFormat:@"yyyyMMdd HH:mm:ss"];
                    NSString *currentdate = [dateFormatter stringFromDate:[NSDate date]];
                    NSString *type;
                    if ([order.orderType isEqualToString:@"LIM"]) {
                        type = @"2";
                    }
                    NSString *soapRequest = [NSString stringWithFormat:
                                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                             "<soap:Body>"
                                             "<AmendOrder xmlns=\"http://OMS/\">"
                                             "<UserSession>%@</UserSession>"
                                             "<RecID>%d</RecID>"
                                             "<Qty>%ld</Qty>"
                                             "<Price>%f</Price>"
                                             "<UpdateBy>%@</UpdateBy>"
                                             "<LastUpdateTime>%@</LastUpdateTime>"
                                             "<OrderType>%@</OrderType>"
                                             "</AmendOrder>"
                                             "</soap:Body>"
                                             "</soap:Envelope>", dm.sessionID,[order.refNo intValue],(long)qty,price,dm.userID,currentdate,type];
                    //NSLog(@"SoapRequest is %@" , soapRequest);
                    NSURL *url =[NSURL URLWithString:@"http://192.168.174.109/oms_portal/ws_rsoms.asmx?op=AmendOrder"];
                    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
                    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                    [req addValue:@"http://OMS/AmendOrder" forHTTPHeaderField:@"SOAPAction"];
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
                else{
                    
                    self.parseURL = @"cancelOrder";
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                    [dateFormatter setDateFormat:@"yyyyMMdd HH:mm:ss"];
                    NSString *currentdate = [dateFormatter stringFromDate:[NSDate date]];
                    NSString *soapRequest = [NSString stringWithFormat:
                                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                             "<soap:Body>"
                                             "<CancelOrder xmlns=\"http://OMS/\">"
                                             "<UserSession>%@</UserSession>"
                                             "<RecID>%i</RecID>"
                                             "<UpdateBy>%@</UpdateBy>"
                                             "<LastUpdateTime>%@</LastUpdateTime>"
                                             "</CancelOrder>"
                                             "</soap:Body>"
                                             "</soap:Envelope>", dm.sessionID,[order.refNo intValue],dm.userID,currentdate];
                    //NSLog(@"SoapRequest is %@" , soapRequest);
                    NSURL *url =[NSURL URLWithString:@"http://192.168.174.109/oms_portal/ws_rsoms.asmx?op=CancelOrder"];
                    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
                    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                    [req addValue:@"http://OMS/CancelOrder" forHTTPHeaderField:@"SOAPAction"];
                    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapRequest length]];
                    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
                    [req setHTTPMethod:@"POST"];
                    [req setHTTPBody:[soapRequest dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    self.conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
                    self.spinner.hidesWhenStopped=YES;
                    [spinner startAnimating];
                    if (conn) {
                        buffer = [NSMutableData data];
                    }
                }
            }
        }
    }
}

@end
