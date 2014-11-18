//
//  OrderBookModel.m
//  tradeportal
//
//  Created by Nagarajan Sathish on 28/10/14.
//
//

#import "OrderBookModel.h"

@implementation OrderBookModel


@synthesize clientAccount,desc,orderPrice,orderQty,qtyFilled,refNo,status,stockCode,avgPrice,exchange,currency,orderDate,orderType,side;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super init])){
        self.refNo = [aDecoder decodeObjectForKey:@"refNo"];
        self.clientAccount = [aDecoder decodeObjectForKey:@"clientAccount"];
        self.stockCode = [aDecoder decodeObjectForKey:@"stockCode"];
        self.orderPrice = [aDecoder decodeObjectForKey:@"orderPrice"];
        self.orderQty = [aDecoder decodeObjectForKey:@"orderQty"];
        self.qtyFilled = [aDecoder decodeObjectForKey:@"qtyFilled"];
        self.status = [aDecoder decodeObjectForKey:@"status"];
        self.desc = [aDecoder decodeObjectForKey:@"desc"];
        self.exchange = [aDecoder decodeObjectForKey:@"exchange"];
        self.orderType = [aDecoder decodeObjectForKey:@"orderType"];
        self.avgPrice = [aDecoder decodeObjectForKey:@"avgPrice"];
        self.orderDate = [aDecoder decodeObjectForKey:@"orderDate"];
        self.currency = [aDecoder decodeObjectForKey:@"currency"];
        self.side = [aDecoder decodeObjectForKey:@"side"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.refNo forKey:@"refNo"];
    [aCoder encodeObject:self.clientAccount forKey:@"clientAccount"];
    [aCoder encodeObject:self.stockCode forKey:@"stockCode"];
    [aCoder encodeObject:self.orderPrice forKey:@"orderPrice"];
    [aCoder encodeObject:self.orderQty forKey:@"orderQty"];
    [aCoder encodeObject:self.qtyFilled forKey:@"qtyFilled"];
    [aCoder encodeObject:self.status forKey:@"status"];
    [aCoder encodeObject:self.desc forKey:@"desc"];
    [aCoder encodeObject:self.exchange forKey:@"exchange"];
    [aCoder encodeObject:self.orderType forKey:@"orderType"];
    [aCoder encodeObject:self.avgPrice forKey:@"avgPrice"];
    [aCoder encodeObject:self.orderDate forKey:@"orderDate"];
    [aCoder encodeObject:self.currency forKey:@"currency"];
    [aCoder encodeObject:self.side forKey:@"side"];

}


@end
