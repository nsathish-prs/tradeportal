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


@interface StockHoldingsViewController : UIViewController<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate,UIPickerViewAccessibilityDelegate>{
 
    NSMutableArray *accountList;
    NSMutableDictionary *accountDict;
    NSMutableArray *stockList;
    NSMutableArray *stockArray;
}

@property (weak, nonatomic) IBOutlet UIView *pickerViewContainer;
@property (weak, nonatomic) IBOutlet UIButton *clientAccount;
@property (weak, nonatomic) IBOutlet UITextField *stockCode;
@property (weak, nonatomic) IBOutlet UITextField *searchAccount;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *accountPicker;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


- (IBAction)CancelPic:(id)sender;
- (IBAction)AccountPicker:(id)sender;
-(IBAction)SearchAccount;
- (void)LoadStocks:(id)sender;
- (IBAction)SearchStocks:(id)sender;
@end
