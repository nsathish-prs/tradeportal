//
//  ChangeServiceViewController.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 8/12/14.
//
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

@interface ChangeServiceViewController : UIViewController

@property (strong, nonatomic)NSString *path;
@property (strong, nonatomic)NSMutableDictionary *url;
@property (weak, nonatomic) IBOutlet UITextField *protocol;
@property (weak, nonatomic) IBOutlet UITextField *ip;
@property (weak, nonatomic) IBOutlet UITextField *domain;
@property (weak, nonatomic) IBOutlet UITextField *service;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property(strong,nonatomic)IBOutlet UIViewController *settings;


- (IBAction)setDefault:(id)sender;
- (IBAction)saveChanges:(id)sender;
- (IBAction)dismissView:(id)sender;

@end
