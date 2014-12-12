//
//  orderEntryViewController.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 10/10/14.
//
//

#import <UIKit/UIKit.h>
//#import "NIDropDown.h"

@class RadioButton;

@interface orderEntryViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UISearchDisplayDelegate,UITabBarControllerDelegate, UISearchBarDelegate,UITableViewDelegate,NSXMLParserDelegate,UISearchControllerDelegate>
{
    NSMutableArray *radioButtons;
    NSMutableArray *accountList;
    NSDictionary *accountDict;
    BOOL flag;
}
- (IBAction)submitOrder:(id)sender;
-(void)reloadData;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic,strong)IBOutlet UIButton *submit;
@property(nonatomic,strong)IBOutlet UITextField *quantity;
@property(nonatomic,strong)IBOutlet UITextField *price;
@property(weak,nonatomic) IBOutlet UIButton *btnSelect;
@property(nonatomic,strong)IBOutlet UILabel *lastPrice;
@property(nonatomic,strong)IBOutlet UILabel *change;
@property(nonatomic,strong)IBOutlet UILabel *shortName;
@property(nonatomic,strong)IBOutlet UILabel *lotSize;
@property(nonatomic,strong)IBOutlet UILabel *bidPrice;
@property(nonatomic,strong)IBOutlet UILabel *askPrice;
@property(nonatomic,strong)IBOutlet UILabel *exchange;
@property(nonatomic,strong)NSString *marketEx;
@property (weak, nonatomic) IBOutlet UIView *container;
@property(assign,nonatomic)BOOL flag;


@end
