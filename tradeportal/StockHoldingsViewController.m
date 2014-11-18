//
//  StockHoldingsViewController.m
//  tradeportal
//
//  Created by Nagarajan Sathish on 10/11/14.
//
//

#import "StockHoldingsViewController.h"
#import "StockHoldingsTableViewCell.h"
#import <QuartzCore/QuartzCore.h>


@interface StockHoldingsViewController (){
    BOOL resultFound;
}

@property (strong, nonatomic) NSMutableData *buffer;
@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSString *parseURL;
@property (strong, nonatomic) NSURLConnection *conn;

@end

@implementation StockHoldingsViewController

@synthesize buffer,parseURL,parser,conn,clientAccount,stockCode,pickerViewContainer,searchAccount,tableView;
DataModel *dm;

- (void)viewDidLoad {
    [super viewDidLoad];
    stockArray = [[NSMutableArray alloc]init];
    stockList = [[NSMutableArray alloc]init];
    accountList = [[NSMutableArray alloc]init];
    accountDict = [[NSMutableDictionary alloc]init];
    
    // Load Account List
    [self loadAccountListfor:dm.userID withSession:dm.sessionID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [stockList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    StockHoldingsTableViewCell *cell = (StockHoldingsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"StockHoldingsTableViewCell"];
    
    if(cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StockHoldingsTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if([stockList count]>0){
        [[cell stockName] setText:[[stockList objectAtIndex:[indexPath row]]stockName]];
        [[cell stockCode] setText:[[stockList objectAtIndex:[indexPath row]]stockCode]];
        [[cell location] setText:[[stockList objectAtIndex:[indexPath row]]stockLocation]];
        [[cell totalStock] setText:[[stockList objectAtIndex:[indexPath row]]totalStock]];
        
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


#pragma mark - Account List

-(void)loadAccountListfor:(NSString *)user withSession:(NSString *)session{
    parseURL = @"accountList";
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
    NSURL *url =[NSURL URLWithString:@"http://192.168.174.109/oms/ws_rsoms.asmx?op=GetTradeAccount"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://OMS/GetTradeAccount" forHTTPHeaderField:@"SOAPAction"];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapRequest length]];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapRequest dataUsingEncoding:NSUTF8StringEncoding]];
    //    [self.searchStockList removeAllObjects];
    //    [self.searchStockNameList removeAllObjects];
    
    conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
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
    
}

-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName
  namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict {
    //parse the data
    if ([parseURL isEqualToString:@"accountList"]) {
        if([elementName isEqualToString:@"GetTradeAccountResult"]){
            ////NSLog(@"%@",[attributeDict description]);
            resultFound=NO;
        }
        [accountDict setValue:@"" forKey:@" Select Account"];
        if ([elementName isEqualToString:@"z:row"]) {
            [accountDict setValue:[attributeDict objectForKey:@"TRADE_ACC_ID"] forKey:[attributeDict objectForKey:@"TRADE_ACC_NAME"]];
            accountList =[[[accountDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
            [[self accountPicker]reloadAllComponents];
        }
        
    }
    else if ([parseURL isEqualToString:@"loadStocks"]) {
        if([elementName isEqualToString:@"GetCustodyStockLocationDetailsResult"]){
            ////NSLog(@"%@",[attributeDict description]);
            resultFound=NO;
        }
        if ([elementName isEqualToString:@"z:row"]) {
            StockHoldingsDataModel *stock = [[StockHoldingsDataModel alloc]init];
            stock.stockCode = [attributeDict objectForKey:@"RICCODE"];
            stock.stockLocation = [attributeDict objectForKey:@"STOCK_LOCATION"];
            stock.stockName = [attributeDict objectForKey:@"STOCK_NAME"];
            stock.totalStock = [attributeDict objectForKey:@"TOTAL"];
            
            [stockList addObject:stock];
            [stockArray addObject:stock];
        }
        [tableView reloadData];
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

#pragma mark - pickerView

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30.0f;
}
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
    
    if([[accountList objectAtIndex:row] isEqualToString:@" Select Account"]){
        [clientAccount setTitle:@"" forState:UIControlStateNormal];
    }
    else{
        [clientAccount setTitle:[accountList objectAtIndex:row] forState:UIControlStateNormal];
    }
}

- (IBAction)CancelPic:(id)sender {
    [UIView beginAnimations:Nil context:NULL];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        pickerViewContainer.frame = CGRectMake(6, 606, 301, 208);
        [UIView setAnimationDuration:0.3];
    }
    else{
        pickerViewContainer.frame = CGRectMake(404, 853, 492, 350);
        [UIView setAnimationDuration:0.5];
    }
    
    [UIView commitAnimations];
    [self LoadStocks:sender];
    [searchAccount resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == searchAccount){
        [self CancelPic:self];
    }
    [self.view endEditing:YES];
    return YES;
}

- (IBAction)AccountPicker:(id)sender {
    [self.view endEditing:YES];    [UIView beginAnimations:Nil context:NULL];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        pickerViewContainer.frame = CGRectMake(6, 106, 308, 208);
        [UIView setAnimationDuration:0.3];
    }
    else{
        pickerViewContainer.frame = CGRectMake(404, 240, 492, 350);
        [UIView setAnimationDuration:0.5];
    }
    [self.accountPicker selectRow:0 inComponent:0 animated:YES];
    [UIView commitAnimations];
    [searchAccount becomeFirstResponder];
    [self SearchAccount];
    
}

-(IBAction)SearchAccount{
    accountList =[[[accountDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
    NSArray *account = [[NSArray alloc]initWithArray:accountList copyItems:YES];
    [accountList removeAllObjects];
    if ([searchAccount.text isEqualToString:@""]) {
        accountList =[[[accountDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
        
    } else {
        NSString *searchText = searchAccount.text;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
        [accountList addObjectsFromArray:[account filteredArrayUsingPredicate:predicate]];
    }
    [[self accountPicker]reloadAllComponents];
    if ([accountList count]>0) {
        if([[accountList objectAtIndex:0] isEqualToString:@" Select Account"]){
            [clientAccount setTitle:@"" forState:UIControlStateNormal];
        }
        else{
            [clientAccount setTitle:[accountList objectAtIndex:0] forState:UIControlStateNormal];
        }
    }
    else {
        [clientAccount setTitle:@"" forState:UIControlStateNormal];
    }
}


#pragma mark - Load Stocks
- (void)LoadStocks:(id)sender {
    self.parseURL = @"loadStocks";
    NSString *account = [accountDict objectForKey:clientAccount.titleLabel.text];
    NSString *soapRequest = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                             "<soap:Body>"
                             "<GetCustodyStockLocationDetails xmlns=\"http://OMS/\">"
                             "<PUserSession>%@</PUserSession>"
                             "<PClientAccount>%@</PClientAccount>"
                             "<PRicCode></PRicCode>"
                             "</GetCustodyStockLocationDetails>"
                             "</soap:Body>"
                             "</soap:Envelope>", dm.sessionID,account];
    //NSLog(@"SoapRequest is %@" , soapRequest);
    NSURL *url =[NSURL URLWithString:@"http://192.168.174.109/oms/ws_rsoms.asmx?op=GetCustodyStockLocationDetails"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://OMS/GetCustodyStockLocationDetails" forHTTPHeaderField:@"SOAPAction"];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapRequest length]];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapRequest dataUsingEncoding:NSUTF8StringEncoding]];
    [stockList removeAllObjects];
    [stockArray removeAllObjects];
    conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (conn) {
        buffer = [NSMutableData data];
    }
}

- (IBAction)SearchStocks:(id)sender {
    [stockList removeAllObjects];
    NSString *searchText = stockCode.text;
    if([searchText isEqualToString:@""]){
        [stockList addObjectsFromArray:stockArray];
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.stockCode contains[c] %@", searchText];
        [stockList addObjectsFromArray:[stockArray filteredArrayUsingPredicate:predicate]];
    }
    [tableView reloadData];
}

@end
