//
//  OrderBookModel.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 28/10/14.
//
//

#import <Foundation/Foundation.h>

@interface OrderBookModel : NSObject{
    NSString *refNo;
    NSString *clientAccount;
    NSString *stockCode;
    NSString *orderPrice;
    NSString *orderQty;
    NSString *qtyFilled;
    NSString *status;
    NSString *desc;
    NSString *exchange;
    NSString *orderType;
    NSString *avgPrice;
    NSDate *orderDate;
    NSString *currency;
    
}
@property(nonatomic,strong)NSString *refNo;
@property(nonatomic,strong)NSString *clientAccount;
@property(nonatomic,strong)NSString *stockCode;
@property(nonatomic,strong)NSString *orderPrice;
@property(nonatomic,strong)NSString *orderQty;
@property(nonatomic,strong)NSString *status;
@property(nonatomic,strong)NSString *qtyFilled;
@property(nonatomic,strong)NSString *desc;
@property(nonatomic,strong)NSString *exchange;
@property(nonatomic,strong)NSString *orderType;
@property(nonatomic,strong)NSString *avgPrice;
@property(nonatomic,strong)NSDate *orderDate;
@property(nonatomic,strong)NSString *currency;

@end
