//
//  SettingsViewController.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 4/11/14.
//
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@interface SettingsViewController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate,UITabBarDelegate,UITabBarControllerDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
-(IBAction)dismissView;

@end
