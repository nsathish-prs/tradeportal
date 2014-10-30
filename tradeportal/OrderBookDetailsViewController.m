//
//  OrderBookDetailsViewController.m
//  tradeportal
//
//  Created by Nagarajan Sathish on 27/10/14.
//
//

#import "OrderBookDetailsViewController.h"
#import "DataModel.h"

@interface OrderBookDetailsViewController ()

@end

@implementation OrderBookDetailsViewController

@synthesize order,refNo,clientAccount,stockCode,desc,exchange,orderType,status,orderQty,qtyFilled,orderPrice,avgPrice,orderDate,currency;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setGroupingSeparator:@","];
    [numberFormatter setGroupingSize:3];
    [numberFormatter setUsesGroupingSeparator:YES];
    [numberFormatter setDecimalSeparator:@"."];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:3];
    
    
    refNo.text = order.refNo;
    clientAccount.text = order.clientAccount;
    stockCode.text = order.stockCode;
    desc.text = order.desc;
    exchange.text = order.exchange;
    orderType.text = order.orderType;
    status.text = order.status;
    orderQty.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:[order.orderQty intValue]]];
    qtyFilled.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:[order.qtyFilled intValue]]];
    orderPrice.text = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[order.orderPrice doubleValue]]];
    avgPrice.text = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[order.avgPrice doubleValue]]];
    orderDate.text = [NSDateFormatter localizedStringFromDate:order.orderDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    currency.text = order.currency;
    
    
    if ([orderType.text isEqualToString:@"Buy"]) {
        orderType.textColor = iGREEN;
    }else if ([orderType.text isEqualToString:@"Sell"]){
        orderType.textColor = iRED;
    }


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
