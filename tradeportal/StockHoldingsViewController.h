//
//  StockHoldingsViewController.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 10/11/14.
//
//

#import <UIKit/UIKit.h>
#import "DataModel.h"
#import "StockHoldingsDataModel.h"


@interface StockHoldingsViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate,UIPickerViewAccessibilityDelegate>{
 
    NSMutableArray *accountList;
    NSMutableDictionary *accountDict;
    NSMutableArray *stockList;
    NSMutableArray *stockArray;
}

@property (weak, nonatomic) IBOutlet UIButton *clientAccount;
@property (weak, nonatomic) IBOutlet UITextField *stockCode;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(weak,nonatomic)NSString *cAccount;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (void)LoadStocksForAccount:(NSString *)account ;
- (IBAction)SearchStocks:(id)sender;
@end
