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

@interface SettingsViewController ()


@end

@implementation SettingsViewController

DataModel *dm;

#pragma mark - View Delegates

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tabBarController setDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated{
    self.view.alpha = 1.0f;
    [super viewWillAppear:animated];
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

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"%ld",(long)indexPath.section);
    if (indexPath.section == 0){
        if(indexPath.row == 0 ){
            [self showAction];
        }
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
    if ([[segue identifier] isEqualToString:@"changePass"]) {
        ChangePasswordViewController *vc = (ChangePasswordViewController *)segue.destinationViewController;
        vc.settings = self;
    }
    if ([[segue identifier] isEqualToString:@"changeService"]) {
        ChangeServiceViewController *vc = (ChangeServiceViewController *)segue.destinationViewController;
        vc.settings = self;
    }
}


@end
