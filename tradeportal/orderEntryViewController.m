//
//  orderEntryViewController.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 10/10/14.
//
//

#import "orderEntryViewController.h"
#import "orderConfirmationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RadioButton.h"
#import "DataModel.h"
#import "ClientAccountViewController.h"
#import "OrderEntryModel.h"

@interface orderEntryViewController ()

@property (strong, nonatomic) NSMutableData *buffer;
@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSString *parseURL;
@property (strong, nonatomic) NSURLConnection *conn;
@property(strong,nonatomic)NSString *stockCode;
@property(strong,nonatomic)NSString *currency;
@property(strong,nonatomic)NSString *exchangeRate;
@property(strong,nonatomic)NSString *type;
@property(strong,nonatomic)NSString *route;
@property(strong,nonatomic)NSString *side;
@property(strong, nonatomic) NSMutableArray *searchStockNameList;
@property(strong, nonatomic) NSMutableArray *searchStockList;


@end

@implementation orderEntryViewController

@synthesize lastPrice,change,shortName,lotSize,askPrice,bidPrice,price,quantity,exchange,buffer,conn,parser,parseURL,submit,marketEx,spinner,btnSelect,container,flag,originalView;

DataModel *dm;
OrderEntryModel *em;

UIButton *label1, *label2;
RadioButton *rb1, *rb2;
CGRect newFrame;
#pragma mark - View Delegates

- (void)viewDidLoad {
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    dm.tabBarController = [self tabBarController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldShouldReturn:) name:UIKeyboardWillHideNotification object:nil];
    [super viewDidLoad];
    [self reloadData];
    originalView = self.view;
    accountDict =[[NSMutableDictionary alloc]init];
    [self loadAccountListfor:dm.userID withSession:dm.sessionID];
    marketEx = @"SGX";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        label1  =[[UIButton alloc] initWithFrame:CGRectMake(35, 15, 40, 20)];
        label1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [label1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        label1.backgroundColor = [UIColor clearColor];
        [label1 addTarget:self action:@selector(radioLabel:) forControlEvents:UIControlEventTouchDown];
        
        label2 =[[UIButton alloc] initWithFrame:CGRectMake(105, 15, 40, 20)];
        label2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [label2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        label2.backgroundColor = [UIColor clearColor];
        [label2 addTarget:self action:@selector(radioLabel:) forControlEvents:UIControlEventTouchDown];
        
        rb1 = [[RadioButton alloc] initWithGroupId:@"first group" index:0];
        rb2 = [[RadioButton alloc] initWithGroupId:@"first group" index:1];
        
        rb1.frame = CGRectMake(10,15,22,22);
        rb2.frame = CGRectMake(80,15,22,22);
        
    }
    else {
        label1 =[[UIButton alloc] initWithFrame:CGRectMake(88, 17, 60, 20)];
        label1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [label1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        label1.backgroundColor = [UIColor clearColor];
        [label1 addTarget:self action:@selector(radioLabel:) forControlEvents:UIControlEventTouchDown];
        
        label2 =[[UIButton alloc] initWithFrame:CGRectMake(203, 17, 60, 20)];
        label2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [label2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        label2.backgroundColor = [UIColor clearColor];
        [label2 addTarget:self action:@selector(radioLabel:) forControlEvents:UIControlEventTouchDown];
        
        rb1 = [[RadioButton alloc] initWithGroupId:@"first group" index:0];
        rb2 = [[RadioButton alloc] initWithGroupId:@"first group" index:1];
        
        rb1.frame = CGRectMake(55,10,33,33);
        rb2.frame = CGRectMake(170,10,33,33);
        
    }
    [self.view addSubview:container];
    [container addSubview:rb1];
    [container addSubview:rb2];
    [RadioButton addObserverForGroupId:@"first group" observer:self];
    [label1 setTitle:@"Buy" forState:UIControlStateNormal];
    [container addSubview:label1];
    [label2 setTitle:@"Sell" forState:UIControlStateNormal];
    [container addSubview:label2];
    [rb1 handleButtonTap:self];
}

-(void)viewWillAppear:(BOOL)animated{
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    [self.view setNeedsDisplay];
    [super viewWillAppear:animated];
    if(em.flag){
        [self loadStockFor:em.searchStock];
        quantity.text = @"";
        price.text =@"";
        [btnSelect setTitle:em.accountNumber forState:UIControlStateNormal];
//        quantity.text = em.quantity;
//        if ([em.action isEqualToString:@"BUY"]) {
//            [rb1 handleButtonTap:self];
//        } else {
//            [rb2 handleButtonTap:self];
//        }
        em.flag = false;
    }
    if (flag) {
        [[[[[self tabBarController]tabBar]items]objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%d", [[[[[[self tabBarController]tabBar]items]objectAtIndex:1]badgeValue]intValue]+1]];
        
        [self.tabBarController setSelectedViewController:[[self.tabBarController viewControllers]objectAtIndex:1]];
        [self.tabBarController setSelectedIndex: 1];
    }
    flag=false;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


#pragma mark -  RadioButton

-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId{
    if (index == 0) {
        [submit setTitle:@"BUY" forState:UIControlStateNormal];
        submit.backgroundColor = iGREEN;
        self.side = @"1";
    }
    else if (index == 1){
        [submit setTitle:@"SELL" forState:UIControlStateNormal];
        submit.backgroundColor = iRED;
        self.side =@"2";
    }
    
    //NSLog(@"changed to %lu in %@",(unsigned long)index,groupId);
}

-(IBAction)radioLabel:(id)sender{
    if (sender == label1) {
        [rb1 handleButtonTap:self];
    } else {
        [rb2 handleButtonTap:self];
    }
}

#pragma mark - Clear Data
-(void)reloadData{
    self.searchStockNameList = [[NSMutableArray alloc]init];
    self.searchStockList = [[NSMutableArray alloc]init];
    shortName.text = @" ";
    lotSize.text = @"";
    change.text = @"-";
    lastPrice.text = @"";
    bidPrice.text = @"";
    askPrice.text = @"";
    [btnSelect setTitle:@"" forState:UIControlStateNormal];
    price.text = @"";
    quantity.text = @"";
    exchange.text = @"";
    [rb1 handleButtonTap:self];
}

- (IBAction)selectPrice:(UIButton *)sender {
    if (sender.tag == 11) {
        price.text = bidPrice.text;
    } else if (sender.tag == 12) {
        price.text = askPrice.text;
    } else if (sender.tag == 13) {
        price.text = lastPrice.text;
    }
}

#pragma mark - TextField Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [price resignFirstResponder];
    [quantity resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSCharacterSet* numberCharSet;
    if (textField == price) {
        numberCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
            NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            NSArray  *arrayOfString = [newString componentsSeparatedByString:@"."];
            if ([arrayOfString count] > 2 )
                return NO;
    }
    else{
        numberCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    }
    for (int i = 0; i < [string length]; ++i)
    {
        unichar c = [string characterAtIndex:i];
        if (![numberCharSet characterIsMember:c])
        {
            return NO;
        }
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
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
    
    if (textField == quantity) {
        quantity.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[quantity.text stringByReplacingOccurrencesOfString:@"," withString:@""]intValue]]];
    }
    if (textField == price) {
    price.text = [priceFormatter stringFromNumber:[NSNumber numberWithDouble:[price.text doubleValue]]];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (![[textField.text stringByReplacingOccurrencesOfString:@"," withString:@""]doubleValue] > 0) {
        textField.text =@"";
    }
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
                             "</soap:Envelope>",session,user];
    //NSLog(@"SoapRequest is %@" , soapRequest);
    NSString *urls = [NSString stringWithFormat:@"%@%s",dm.serviceURL,"op=GetTradeAccount"];
    NSURL *url =[NSURL URLWithString:urls];
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
        buffer = [NSMutableData data];
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
        //        NSLog(@"Selected Row Index Path : %@",indexPath);
        parseURL = @"";
        self.stockCode = searchText;
        [self loadStockFor:searchText];
    }
}


- (void) loadStockFor:(NSString*)searchText{
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
    //        NSLog(@"SoapRequest is %@" , soapRequest);
    
    NSString *urls = [NSString stringWithFormat:@"%@%s",dm.serviceURL,"op=GetRicInfoFromDatabase"];
    NSURL *url =[NSURL URLWithString:urls];
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
    spinner.hidesWhenStopped=YES;
    [spinner startAnimating];
    if (conn) {
        buffer = [NSMutableData data];
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.view = originalView;
    }
}


#pragma mark - SearchBar

-(IBAction)dismissFirstResponder:(id)sender{
    [self.view endEditing:YES];
    [self.navigationController.navigationBar endEditing:YES];
    originalView.alpha = 1.0f;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    originalView.alpha = 0.5f;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    originalView.alpha = 1.0f;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller  didShowSearchResultsTableView:(UITableView *)tableView
{
    if (OSVersionIsAtLeastiOS7() && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) { // These are custom methods I have in my .pch file
        if (([originalView isEqual:self.view])) {
            self.view = controller.searchResultsTableView;
            controller.searchResultsTableView.contentInset = UIEdgeInsetsMake(70, 0, 0, 0);
            [self.searchDisplayController.searchBar becomeFirstResponder];
            
        }
    }
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    if ([searchString isEqualToString:@""]) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.view = originalView;
        }
    }
    else{
        [self filterContentForSearch:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    }
    return YES;
}

-(void)filterContentForSearch:(NSString *)searchText scope:(NSString *)scope{
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
    //    NSLog(@"SoapRequest is %@" , soapRequest);
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
    //        NSLog(@"\n\nSoap Response is %@",theXML);
    [buffer setData:[theXML dataUsingEncoding:NSUTF8StringEncoding]];
    self.parser =[[NSXMLParser alloc]initWithData:buffer];
    [parser setDelegate:self];
    [parser parse];
    [spinner stopAnimating];
}

#pragma mark - XML Parser

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
            [self.searchStockList addObject:[attributeDict objectForKey:@"RicCode"]];
            [self.searchStockNameList addObject:[attributeDict objectForKey:@"ShortName"]];
        }
        [[self.searchDisplayController searchResultsTableView]reloadData];
    }
    else if ([parseURL isEqualToString:@"searchStock"]) {
        if ([elementName isEqualToString:@"z:row"]) {
            
            NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
            [priceFormatter setDecimalSeparator:@"."];
            [priceFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [priceFormatter setMaximumFractionDigits:3];
            [priceFormatter setMinimumFractionDigits:3];
            
            
            shortName.text = [attributeDict objectForKey:@"SHORT_NAME"];
            lotSize.text = [attributeDict objectForKey:@"LOT_SIZE"];
            //            change.text = [attributeDict objectForKey:@""];
            CGFloat lPrice = [[attributeDict objectForKey:@"LAST_DONE_PRICE"] floatValue];
            lastPrice.text = [priceFormatter stringFromNumber:[NSNumber numberWithFloat:lPrice]];
            CGFloat bPrice = [[attributeDict objectForKey:@"BID_PRICE"] floatValue];
            bidPrice.text = [priceFormatter stringFromNumber:[NSNumber numberWithFloat:bPrice]];
            CGFloat aPrice = [[attributeDict objectForKey:@"ASK_PRICE"] floatValue];
            askPrice.text = [priceFormatter stringFromNumber:[NSNumber numberWithFloat:aPrice]];
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
        }
    }
}


#pragma mark - Submit

- (IBAction)submitOrder:(id)sender {
    NSString *msg;
    if([exchange.text isEqualToString:@""]){
        msg = @"Please set Stock Symbol";
    }
    else if (btnSelect.titleLabel.text == nil){
        msg = @"Please Select Account No";
    }
    else if(([price.text isEqualToString:@""])
            || ([price.text isEqualToString:@"0.000"])){
        msg = @"Please enter price!";
        price.text = @"";
    }
    else if(([quantity.text isEqualToString:@""])
            || ([quantity.text isEqualToString:@"0"])){
        msg = @"Please enter Quantity";
        quantity.text = @"";
    }
    else{
        [self performSegueWithIdentifier:@"orderConfirmation" sender:sender];
    }
    if(msg != nil){
        UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [toast show];
        int duration = 1.5;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [toast dismissWithClickedButtonIndex:0 animated:YES];
        });
    }
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [self.view endEditing:YES];
    if ([[segue identifier] isEqualToString:@"clientAccount"]) {
        [self dismissFirstResponder:self];
        ClientAccountViewController *vc = (ClientAccountViewController *)segue.destinationViewController;
        vc.clientAccountOrder = self;
    }
    else{
        orderConfirmationViewController *vc = (orderConfirmationViewController *)segue.destinationViewController;
        vc.clientAccountValue = [accountDict objectForKey:btnSelect.titleLabel.text];
        vc.stockCodeValue = self.stockCode;
        vc.shortNameValue = shortName.text;
        vc.qtyValue = quantity.text;
        CGFloat oPrice = [price.text floatValue];
        vc.orderPriceValue = [[NSNumber numberWithFloat:oPrice]stringValue];
        vc.currencyValue = self.currency;
        vc.typeValue =submit.titleLabel.text;
        vc.routeDestValue = exchange.text;
        vc.orderEntry=self;
        vc.side = self.side;
        vc.exchange = exchange.text;
        vc.exchangeRate = self.exchangeRate;
    }
}



@end
