//
//  LoginViewController.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 8/10/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface LoginViewController : UIViewController<UIGestureRecognizerDelegate,NSXMLParserDelegate>

-(IBAction)login:(id)sender;
-(void)dismissView;

@property(nonatomic,weak)IBOutlet UITextField *uname1;
@property(nonatomic,strong)IBOutlet UITextField *upwd;
@property (strong, nonatomic) NSMutableData *buffer;
@property (strong, nonatomic) NSString *parseURL;
@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSURLConnection *conn;
@property(strong,nonatomic)IBOutlet UILabel *error;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner1;


@end
