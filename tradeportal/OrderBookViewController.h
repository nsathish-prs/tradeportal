//
//  OrderBookViewController.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 23/10/14.
//
//

#import <Foundation/Foundation.h>
#import "OrderBookModel.h"
#import "DataModel.h"

@interface OrderBookViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *orders;
    NSMutableArray *orderList;
}


@property(nonatomic,assign) NSMutableArray *orders;
@property(assign, nonatomic)NSMutableArray *orderList;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

-(void)loadOrders;
- (IBAction)indexChanged:(UISegmentedControl *)sender;

@end
