//
//  AmendOrderViewController.m
//  tradeportal
//
//  Created by intern on 13/11/14.
//
//

#import "AmendOrderViewController.h"
#import "OrderBookViewController.h"
#import "OrderBookModel.h"

@interface AmendOrderViewController (){
    BOOL resultFound;
}

@property (strong, nonatomic) NSMutableData *buffer;
@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSString *parseURL;
@property (strong, nonatomic) NSURLConnection *conn;

@end

@implementation AmendOrderViewController
@synthesize orderPrice,orderQty,matchQty,nQty,nPrice,spinner,buffer,parser,parseURL,conn,order,orderBook;
DataModel *dm;
NSInteger qty ;
CGFloat price;
NSUserDefaults *getOrder;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setGroupingSeparator:@","];
    [numberFormatter setGroupingSize:3];
    [numberFormatter setUsesGroupingSeparator:YES];
    [numberFormatter setDecimalSeparator:@"."];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:3];
    self.view.backgroundColor=[UIColor clearColor];
    orderBook.view.alpha=0.5f;
    spinner.center= CGPointMake( [UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
    UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
    [mainWindow addSubview:spinner];
    
    
    //     getOrder = [NSUserDefaults standardUserDefaults];
    //    NSData *deOrder = [getOrder objectForKey:@"order"];
    //    order = [NSKeyedUnarchiver unarchiveObjectWithData:deOrder];
    //    orderQty.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:[order.orderQty intValue]]];
    //    orderPrice.text = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[order.orderPrice doubleValue]]];
    //    matchQty.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:[order.qtyFilled intValue]]];
    //    [getOrder removeObjectForKey:@"order"];
    //    [getOrder synchronize];
    orderQty.text = order.orderQty;
    orderPrice.text = order.orderPrice;
    matchQty.text = order.qtyFilled;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (IBAction)cancelAmend:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    orderBook.view.alpha = 1.0f;
}

- (IBAction)confirmAmend:(id)sender {
    qty = [nQty.text integerValue];
    price = [nPrice.text floatValue];
    NSString *qFilled = [matchQty.text stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSString *oQty = [orderQty.text stringByReplacingOccurrencesOfString:@"," withString:@""];
    if (!(qty == 0 && price == 0.0)) {
        if(qty == 0){
            qty = [oQty intValue];
        }
        if (price == 0.0) {
            price = [order.orderPrice doubleValue];
        }
        if (!(qty < [qFilled intValue] || qty > [oQty intValue])) {
            [self checkStatus];
        }
        else{
            UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:@"Invalid Quantity" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [toast show];
            int duration = 1.5;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
        }
    } else {
        UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:@"Please enter\n New Order Price or Quantity" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [toast show];
        int duration = 1.5;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [toast dismissWithClickedButtonIndex:0 animated:YES];
        });
    }
    
    
    
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
    NSLog(@"SoapRequest is %@" , soapRequest);
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
    NSLog(@"\n\nSoap Response is %@",theXML);
    [buffer setData:[theXML dataUsingEncoding:NSUTF8StringEncoding]];
    parser =[[NSXMLParser alloc]initWithData:buffer];
    [parser setDelegate:self];
    [parser parse];
    [spinner stopAnimating];
    
}

-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict {
    
    //parse the data
    if ([parseURL isEqualToString:@"amendOrder"]){
        if([elementName isEqualToString:@"AmendOrderResult"]){
            ////NSLog(@"%@",[attributeDict description]);
            resultFound=NO;
        }
        if ([elementName isEqualToString:@"z:row"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [orderBook.navigationController popViewControllerAnimated:YES];
            UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:@"Order Amended Successfully!" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [toast show];
            int duration = 1.5;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
        }
    }else if ([parseURL isEqualToString:@"checkStatus"]){
        if([elementName isEqualToString:@"GetOrderStatusResult"]){
            ////NSLog(@"%@",[attributeDict description]);
            resultFound=NO;
        }
        if ([elementName isEqualToString:@"z:row"]) {
            if([[attributeDict objectForKey:@"ORDER_STATUS"] isEqualToString:@"0"]
               ||[[attributeDict objectForKey:@"ORDER_STATUS"] isEqualToString:@"1"]
               ||[[attributeDict objectForKey:@"ORDER_STATUS"] isEqualToString:@"5"]){
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
        }
    }
}

- (void) parser:(NSXMLParser *) parser foundCharacters:(NSString *) string {
    NSString *msg;
    BOOL flag=FALSE;
    if(!resultFound){
        if([[string substringToIndex:1] isEqualToString:@"R"]){
            msg = @"Some Technical Error...\nPlease Try again...";
            flag=TRUE;
        }
        else if([[string substringToIndex:1] isEqualToString:@"E"]){
            //NSLog(@"E error");
            msg = @"User has logged on elsewhere!";
            [self dismissViewControllerAnimated:YES completion:nil];
            [getOrder setObject:@"NO" forKey:@"amend"];
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

@end
