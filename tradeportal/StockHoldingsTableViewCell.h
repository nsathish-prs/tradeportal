//
//  StockHoldingsTableViewCell.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 10/11/14.
//
//

#import <UIKit/UIKit.h>

@interface StockHoldingsTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *stockName;
@property (weak, nonatomic) IBOutlet UILabel *stockCode;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *totalStock;
@property (weak, nonatomic) IBOutlet UILabel *noResults;
@end
