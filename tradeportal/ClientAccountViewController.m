//
//  ClientAccountViewController.m
//  tradeportal
//
//  Created by Nagarajan Sathish on 8/12/14.
//
//

#import "ClientAccountViewController.h"
#import "ClientAccountTableViewCell.h"
#import "DataModel.h"

@interface ClientAccountViewController (){
    
}

@property (strong, nonatomic) NSMutableData *buffer;
@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSString *parseURL;
@property (strong, nonatomic) NSURLConnection *conn;



@end

@implementation ClientAccountViewController

@synthesize clientAccountOrder,clientAccountStock,buffer,parser,parseURL,conn,tableView,searchAccount,clientAccountView;
DataModel *dm;

#pragma mark - View Delegates

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor clearColor];
    clientAccountStock.view.alpha=0.5f;
    clientAccountOrder.view.alpha=0.5f;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    singleTapGestureRecognizer.cancelsTouchesInView = NO;
    
    [self.clientAccountView addGestureRecognizer:singleTapGestureRecognizer];
}

-(void)viewWillAppear:(BOOL)animated{
    [dm.accountList removeAllObjects];
    dm.accountList =[[[dm.accountDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
    
}

-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer{
    [self dismissViewControllerAnimated:YES completion:nil];
    clientAccountStock.view.alpha = 1.0f;
    [clientAccountStock.view setNeedsDisplay];
    clientAccountOrder.view.alpha = 1.0f;
    [clientAccountOrder.view setNeedsDisplay];
    
    [self.view endEditing:YES];
}

#pragma mark - Textfield Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([dm.accountList count]==0) {
        return 4;
    }

    return [dm.accountList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ClientAccountTableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[ClientAccountTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"Cell"];
    }
    if([dm.accountList count]>0){
    // Configure the cell.
    cell.accountNumber.text = [dm.accountList objectAtIndex:indexPath.row];
        if (indexPath.row==3) {
            cell.noResults.hidden=true;
        }
    }
    else{
        [[cell accountNumber] setText:@" "];
        if (indexPath.row==3) {
            cell.noResults.hidden=false;
            cell.userInteractionEnabled=NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)index{
    [clientAccountStock.clientAccount setTitle:[dm.accountList objectAtIndex:index.row] forState:UIControlStateNormal];
    [clientAccountStock LoadStocksForAccount:[dm.accountDict objectForKey:[dm.accountList objectAtIndex:index.row]]];
    [clientAccountOrder.btnSelect setTitle:[dm.accountList objectAtIndex:index.row] forState:UIControlStateNormal];
    
}

#pragma mark - Search Account

-(IBAction)SearchAccount{
    dm.accountList =[[[dm.accountDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
    NSArray *account = [[NSArray alloc]initWithArray:dm.accountList copyItems:YES];
    [dm.accountList removeAllObjects];
    if ([searchAccount.text isEqualToString:@""]) {
        dm.accountList =[[[dm.accountDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
        
    } else {
        NSString *searchText = searchAccount.text;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
        [dm.accountList addObjectsFromArray:[account filteredArrayUsingPredicate:predicate]];
    }
    [tableView reloadData];
}

@end
