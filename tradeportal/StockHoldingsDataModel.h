//
//  StockHoldingsDataModel.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 10/11/14.
//
//

#import <Foundation/Foundation.h>

@interface StockHoldingsDataModel : NSObject{
    NSString *stockLocation;
    NSString *stockCode;
    NSString *stockName;
    NSString *totalStock;
    
}

@property(nonatomic,strong)NSString *stockLocation;
@property(nonatomic,strong)NSString *stockCode;
@property(nonatomic,strong)NSString *stockName;
@property(nonatomic,strong)NSString *totalStock;

@end
