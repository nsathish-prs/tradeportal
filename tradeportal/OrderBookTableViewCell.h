//
//  OrderBookTableViewCell.h
//  tradeportal
//
//  Created by intern on 27/10/14.
//
//

#import <UIKit/UIKit.h>

@interface OrderBookTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *ShortName;
@property (weak, nonatomic) IBOutlet UILabel *side;
@property (weak, nonatomic) IBOutlet UILabel *quantity;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *status;
@end
