//
//  OrderBookDetailsViewController.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 27/10/14.
//
//

#import <UIKit/UIKit.h>
#import "OrderBookModel.h"
#import "OrderBookViewController.h"

@interface OrderBookDetailsViewController : UIViewController<UIAlertViewDelegate,NSXMLParserDelegate>{
    
}

@property(nonatomic,strong)OrderBookModel *order;


@property (weak, nonatomic) IBOutlet UILabel *refNo;
@property(nonatomic,strong) IBOutlet UILabel *clientAccount;
@property(nonatomic,weak) IBOutlet UILabel *stockCode;
@property(nonatomic,weak) IBOutlet UILabel *orderPrice;
@property(nonatomic,weak) IBOutlet UILabel *orderQty;
@property(nonatomic,weak) IBOutlet UILabel *status;
@property(nonatomic,weak) IBOutlet UILabel *qtyFilled;
@property(nonatomic,weak) IBOutlet UILabel *desc;
@property(nonatomic,weak) IBOutlet UILabel *exchange;
@property(nonatomic,weak) IBOutlet UILabel *orderType;
@property(nonatomic,weak) IBOutlet UILabel *avgPrice;
@property(nonatomic,weak) IBOutlet UILabel *orderDate;
@property(nonatomic,weak) IBOutlet UILabel *currency;
@property(nonatomic,weak) IBOutlet UILabel *side;

@property (weak, nonatomic) IBOutlet UIView *options;
@property (weak, nonatomic) IBOutlet UIButton *edit;
@property (weak, nonatomic) IBOutlet UIButton *cancel;
- (IBAction)amendOrder:(id)sender;
- (IBAction)cancelOrder:(id)sender;

@property(nonatomic,strong)IBOutlet OrderBookViewController *orderBook;
@property(nonatomic,assign)Boolean flag;

@end
