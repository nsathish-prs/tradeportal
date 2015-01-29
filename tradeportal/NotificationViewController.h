//
//  NotificationViewController.h
//  TradePortal
//
//  Created by intern on 22/1/15.
//
//

#import <UIKit/UIKit.h>

@interface NotificationViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIRefreshControl *refreshControl;

@end
