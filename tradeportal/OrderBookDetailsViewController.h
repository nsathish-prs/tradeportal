//
//  OrderBookDetailsViewController.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 27/10/14.
//
//

#import <UIKit/UIKit.h>
#import "OrderBookModel.h"

@interface OrderBookDetailsViewController : UIViewController

@property(nonatomic,strong)OrderBookModel *order;


@property (weak, nonatomic) IBOutlet UILabel *refNo;
@property(nonatomic,strong) IBOutlet UILabel *clientAccount;
@property(nonatomic,strong) IBOutlet UILabel *stockCode;
@property(nonatomic,strong) IBOutlet UILabel *orderPrice;
@property(nonatomic,strong) IBOutlet UILabel *orderQty;
@property(nonatomic,strong) IBOutlet UILabel *status;
@property(nonatomic,strong) IBOutlet UILabel *qtyFilled;
@property(nonatomic,strong) IBOutlet UILabel *desc;
@property(nonatomic,strong) IBOutlet UILabel *exchange;
@property(nonatomic,strong) IBOutlet UILabel *orderType;
@property(nonatomic,strong) IBOutlet UILabel *avgPrice;
@property(nonatomic,strong) IBOutlet UILabel *orderDate;
@property(nonatomic,strong) IBOutlet UILabel *currency;



@end
