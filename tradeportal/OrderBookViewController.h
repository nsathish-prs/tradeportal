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
    NSMutableArray *exeOrderList;
}


@property(nonatomic,assign) NSMutableArray *orders;
@property(assign, nonatomic)NSMutableArray *orderList;
@property(strong, nonatomic)NSMutableArray *exeOrderList;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;


-(void)loadOrders;
-(void)reloadTableData;

- (IBAction)capitalize:(id)sender;
- (IBAction)indexChanged:(UISegmentedControl *)sender;
- (IBAction)stockSearch:(id)sender;
- (IBAction)sort:(UIButton *)sender;
@end
