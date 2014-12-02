//
//  OrderBookViewController.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 23/10/14.
//
//

#import <Foundation/Foundation.h>
#import "OrderBookModel.h"
#import "DataModel.h"
#import "StockHoldingsTableViewCell.h"

@interface OrderBookViewController : UITableViewController<UITextFieldDelegate,NSXMLParserDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *orders;
    NSMutableArray *orderList;
}


@property(nonatomic,assign) NSMutableArray *orders;
@property(assign, nonatomic)NSMutableArray *orderList;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *orderBy;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;

-(void)loadOrders;
- (IBAction)indexChanged:(UISegmentedControl *)sender;
-(void)reloadTableData;
- (IBAction)stockSearch:(id)sender;
@end
