//
//  orderEntryViewController.h
//  tradeportal
//
//  Created by intern on 10/10/14.
//
//

#import <UIKit/UIKit.h>
//#import "NIDropDown.h"

@class RadioButton;

@interface orderEntryViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UISearchDisplayDelegate,UITabBarControllerDelegate, UISearchBarDelegate,UITableViewDelegate>
{
    //DropDown
    IBOutlet UIButton *btnSelect;
    //NIDropDown *dropDown;
    //Radio Button
    NSMutableArray *radioButtons;
    NSMutableArray *accountList;
    NSDictionary *accountDict;
    
}
- (IBAction)CancelPic:(id)sender;
- (IBAction)submitOrder:(id)sender;
- (IBAction)accountPicker:(id)sender;

-(void)reloadData;
//-(IBAction)selectClicked:(id)sender;
//-(IBAction)accounts:(id)sender;
//-(void)rel;

@property (weak, nonatomic) IBOutlet UIView *pickerViewContainer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property(nonatomic,strong)IBOutlet UIButton *viewButton;
@property(nonatomic,strong)IBOutlet UIButton *submit;
@property(nonatomic,strong)IBOutlet UITextField *quantity;
@property(nonatomic,strong)IBOutlet UITextField *price;
@property(weak, nonatomic) IBOutlet UIPickerView *picker;
@property(strong,nonatomic)IBOutlet UITextField *accountNumber;

@property(nonatomic,strong)IBOutlet UILabel *lastPrice;
@property(nonatomic,strong)IBOutlet UILabel *change;
@property(nonatomic,strong)IBOutlet UILabel *shortName;
@property(nonatomic,strong)IBOutlet UILabel *lotSize;
@property(nonatomic,strong)IBOutlet UILabel *bidPrice;
@property(nonatomic,strong)IBOutlet UILabel *askPrice;
@property(nonatomic,strong)IBOutlet UILabel *exchange;
@property(nonatomic,strong)IBOutlet NSString *marketEx;


@end
