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
#import "TransitionDelegate.h"
#import "ChangeServiceViewController.h"

@interface SettingsViewController ()

@property (nonatomic, strong) TransitionDelegate *transitionController;

@end

@implementation SettingsViewController

DataModel *dm;
@synthesize transitionController;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tabBarController setDelegate:self];
    self.transitionController = [[TransitionDelegate alloc] init];
}

-(void)viewWillAppear:(BOOL)animated{
    self.view.alpha = 1.0f;
}

-(IBAction)showAction{
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self.view endEditing:YES];
    return YES;
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


//-(IBAction)changePassword {
//    SettingsViewController *lvc;
//    ChangePasswordViewController *cvc;
//    dm.toView=cvc;
//    dm.fromView = lvc;
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
//    vc.view.backgroundColor = [UIColor clearColor];
//    self.view.alpha = 0.5f;
//    [vc setTransitioningDelegate:transitionController];
//    vc.modalPresentationStyle= UIModalPresentationCustom;
//    [self presentViewController:vc animated:YES completion:nil];
//    
//}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"%ld",(long)indexPath.section);
    if (indexPath.section == 0){
        if(indexPath.row == 0 ){
            [self showAction];
        }
    }
//    else if (indexPath.section == 1){
//        if(indexPath.row == 0 ){
//            [self changePassword];
//        }
//    }
    
}

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
