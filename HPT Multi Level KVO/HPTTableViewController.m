//
//  HPTTableViewController.m
//  HPT Multi Level KVO
//
//  Created by Jakub Hladík on 18.04.13.
//  Copyright (c) 2013 Hippotaps s.r.o. All rights reserved.
//

#import "HPTTableViewController.h"
#import "HPTDataService.h"
#import "HPTCell.h"

@interface HPTTableViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation HPTTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[HPTDataService sharedService] removeObserver:self forKeyPath:@"dataArray"];
    
    TRC_EXIT;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"KVO Demo";
    [self.tableView registerClass:[HPTCell class] forCellReuseIdentifier:@"Cell"];
    
    self.dataArray = [HPTDataService sharedService].dataArray;
    
    [[HPTDataService sharedService] addObserver:self
                                     forKeyPath:@"dataArray"
                                        options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"dataArray"]) {
        NSIndexSet *set = change[NSKeyValueChangeIndexesKey];
        NSKeyValueChange valueChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
        NSArray *new = change[NSKeyValueChangeNewKey];

        switch (valueChange) {
            case NSKeyValueChangeInsertion:
                [self addObject:new.lastObject atIndex:set];
                break;
            case NSKeyValueChangeRemoval:
                ;
                break;
            case NSKeyValueChangeReplacement:
                ;
                break;
            case NSKeyValueChangeSetting:
                self.dataArray = [new mutableCopy];
                [self.tableView reloadData];
                break;
            default:
                break;
        }
        
        TRC_LOG(@"%@, %d, %@", set, valueChange, new);
        
        [self.tableView reloadData];
    }
}

- (void)addObject:(id)object atIndex:(NSIndexSet *)set
{
    ASSERT_MAIN_THREAD;
    
    [self.dataArray insertObject:object atIndex:set.firstIndex];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:set.firstIndex inSection:0]]
                          withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
}

- (void)removeObjectAtIndex:(NSIndexSet *)set
{
    ASSERT_MAIN_THREAD;
    
    [self.dataArray removeObjectAtIndex:set.firstIndex];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:set.firstIndex inSection:0]]
                          withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d:%d", indexPath.section, indexPath.row];
    cell.detailTextLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
