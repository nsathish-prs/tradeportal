//
//  OrderBookTableViewCell.m
//  tradeportal
//
//  Created by Nagarajan Sathish on 27/10/14.
//
//

#import "OrderBookTableViewCell.h"

@implementation OrderBookTableViewCell

@synthesize stockCode,side,qtyFilled,quantity,price,status;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
