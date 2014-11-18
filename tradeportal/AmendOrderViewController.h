//
//  AmendOrderViewController.h
//  tradeportal
//
//  Created by intern on 13/11/14.
//
//

#import <UIKit/UIKit.h>

@interface AmendOrderViewController : UIViewController<NSXMLParserDelegate>

@property (weak, nonatomic) IBOutlet UILabel *orderQty;
@property (weak, nonatomic) IBOutlet UILabel *orderPrice;
@property (weak, nonatomic) IBOutlet UILabel *matchQty;
@property (weak, nonatomic) IBOutlet UITextField *nPrice;
@property (weak, nonatomic) IBOutlet UITextField *nQty;
@property (weak, nonatomic) IBOutlet UIButton *confirm;
@property (weak, nonatomic) IBOutlet UIButton *cancelAmend;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)cancelAmend:(id)sender;
- (IBAction)confirmAmend:(id)sender;
@end
