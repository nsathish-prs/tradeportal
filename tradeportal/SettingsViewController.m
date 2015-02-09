//
//  SettingsViewController.m
//  tradeportal
//
//  Created by Nagarajan Sathish on 4/11/14.
//
//

#import "SettingsViewController.h"
#import "DataModel.h"
#import "ChangePasswordViewController.h"
#import "ChangeServiceViewController.h"
#import "DetailViewController.h"

@interface SettingsViewController ()


@end

@implementation SettingsViewController

DataModel *dm;
@synthesize detailViewController,notifiSwitch;

#pragma mark - View Delegates

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tabBarController setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"refreshView" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    self.view.alpha = 1.0f;
    [super viewWillAppear:animated];
    
}

-(void)refreshView:(NSNotification *) notification{
    [self.tableView reloadData];
}
-(IBAction)dismissView{
    dm.sessionID=@"";
    dm.password=@"";
    [self dismissViewControllerAnimated:NO completion:nil];
    [[self navigationController]popToRootViewControllerAnimated:YES];
}
#pragma mark - Logout Action

-(void)showAction{
    
    NSString *actionSheetTitle = @"Confirm to Logout?"; //Action Sheet Title
    NSString *destructiveTitle = @"Logout"; //Action Sheet Button Titles
    NSString *cancelTitle = @"Cancel";
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:destructiveTitle
                                  otherButtonTitles:nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //NSLog(@"%ld",(long)buttonIndex);
    if (buttonIndex == 0) {
        dm.sessionID=@"";
        //        dm.userID=@"";
        dm.password=@"";
        [self dismissViewControllerAnimated:YES completion:nil];
        [[self navigationController]popToRootViewControllerAnimated:YES];
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else if (section ==1)
        return 2;
    else
        return 2;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    switch (section)
    {
        case 2:
            if (row == 0)
            {
                cell.detailTextLabel.text = dm.wifi;
            }
            break;

    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"%ld",(long)indexPath.section);
    if (indexPath.section == 0){
        if(indexPath.row == 0 ){
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                [self showAction];
            }
            else{
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                UIAlertView* logout = [[UIAlertView alloc] init];
                logout.alertViewStyle = UIAlertViewStyleDefault;
                [logout setDelegate:self];
                [logout setTag:0];
                [logout setMessage:@"Confirm to Logout"];
                [logout addButtonWithTitle:@"Confirm"];
                [logout addButtonWithTitle:@"Cancel"];
                [logout show];
            }
        }
    }
    else if (indexPath.section == 1){
        if(indexPath.row == 0 ){
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            [self performSegueWithIdentifier:@"changePass" sender:self];
        }
        else if(indexPath.row == 1 ){
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            [self performSegueWithIdentifier:@"changeService" sender:self];
        }
    }
    else if (indexPath.section == 2){
        if(indexPath.row == 0 ){
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
//            [self performSegueWithIdentifier:@"notify" sender:self];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 0) {
        if (buttonIndex == 0) {
            //confirm
            [self dismissView];
            
        }
        //    } else {
        //        if (buttonIndex == 0) {
        //            dm.currentInstallation.channels = [NSArray arrayWithObjects:@"",nil];
        //            [dm.currentInstallation saveInBackground];
        //            UIAlertView *toast = [[UIAlertView alloc]initWithTitle:nil message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        //            [toast show];
        //            int duration = 1.5;
        //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //                [toast dismissWithClickedButtonIndex:0 animated:YES];
        //            });
        //        }
    }
    
}

#pragma mark - TextField Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([[segue identifier] isEqualToString:@"changePass"]) {
            ChangePasswordViewController *vc = (ChangePasswordViewController *)segue.destinationViewController;
            vc.settings = self;
        }
        if ([[segue identifier] isEqualToString:@"changeService"]) {
            ChangeServiceViewController *vc = (ChangeServiceViewController *)segue.destinationViewController;
            vc.settings = self;
        }
    }
}



@end


