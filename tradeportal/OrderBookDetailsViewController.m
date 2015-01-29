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
#import "AmendOrderViewController.h"
#import "OrderDetailsTableViewCell.h"
#import "OrderDetailsModel.h"

@interface OrderBookDetailsViewController (){
    BOOL resultFound;
}

@property (strong, nonatomic) NSMutableData *buffer;
@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSString *parseURL;
@property (strong, nonatomic) NSURLConnection *conn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner1;
@end

@implementation OrderBookDetailsViewController

@synthesize order,refNo,clientAccount,stockCode,desc,exchange,status,orderQty,qtyFilled,orderPrice,avgPrice,orderDate,currency,options,edit,cancel,buffer,parser,parseURL,conn,spinner,spinner1,orderBook,side,flag,messages=_messages;
DataModel *dm;
bool tag;
NSInteger qty ;
CGFloat price;

#pragma mark - View Delegates

- (void)viewDidLoad {
    [super viewDidLoad];
    flag=false;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setGroupingSeparator:@","];
    [numberFormatter setGroupingSize:3];
    [numberFormatter setUsesGroupingSeparator:YES];
    
    NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
    [priceFormatter setGroupingSeparator:@","];
    [priceFormatter setGroupingSize:3];
    [priceFormatter setDecimalSeparator:@"."];
    [priceFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [priceFormatter setMaximumFractionDigits:3];
    [priceFormatter setMinimumFractionDigits:3];
    
    refNo.text = order.refNo;
    clientAccount.text = order.clientAccount;
    stockCode.text = order.stockCode;
    desc.text = order.desc;
    exchange.text = order.exchange;
    side.text = order.side;
    status.text = order.status;
    orderQty.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:[order.orderQty intValue]]];
    qtyFilled.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:[order.qtyFilled intValue]]];
    orderPrice.text = [priceFormatter stringFromNumber:[NSNumber numberWithDouble:[order.orderPrice doubleValue]]];
    avgPrice.text = [priceFormatter stringFromNumber:[NSNumber numberWithDouble:[order.avgPrice doubleValue]]];
    orderDate.text = [NSDateFormatter localizedStringFromDate:order.orderDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    currency.text = order.currency;
    if ([side.text isEqualToString:@"Buy"]) {
        side.textColor = iGREEN;
    }else if ([side.text isEqualToString:@"Sell"]){
        side.textColor = iRED;
    }
    if([order.status isEqualToString:@"Queue"]
       ||[order.status isEqualToString:@"Partially Filled"]
       ||[order.status isEqualToString:@"Changed"]
       ||[order.status isEqualToString:@"Part Changed"]){
        [options setHidden:NO];
    }
    spinner1.center= CGPointMake( [UIScreen mainScreen].bounds.size.width/4,[UIScreen mainScreen].bounds.size.height/2);
    UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
    [mainWindow addSubview:spinner1];
    
    messages = [[NSMutableArray alloc]init];
    [self loadMessages];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.view.alpha = 1.0f;
    if (flag) {
        [orderBook reloadTableData];
        [self.navigationController popViewControllerAnimated:YES];
    }
    [super viewWillAppear:animated];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    OrderDetailsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if([messages count]>0){
        [[cell recId]setText:[[messages objectAtIndex:[indexPath row]]rec_Id]];
        [[cell msg]setText:[[messages objectAtIndex:[indexPath row]]statusMessage]];
        [[cell updatedBy]setText:[[messages objectAtIndex:[indexPath row]]updated_By]];
    }
    return cell;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"tableHeader"];
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75.0;
}

#pragma mark - Invoke Order List Service

-(void)loadMessages{
    self.parseURL = @"loadMessages";
    NSString *soapRequest = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                             "<soap:Body>"
                             "<GetMessageLog xmlns=\"http://OMS/\">"
                             "<UserSession>%@</UserSession>"
                             "<POrderRecID>%d</POrderRecID>"
                             "</GetMessageLog>"
                             "</soap:Body>"
                             "</soap:Envelope>", dm.sessionID,[order.refNo intValue]];
    //    NSLog(@"SoapRequest is %@" , soapRequest);
    NSString *urls = [NSString stringWithFormat:@"%@%s",dm.serviceURL,"op=GetMessageLog"];
    NSURL *url =[NSURL URLWithString:urls];
    //    NSLog(@"%@",url);
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://OMS/GetMessageLog" forHTTPHeaderField:@"SOAPAction"];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapRequest length]];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapRequest dataUsingEncoding:NSUTF8StringEncoding]];
    conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (conn) {
        buffer = [NSMutableData data];
    }
    [spinner1 startAnimating];
}



#pragma mark - Cancel Order

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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 2) {
        
        if (buttonIndex == 0) {
            //confirm
            tag = false;
            [self checkStatus];
        }
    }
}

#pragma Invoke Cancel Order Service

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
    NSString *urls = [NSString stringWithFormat:@"%@%s",dm.serviceURL,"op=GetOrderStatus"];
    NSURL *url =[NSURL URLWithString:urls];
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
    [spinner stopAnimating];
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
    parser =[[NSXMLParser alloc]initWithData:buffer];
    [parser setDelegate:self];
    [parser parse];
    
}


#pragma mark - XML Parser

-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict {
    
    //parse the data
    if ([parseURL isEqualToString:@"cancelOrder"]) {
        if ([elementName isEqualToString:@"z:row"]) {
            if([elementName isEqualToString:@"CancelOrderFixIncomeResult"]){
                resultFound=NO;
            }
            else{
                OrderBookViewController *vc = (OrderBookViewController *)[[self.tabBarController viewControllers]objectAtIndex:1];
                [vc.view setNeedsDisplay];
                [orderBook reloadTableData];
                [self.tabBarController setSelectedViewController:vc];
                [self.navigationController popViewControllerAnimated:YES];
                UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:@"Cancel Order request sent Successfully" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
                [toast show];
                int duration = 1.5;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [toast dismissWithClickedButtonIndex:0 animated:YES];
                });
                [spinner stopAnimating];
            }
        }
    }else if ([parseURL isEqualToString:@"loadMessages"]) {
        if ([elementName isEqualToString:@"z:row"]) {
            OrderDetailsModel *msgs = [[OrderDetailsModel alloc]init];
            msgs.rec_Id= [attributeDict objectForKey:@"REC_ID"];
            msgs.statusMessage = [attributeDict objectForKey:@"MESSAGE"];
            msgs.updated_By = [attributeDict objectForKey:@"UPDATE_BY"];
            [messages addObject:msgs];
            [self.tableView reloadData];
            [spinner1 stopAnimating];
        }
    }
    else if ([parseURL isEqualToString:@"checkStatus"]){
        if([elementName isEqualToString:@"GetOrderStatusResult"]){
            //NSLog(@"%@",[attributeDict description]);
            resultFound=NO;
        }
        if ([elementName isEqualToString:@"z:row"]) {
            if([[attributeDict objectForKey:@"ORDER_STATUS"] isEqualToString:@"0"]
               ||[[attributeDict objectForKey:@"ORDER_STATUS"] isEqualToString:@"1"]
               ||[[attributeDict objectForKey:@"ORDER_STATUS"] isEqualToString:@"5"]){
                self.parseURL = @"cancelOrder";
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
                NSString *currentdate = [dateFormatter stringFromDate:[NSDate date]];
                
                NSString *data = [NSString stringWithFormat:@"UpdateBy=%@~RecID=%@~VoiceLog=~LastUpdateTime=%@~",dm.userID,order.refNo,currentdate];
                NSString *soapRequest = [NSString stringWithFormat:
                                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                         "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                         "<soap:Body>"
                                         "<CancelOrderFixIncome xmlns=\"http://OMS/\">"
                                         "<UserSession>%@</UserSession>"
                                         "<strData>%@</strData>"
                                         "<nVersion>%d</nVersion>"
                                         "</CancelOrderFixIncome>"
                                         "</soap:Body>"
                                         "</soap:Envelope>", dm.sessionID,data,0];
//                NSLog(@"SoapRequest is %@" , soapRequest);
                NSString *urls = [NSString stringWithFormat:@"%@%s",dm.serviceURL,"op=CancelOrderFixIncome"];
                NSURL *url =[NSURL URLWithString:urls];
                NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
                [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                [req addValue:@"http://OMS/CancelOrderFixIncome" forHTTPHeaderField:@"SOAPAction"];
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

- (void) parser:(NSXMLParser *) parser foundCharacters:(NSString *) string {
    NSString *msg;
    BOOL flag1=FALSE;
    if(!resultFound){
        if([[string substringToIndex:1] isEqualToString:@"R"]){
            msg = @"Some Technical Error...\nPlease Try again...";
            flag1=TRUE;
        }
        else if([[string substringToIndex:1] isEqualToString:@"E  "]){
            //NSLog(@"E error");
            msg = @"User has logged on elsewhere!";
            [self dismissViewControllerAnimated:YES completion:nil];
            [[self navigationController]popToRootViewControllerAnimated:YES];
            flag1=TRUE;
        }
        if (flag1) {
            
            UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [toast show];
            int duration = 1.5;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
            
        }
        [spinner stopAnimating];
        [spinner1 stopAnimating];
        resultFound=YES;
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Amend"]) {
        
        AmendOrderViewController *vc = (AmendOrderViewController *)segue.destinationViewController;
        vc.order = order;
        vc.orderBookDetails = self;
        vc.orderBook = orderBook;
    }
}

@end
