//
//  LoginViewController.h
//  tradeportal
//
//  Created by intern on 8/10/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface LoginViewController : UIViewController

-(IBAction)login:(id)sender;


@property(nonatomic,weak)IBOutlet UITextField *uname;
@property(nonatomic,weak)IBOutlet UITextField *pwd;
@property (strong, nonatomic) NSMutableData *buffer;
@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSURLConnection *conn;
@property(strong,nonatomic)IBOutlet UILabel *error;

@end
