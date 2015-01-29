//
//  OrderDetailsTableViewCell.h
//  TradePortal
//
//  Created by Nagarajan Sathish on 6/1/15.
//
//

#import <UIKit/UIKit.h>

@interface OrderDetailsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *recId;
@property (weak, nonatomic) IBOutlet UILabel *msg;
@property (weak, nonatomic) IBOutlet UILabel *updatedBy;

@end
