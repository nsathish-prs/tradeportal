//
//  OrderBookTableViewCell.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 27/10/14.
//
//

#import <UIKit/UIKit.h>

@interface OrderBookTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *stockCode;
@property (weak, nonatomic) IBOutlet UILabel *side;
@property (weak, nonatomic) IBOutlet UILabel *quantity;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (strong, nonatomic) IBOutlet UILabel *qtyFilled;

@end
