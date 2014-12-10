//
//  ChangeServiceViewController.m
//  tradeportal
//
//  Created by intern on 8/12/14.
//
//

#import "ChangeServiceViewController.h"
#import "DataModel.h"
@interface ChangeServiceViewController ()

@end

@implementation ChangeServiceViewController


@synthesize url,protocol,ip,domain,path,settings,service;
DataModel *dm;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor clearColor];
    settings.view.alpha=0.5f;
    [self loadData];
}
-(void)loadData{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    path = [documentsDirectory stringByAppendingPathComponent:@"TradePortal.plist"];
    url = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    BOOL oldIP= [url objectForKey:@"ip"]!=nil;
    if (!oldIP) {
        [dm resetService];
        url = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    }
    else{
        protocol.placeholder = [url objectForKey:@"protocol"];
        ip.placeholder = [url objectForKey:@"ip"];
        domain.placeholder = [url objectForKey:@"domain"];
        service.placeholder = [url objectForKey:@"service"];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self.view endEditing:YES];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)setDefault:(id)sender {
    [dm resetService ];
    [self loadData];
    dm.serviceURL = [NSString stringWithFormat:@"%@://%@%@/%@",[url objectForKey:@"protocol"],[url objectForKey:@"ip"],[url objectForKey:@"domain"],[url objectForKey:@"service"]];
    //    NSLog(@"%@",dm.serviceURL);
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(dismissView:)
                                   userInfo:nil
                                    repeats:NO];
}

- (IBAction)saveChanges:(id)sender {
    
    if (![ip.text isEqualToString:@""]) {
        if ([ip.text isEqualToString:@"-"]) {
            [url setObject:@"" forKey:@"ip"];
        }
        else{
            [url setObject:[NSString stringWithString:ip.text] forKey:@"ip"];
        }
    }
    if (![domain.text isEqualToString:@""]) {
        if ([domain.text isEqualToString:@"-"]) {
            [url setObject:@"" forKey:@"domain"];
        }
        else{
        [url setObject:[NSString stringWithString:domain.text] forKey:@"domain"];
        }
    }
    if (![protocol.text isEqualToString:@""]) {
        if ([protocol.text isEqualToString:@"-"]) {
            [url setObject:@"" forKey:@"protocol"];
        }
        else{
        [url setObject:[NSString stringWithString:protocol.text] forKey:@"protocol"];
        }
    }
    if (![service.text isEqualToString:@""]) {
        if ([service.text isEqualToString:@"-"]) {
            [url setObject:@"" forKey:@"service"];
        }
        else{
        [url setObject:[NSString stringWithString:protocol.text] forKey:@"service"];
        }
    }
    [url writeToFile: path atomically:YES];
    dm.serviceURL = [NSString stringWithFormat:@"%@://%@%@/%@",[url objectForKey:@"protocol"],[url objectForKey:@"ip"],[url objectForKey:@"domain"],[url objectForKey:@"service"]];
    //    NSLog(@"%@",dm.serviceURL);

    [self dismissView:sender];
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    settings.view.alpha = 1.0f;
}
@end
