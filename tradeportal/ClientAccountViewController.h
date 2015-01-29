//
//  ClientAccountViewController.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 8/12/14.
//
//

#import <UIKit/UIKit.h>
#import "StockHoldingsViewController.h"
#import "orderEntryViewController.h"

@interface ClientAccountViewController : UIViewController<NSXMLParserDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,UITextFieldDelegate>

@property(nonatomic,strong)IBOutlet StockHoldingsViewController *clientAccountStock;
@property(nonatomic,strong)IBOutlet orderEntryViewController *clientAccountOrder;

@property (weak, nonatomic) IBOutlet UIView *clientAccountView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchAccount;



-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer;


@end
