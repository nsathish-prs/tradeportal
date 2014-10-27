//
//  orderConfirmationViewController.h
//  tradeportal
//
//  Created by intern on 20/10/14.
//
//

#import <UIKit/UIKit.h>
#import "orderEntryViewController.h"

@interface orderConfirmationViewController : UIViewController

@property(nonatomic,strong)IBOutlet UILabel *clientAccount;
@property(nonatomic,strong)IBOutlet UILabel *stockCode;
@property(nonatomic,strong)IBOutlet UILabel *shortName;
@property(nonatomic,strong)IBOutlet UILabel *orderPrice;
@property(nonatomic,strong)IBOutlet UILabel *qty;
@property(nonatomic,strong)IBOutlet UILabel *totalAmount;
@property(nonatomic,strong)IBOutlet UILabel *currency;
@property(nonatomic,strong)IBOutlet UILabel *type;
@property(nonatomic,strong)IBOutlet UILabel *routeDest;
@property(nonatomic,strong)IBOutlet UITextField *password;
@property(nonatomic,strong)IBOutlet UIButton *confirm;
@property(nonatomic,strong)IBOutlet UIButton *cancel;


@property(nonatomic,strong)IBOutlet NSString *clientAccountValue;
@property(nonatomic,strong)IBOutlet NSString *stockCodeValue;
@property(nonatomic,strong)IBOutlet NSString *shortNameValue;
@property(nonatomic,strong)IBOutlet NSString *orderPriceValue;
@property(nonatomic,strong)IBOutlet NSString *qtyValue;
@property(nonatomic,strong)IBOutlet NSString *totalAmountValue;
@property(nonatomic,strong)IBOutlet NSString *currencyValue;
@property(nonatomic,strong)IBOutlet NSString *typeValue;
@property(nonatomic,strong)IBOutlet NSString *routeDestValue;
@property(nonatomic,strong)IBOutlet NSString *side;
@property(nonatomic,strong)IBOutlet NSString *exchange;
@property(nonatomic,strong)IBOutlet NSString *orderType;
@property(nonatomic,strong)IBOutlet NSString *timeInForce;
@property(nonatomic,strong)IBOutlet NSString *currencyCode;
@property(nonatomic,strong)IBOutlet NSString *exchangeRate;

@property(nonatomic,strong)IBOutlet orderEntryViewController *orderEntry;

- (IBAction)confirmPassword:(id)sender;
- (IBAction)cancelOrder:(id)sender;

@end
