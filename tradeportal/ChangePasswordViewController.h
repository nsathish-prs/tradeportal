//
//  ChangePasswordViewController.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 4/11/14.
//
//

#import <UIKit/UIKit.h>

@interface ChangePasswordViewController : UIViewController<UITextFieldDelegate,NSXMLParserDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userID;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *nPassword;
@property (weak, nonatomic) IBOutlet UITextField *cPassword;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
- (IBAction)changePassword:(id)sender;
- (IBAction)dismissView:(id)sender;
@end
