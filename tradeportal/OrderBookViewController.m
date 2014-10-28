//
//  OrderBookViewController.m
//  tradeportal
//
//  Created by intern on 23/10/14.
//
//

#import "OrderBookViewController.h"

@implementation OrderBookViewController


-(void)viewDidLoad{
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self tableView]reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [courses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // NSDate *object = _objects[indexPath.row];
    //cell.textLabel.text = [object description];
    [[cell textLabel] setText:[[courses objectAtIndex:[indexPath row]]courseId]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        // NSDate *object = _objects[indexPath.row];
        //   [[segue destinationViewController] setDetailItem:object];
        [[segue destinationViewController] setEditingCourse:[courses objectAtIndex:[indexPath row]]];
    }
}


@end
