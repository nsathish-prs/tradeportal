//
//  orderEntryViewController.h
//  tradeportal
//
//  Created by intern on 10/10/14.
//
//

#import "orderEntryViewController.h"
#import "orderConfirmationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RadioButton.h"
#import "DataModel.h"

@interface orderEntryViewController ()

@property (strong, nonatomic) NSMutableData *buffer;
@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSString *parseURL;
@property(strong,nonatomic)NSString *stockCode;
@property(strong,nonatomic)NSString *currency;
@property(strong,nonatomic)NSString *exchangeRate;
@property(strong,nonatomic)NSString *type;
@property(strong,nonatomic)NSString *route;
@property(strong,nonatomic)NSString *side;

@property (strong, nonatomic) NSURLConnection *conn;

@property(strong, nonatomic) NSMutableArray *searchStockNameList;
@property(strong, nonatomic) NSMutableArray *searchStockList;

@end

@implementation orderEntryViewController

@synthesize lastPrice,change,shortName,lotSize,askPrice,bidPrice,price,quantity,exchange, accountNumber,buffer,conn,parser,parseURL,submit,marketEx;
UIView *container;
DataModel *dm;
UILabel *label1, *label2;
RadioButton *rb1, *rb2;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadData];
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;

    [self.tabBarController setDelegate:self];
    //Picker View
    accountDict =[[NSMutableDictionary alloc]init];
    //[accountDict setValue:@"" forKey:@"Select Account"];
    [accountNumber resignFirstResponder];
    [self loadAccountListfor:dm.userID withSession:dm.sessionID];
    marketEx = @"SGX";
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont fontWithName:@"Helvetica Neue" size:11.0f], UITextAttributeFont,
                                                       [UIColor whiteColor], UITextAttributeTextColor,
                                                       [UIColor whiteColor], UITextAttributeTextShadowColor,
                                                       [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                                       nil] forState:UIControlStateNormal];
    
    //Radio Button
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        container = [[UIView alloc] initWithFrame:CGRectMake(150, 170, 150, 30)];
        label1  =[[UILabel alloc] initWithFrame:CGRectMake(35, 15, 60, 20)];
        label1.backgroundColor = [UIColor clearColor];
        label1.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0f];
        label2 =[[UILabel alloc] initWithFrame:CGRectMake(105, 15, 60, 20)];
        label2.backgroundColor = [UIColor clearColor];
        label2.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0f];
        
        rb1 = [[RadioButton alloc] initWithGroupId:@"first group" index:0];
        rb2 = [[RadioButton alloc] initWithGroupId:@"first group" index:1];
        
        rb1.frame = CGRectMake(10,15,22,22);
        rb2.frame = CGRectMake(80,15,22,22);
        
        _pickerViewContainer.frame = CGRectMake(6, 556, 308, 208);
    } else {
        container = [[UIView alloc] initWithFrame:CGRectMake(400, 250, 150, 30)];
        label1 =[[UILabel alloc] initWithFrame:CGRectMake(30, 5, 60, 20)];
        label1.backgroundColor = [UIColor clearColor];
        label1.font = [UIFont fontWithName:@"Helvetica Neue" size:17.0f];
        
        label2 =[[UILabel alloc] initWithFrame:CGRectMake(110, 5, 60, 20)];
        label2.backgroundColor = [UIColor clearColor];
        label2.font = [UIFont fontWithName:@"Helvetica Neue" size:17.0f];
        
        rb1 = [[RadioButton alloc] initWithGroupId:@"first group" index:0];
        rb2 = [[RadioButton alloc] initWithGroupId:@"first group" index:1];
        
        rb1.frame = CGRectMake(0,0,33,33);
        rb2.frame = CGRectMake(80,0,33,33);
        
        _pickerViewContainer.frame = CGRectMake(404, 840, 492, 350);
    }
    [self.view addSubview:container];
    [container addSubview:rb1];
    [container addSubview:rb2];
    [RadioButton addObserverForGroupId:@"first group" observer:self];
    container.hidden=NO;
    label1.text = @"Buy";
    [container addSubview:label1];
    label2.text = @"Sell";
    [container addSubview:label2];
    [rb1 handleButtonTap:self];
    
}

-(void)reloadData{
    self.searchStockNameList = [[NSMutableArray alloc]init];
    self.searchStockList = [[NSMutableArray alloc]init];
    shortName.text = @"";
    lotSize.text = @"";
    change.text = @"";
    lastPrice.text = @"";
    bidPrice.text = @"";
    askPrice.text = @"";
    accountNumber.text = @"";
    price.text = @"";
    quantity.text = @"";
    exchange.text = @"";
    [rb1 handleButtonTap:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.view setNeedsDisplay];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [accountNumber resignFirstResponder];
    [price resignFirstResponder];
    [quantity resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [self.viewButton endEditing:YES];
}

-(void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed{
    
}
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
    //[viewController.view setNeedsDisplay];
}




#pragma mark - Account List

-(void)loadAccountListfor:(NSString *)user withSession:(NSString *)session{
    parseURL = @"";
    NSString *soapRequest = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                             "<soap:Body>"
                             "<GetTradeAccount xmlns=\"http://OMS/\">"
                             "<UserSession>%@</UserSession>"
                             "<UserID>%@</UserID>"
                             "</GetTradeAccount>"
                             "</soap:Body>"
                             "</soap:Envelope>", session,user];
    NSLog(@"SoapRequest is %@" , soapRequest);
    NSURL *url =[NSURL URLWithString:@"http://192.168.174.109/oms/ws_rsoms.asmx?op=GetTradeAccount"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://OMS/GetTradeAccount" forHTTPHeaderField:@"SOAPAction"];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapRequest length]];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapRequest dataUsingEncoding:NSUTF8StringEncoding]];
    [self.searchStockList removeAllObjects];
    [self.searchStockNameList removeAllObjects];
    
    conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (conn) {
        self.buffer = [NSMutableData data];
    }
    
}

#pragma mark -  TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.searchStockList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Georgia" size:18.0f];
    cell.textLabel.text = [[self.searchStockNameList objectAtIndex:indexPath.row] capitalizedString];
    cell.detailTextLabel.text = [self.searchStockList objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSString *searchText = [self.searchStockList objectAtIndex:indexPath.row];
        [self.searchDisplayController setActive:NO animated:YES];
        NSLog(@"Selected Row Index Path : %@",searchText);
        parseURL = @"";
        self.stockCode = searchText;
        NSString *soapRequest = [NSString stringWithFormat:
                                 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                 "<soap:Body>"
                                 "<GetRicInfoFromDatabase xmlns=\"http://OMS/\">"
                                 "<RicCode>%@</RicCode>"
                                 "</GetRicInfoFromDatabase>"
                                 "</soap:Body>"
                                 "</soap:Envelope>", searchText];
        NSLog(@"SoapRequest is %@" , soapRequest);
        NSURL *url =[NSURL URLWithString:@"http://192.168.174.109/oms/ws_rsoms.asmx?op=GetRicInfoFromDatabase"];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://OMS/GetRicInfoFromDatabase" forHTTPHeaderField:@"SOAPAction"];
        NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapRequest length]];
        [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapRequest dataUsingEncoding:NSUTF8StringEncoding]];
        [self.searchStockList removeAllObjects];
        [self.searchStockNameList removeAllObjects];
        
        conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
        if (conn) {
            self.buffer = [NSMutableData data];
        }
    }
}

#pragma mark - SearchBar


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self filterContentForSearch:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}



-(void)filterContentForSearch:(NSString *)searchText scope:(NSString *)scope{
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    //self.searchStockList = [self.stocklList filteredArrayUsingPredicate:predicate];
    parseURL = @"";
    NSString *soapRequest = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                             "<soap:Body>"
                             "<SearchCounterByName xmlns=\"http://www.ifis.com.sg/\">"
                             "<SearchKey>%@</SearchKey>"
                             "<Exchange>%@</Exchange>"
                             "<Limit>20</Limit>"
                             "<Login></Login>"
                             "<Pwd></Pwd>"
                             "</SearchCounterByName>"
                             "</soap:Body>"
                             "</soap:Envelope>", searchText,marketEx];
    NSLog(@"SoapRequest is %@" , soapRequest);
    NSURL *url =[NSURL URLWithString:@"http://ifis.com.sg/CodeDbWS/Service.asmx?op=SearchCounterByName"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://www.ifis.com.sg/SearchCounterByName" forHTTPHeaderField:@"SOAPAction"];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapRequest length]];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapRequest dataUsingEncoding:NSUTF8StringEncoding]];
    [self.searchStockList removeAllObjects];
    [self.searchStockNameList removeAllObjects];
    
    conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (conn) {
        self.buffer = [NSMutableData data];
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
    
    //To find the base request
    if ([elementName isEqualToString:@"s:AttributeType"]) {
        if ([[attributeDict objectForKey:@"rs:basetable"] isEqualToString:@"CodeTable"]) {
            parseURL = @"searchBar";
        }
        else if ([[attributeDict objectForKey:@"rs:basetable"] isEqualToString:@"STOCKTABLE"]) {
            parseURL = @"searchStock";
        }
        else if ([[attributeDict objectForKey:@"rs:basetable"] isEqualToString:@"OMS_TRADE_ACCOUNT"]){
            parseURL = @"accountList";
        }
    }
    
    //parse the data
    if ([parseURL isEqualToString:@"searchBar"]) {
        
        if ([elementName isEqualToString:@"z:row"]) {
            //Add arrribute value to array
            [self.searchStockList addObject:[attributeDict objectForKey:@"RicCode"]];
            [self.searchStockNameList addObject:[attributeDict objectForKey:@"ShortName"]];
        }
        [[self.searchDisplayController searchResultsTableView]reloadData];
    }
    else if ([parseURL isEqualToString:@"searchStock"]) {
        if ([elementName isEqualToString:@"z:row"]) {
            shortName.text = [attributeDict objectForKey:@"SHORT_NAME"];
            lotSize.text = [attributeDict objectForKey:@"LOT_SIZE"];
            change.text = [attributeDict objectForKey:@""];
            lastPrice.text = [attributeDict objectForKey:@"LAST_DONE_PRICE"];
            bidPrice.text = [attributeDict objectForKey:@"BID_PRICE"];
            askPrice.text = [attributeDict objectForKey:@"ASK_PRICE"];
            exchange.text = [attributeDict objectForKey:@"EXCHANGE"];
            self.currency = [attributeDict objectForKey:@"CURRENCY_NAME"];
            self.exchangeRate = [attributeDict objectForKey:@"EXCHANGE_RATE"];
            
        }
    }
    else if ([parseURL isEqualToString:@"accountList"]) {
        [accountDict setValue:@"" forKey:@" Select Account"];
        if ([elementName isEqualToString:@"z:row"]) {
            [accountDict setValue:[attributeDict objectForKey:@"TRADE_ACC_ID"] forKey:[attributeDict objectForKey:@"TRADE_ACC_NAME"]];
            accountList =[[[accountDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
            [[self picker]reloadAllComponents];
        }
        
    }
}


#pragma mark -  RadioButton

-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId{
    if (index == 0) {
        [submit setTitle:@"BUY" forState:UIControlStateNormal];
        submit.backgroundColor = [UIColor colorWithRed:64.0f/255.0f green:177.0f/255.0f blue:64.0f/255.0f alpha:1.0f];
        self.side = @"1";
    }
    else if (index == 1){
        [submit setTitle:@"SELL" forState:UIControlStateNormal];
        submit.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:110.0f/255.0f blue:118.0f/255.0f alpha:1.0f];
        self.side =@"2";
    }
    
    NSLog(@"changed to %lu in %@",(unsigned long)index,groupId);
}


#pragma mark - pickerView

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [accountList count];
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return[accountList objectAtIndex:row];
}
-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (row == 0) {
        accountNumber.text=@"";
    }
    else{
        accountNumber.text=[accountList objectAtIndex:row];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)CancelPic:(id)sender {
    [UIView beginAnimations:Nil context:NULL];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        _pickerViewContainer.frame = CGRectMake(6, 556, 301, 208);
        [UIView setAnimationDuration:0.3];
    }
    else{
        container.hidden=NO;
        _pickerViewContainer.frame = CGRectMake(404, 853, 492, 350);
        [UIView setAnimationDuration:0.5];
    }
    
    [UIView commitAnimations];
    
}


- (IBAction)accountPicker:(id)sender {
    [UIView beginAnimations:Nil context:NULL];
    [accountNumber resignFirstResponder];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        _pickerViewContainer.frame = CGRectMake(6, 290, 308, 208);
        [UIView setAnimationDuration:0.3];
    }
    else{
        container.hidden=YES;
        _pickerViewContainer.frame = CGRectMake(404, 240, 492, 350);
        [UIView setAnimationDuration:0.5];
    }
    [self.picker selectRow:0 inComponent:0 animated:YES];
    [UIView commitAnimations];
    
}

#pragma mark - Submit

- (IBAction)submitOrder:(id)sender {
    if (!([accountNumber.text isEqualToString:@""])
        && !([price.text isEqualToString:@""])
        && !([quantity.text isEqualToString:@""])
        && !([exchange.text isEqualToString:@""])){
        [self performSegueWithIdentifier:@"orderConfirmation" sender:sender];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    orderConfirmationViewController *vc = (orderConfirmationViewController *)segue.destinationViewController;
    vc.clientAccountValue = [accountDict objectForKey:accountNumber.text];
    vc.stockCodeValue = self.stockCode;
    vc.shortNameValue = shortName.text;
    vc.qtyValue = quantity.text;
    vc.orderPriceValue = price.text;
    vc.currencyValue = self.currency;
    vc.typeValue =submit.titleLabel.text;
    vc.routeDestValue = exchange.text;
    vc.orderEntry=self;
    vc.side = self.side;
    vc.exchange = exchange.text;
    vc.exchangeRate = self.exchangeRate;
}


//#pragma mark - DropDown
//
//- (IBAction)selectClicked:(id)sender {
//    NSArray * arr = [[NSArray alloc] init];
//    arr = [NSArray arrayWithObjects:@"Buy", @"Sell",nil];
//    NSArray * arrImage = [[NSArray alloc] init];
//    //arrImage = [NSArray arrayWithObjects:[nil];
//    if(dropDown == nil) {
//        CGFloat f = 75;
//        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :arrImage :@"down"];
//        dropDown.delegate = self;
//    }
//    else {
//        [dropDown hideDropDown:sender];
//        [self rel];
//    }
//}
//
//- (IBAction)accounts:(id)sender {
//    NSArray * arr = [[NSArray alloc] init];
//    arr = [NSArray arrayWithObjects:@"Account 1", @"Account 2",@"Account 3",nil];
//    NSArray * arrImage = [[NSArray alloc] init];
//    //arrImage = [NSArray arrayWithObjects:[nil];
//    if(dropDown == nil) {
//        CGFloat f = 75;
//        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :arrImage :@"down"];
//        dropDown.delegate = self;
//    }
//    else {
//        [dropDown hideDropDown:sender];
//        [self rel];
//    }
//}
//
//
//- (void) niDropDownDelegateMethod: (NIDropDown *) sender {
//    [self rel];
//}
//
//-(void)rel{
//    //    [dropDown release];
//    dropDown = nil;
//}


@end
