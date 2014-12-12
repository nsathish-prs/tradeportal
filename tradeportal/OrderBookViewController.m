//
//  OrderBookViewController.m
//  tradeportal
//
//  Created by Nagarajan Sathish on 23/10/14.
//
//

#import "OrderBookViewController.h"
#import "OrderBookTableViewCell.h"
#import "OrderBookDetailsViewController.h"

@interface OrderBookViewController(){
    BOOL resultFound;
}

@property (strong, nonatomic) NSMutableData *buffer;
@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSString *parseURL;
@property (strong, nonatomic) NSURLConnection *conn;
@property(strong,nonatomic)NSDictionary *statusDict;


@end

@implementation OrderBookViewController


@synthesize orders = _orders,buffer,parseURL,parser,conn,orderList=_orderList,statusDict, searchBar,searchBtn;
OrderBookModel *obm;
DataModel *dm;

#pragma mark - View Delegates

-(void)viewDidLoad{
    statusDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                  @"CXL",@"Cancelled",
                  @"CHG",@"Changed",
                  @"FILL",@"Filled",
                  @"PARK",@"Parked",
                  @"PART",@"Partially Filled",
                  @"PCHG",@"Pending Changed",
                  @"PCXL",@"Pending Cancel",
                  @"PQ",@"Pending Queue",
                  @"Q",@"Queue",
                  @"RJCT",@"Rejected",
                  @"CXL",@"Unsolicited Cancel",
                  @"CHG",@"Part Changed",
                  @"CXL",@"Part Cancelled",
                  nil];
    
    orders = [[NSMutableArray alloc]init];
    orderList= [[NSMutableArray alloc]init];
    self.tableView.estimatedRowHeight = 40.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    refreshControl.tintColor = iRELOAD;
    [refreshControl addTarget:self action:@selector(reloadTableData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.refreshControl beginRefreshing];
    [self searchBar].hidden = TRUE;
    [self reloadTableData];
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar endEditing:YES];
    [orders removeAllObjects];
    [orders addObjectsFromArray:orderList];
    [self.tableView reloadData];
    [[self segmentedControl]setSelectedSegmentIndex:0];
    [super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[[[[[self tabBarController]tabBar]items]objectAtIndex:1]badgeValue] isEqualToString:@"1"]) {
        [self reloadTableData];
        [[[[[self tabBarController]tabBar]items]objectAtIndex:1]setBadgeValue:NULL];
    }
    [super viewDidAppear:animated];
}

#pragma mark - Reload Order List

-(void)reloadTableData{
    [orderList removeAllObjects];
    [orders removeAllObjects];
    [self loadOrders];
}

#pragma mark - TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == searchBar){
        [self hideSearch:self];
    }
    return YES;
}

#pragma mark - Search

- (IBAction)stockSearch:(id)sender {
    [self.segmentedControl setSelectedSegmentIndex:0];
    [orders removeAllObjects];
    [orders addObjectsFromArray:orderList];
    [self.tableView reloadData];
    [self segmentedControl].hidden = TRUE;
    [self searchBtn].hidden = TRUE;
    [self searchBar].hidden = FALSE;
    [searchBar becomeFirstResponder];
}

- (IBAction)hideSearch:(id)sender {
    [self segmentedControl].hidden = FALSE;
    [self searchBtn].hidden = FALSE;
    [self searchBar].hidden = TRUE;
    [self searchBar].text = @"";
    [[self segmentedControl]setSelectedSegmentIndex:-1];
    [self.navigationController.navigationBar endEditing:YES];
}

-(IBAction)searchOrderList:(id)sender
{
    if ([searchBar.text isEqualToString:@""]) {
        [orders removeAllObjects];
        [orders addObjectsFromArray:orderList];
    } else {
        NSString *searchText = searchBar.text;
        [orders removeAllObjects];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(stockCode contains[cd] %@) or (desc contains[cd] %@) or (clientAccount contains[cd] %@)", searchText,searchText,searchText];
        [orders addObjectsFromArray:[orderList filteredArrayUsingPredicate:predicate]];
    }
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [orders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setGroupingSeparator:@","];
    [numberFormatter setGroupingSize:3];
    [numberFormatter setUsesGroupingSeparator:YES];
    
    NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
    [priceFormatter setDecimalSeparator:@"."];
    [priceFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [priceFormatter setMaximumFractionDigits:3];
    [priceFormatter setMinimumFractionDigits:3];
    
    OrderBookTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OrderBookTableViewCell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if([orders count]>0){
        NSMutableString *stock = [[[orders objectAtIndex:[indexPath row]]stockCode]mutableCopy];
        UIColor *textColor = [[UIColor alloc]init];
        //        [[cell stockCode] setText:[[orders objectAtIndex:[indexPath row]]stockCode]];
        [[cell side] setText:[[orders objectAtIndex:[indexPath row]]clientAccount]];
        if([[[orders objectAtIndex:[indexPath row]]side] isEqualToString:@"Buy"]){
            [stock appendString:@" (B)"];
            textColor = iGREEN;
        }
        if([[[orders objectAtIndex:[indexPath row]]side] isEqualToString:@"Sell"]){
            [stock appendString:@" (S)"];
            textColor = iRED;
        }
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:stock];
        //        NSLog(@"%lu\t%lu",(unsigned long)stock.length,(unsigned long)string.length);
        [string addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(stock.length-2, 1)];
        
        [[cell stockCode] setAttributedText:string];
        [[cell price] setText:[priceFormatter stringFromNumber:[NSNumber numberWithDouble:[[[orders objectAtIndex:[indexPath row]]orderPrice] doubleValue]]]];
        [[cell quantity] setText:[numberFormatter stringFromNumber:[NSNumber numberWithInt:[[[orders objectAtIndex:[indexPath row]]orderQty] intValue]]]];
        [[cell qtyFilled] setText:[numberFormatter stringFromNumber:[NSNumber numberWithInt:[[[orders objectAtIndex:[indexPath row]]qtyFilled] intValue]]]];
        [[cell status] setText:[statusDict valueForKey:[[orders objectAtIndex:[indexPath row]]status]]];
    }
    return cell;
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"tableHeader"];
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 38.0;
}


#pragma mark - Invoke Order List Service

-(void)loadOrders{
    
    self.parseURL = @"getOrders";
    NSString *soapRequest = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                             "<soap:Body>"
                             "<GetOrderByUserID xmlns=\"http://OMS/\">"
                             "<UserSession>%@</UserSession>"
                             "<UserID>%@</UserID>"
                             "</GetOrderByUserID>"
                             "</soap:Body>"
                             "</soap:Envelope>", dm.sessionID,dm.userID];
//    NSLog(@"SoapRequest is %@" , soapRequest);
    NSString *urls = [NSString stringWithFormat:@"%@%s",dm.serviceURL,"op=GetOrderByUserID"];
    NSURL *url =[NSURL URLWithString:urls];
    //    NSLog(@"%@",url);
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://OMS/GetOrderByUserID" forHTTPHeaderField:@"SOAPAction"];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapRequest length]];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapRequest dataUsingEncoding:NSUTF8StringEncoding]];
    [orders removeAllObjects];
    [orderList removeAllObjects];
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
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

-(void) connectionDidFinishLoading:(NSURLConnection *) connection {
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
    [orderList removeAllObjects];
    [orders removeAllObjects];
    [buffer setData:[theXML dataUsingEncoding:NSUTF8StringEncoding]];
    parser =[[NSXMLParser alloc]initWithData:buffer];
    [parser setDelegate:self];
    [parser parse];
}


#pragma mark - XML Parser

-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict {
    
    //parse the data
    if ([parseURL isEqualToString:@"getOrders"]) {
        
        if([elementName isEqualToString:@"GetOrderByUserIDResult"]){
            resultFound=NO;
        }
        if ([elementName isEqualToString:@"z:row"]) {
            resultFound=YES;
            OrderBookModel *order = [[OrderBookModel alloc]init];
            order.refNo = [attributeDict objectForKey:@"c8"];
            order.clientAccount = [attributeDict objectForKey:@"c9"];
            order.stockCode = [attributeDict objectForKey:@"Stock"];
            order.desc = [attributeDict objectForKey:@"c43"];
            order.exchange = [attributeDict objectForKey:@"Exchange"];
            order.side = [attributeDict objectForKey:@"c4"];
            order.orderType = [attributeDict objectForKey:@"c24"];
            order.status = [attributeDict objectForKey:@"c7"];
            order.orderQty = [attributeDict objectForKey:@"OrderQty"];
            order.qtyFilled = [attributeDict objectForKey:@"FilledQty"];
            order.orderPrice = [attributeDict objectForKey:@"OrderPrice"];
            order.avgPrice = [attributeDict objectForKey:@"AvePrice"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
            order.orderDate = [dateFormatter dateFromString:[attributeDict objectForKey:@"c11"]];
            order.currency = [attributeDict objectForKey:@"c22"];
            //Add arrribute value to array
            [orderList addObject:order];
            [orders addObject:order];
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
        [self.segmentedControl setSelectedSegmentIndex:0];
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
            msg = @"User has logged on elsewhere!";
            [self dismissViewControllerAnimated:YES completion:nil];
            [[self navigationController]popToRootViewControllerAnimated:YES];
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


#pragma mark - Segmented Control

-(IBAction)indexChanged:(UISegmentedControl *)sender
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
            [orders removeAllObjects];
            [orders addObjectsFromArray:orderList];
            [self.tableView reloadData];
            break;
        case 1:
            [orders removeAllObjects];
            for(OrderBookModel *ob in orderList){
                if([ob.status isEqualToString:@"Filled"]){
                    [orders addObject:ob];
                }
            }
            [self.tableView reloadData];
            break;
        case 2:
            [orders removeAllObjects];
            for(OrderBookModel *ob in orderList){
                if([ob.status isEqualToString:@"Queue"]){
                    [orders addObject:ob];
                }
            }
            [self.tableView reloadData];
            break;
        default:
            break;
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.navigationController.navigationBar endEditing:YES];
    if ([[segue identifier] isEqualToString:@"orderDetail"]) {
        
        OrderBookDetailsViewController *vc = (OrderBookDetailsViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //        NSLog(@"%@",indexPath);
        OrderBookModel *obm = [orders objectAtIndex:indexPath.row];
        vc.order = obm;
        vc.orderBook = self;
    }
    
}


@end
