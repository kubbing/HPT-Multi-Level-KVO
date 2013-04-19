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

- (id)valueForUndefinedKey:(NSString *)key
{
    NSUInteger index = [key integerValue];
    return self.dataArray[index];
}

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                           target:self
                                                                                           action:@selector(resetButtonAction:)];
    
    
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

#pragma mark - Actions

- (void)resetButtonAction:(id)sender
{
    [[HPTDataService sharedService] reset];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    ASSERT_MAIN_THREAD;
    
    if ([keyPath isEqualToString:@"dataArray"]) {
        NSIndexSet *set = change[NSKeyValueChangeIndexesKey];
        NSKeyValueChange valueChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
        NSArray *new = change[NSKeyValueChangeNewKey];

        switch (valueChange) {
            case NSKeyValueChangeInsertion:
                [self addObject:new.lastObject atIndex:set.lastIndex];
                break;
            case NSKeyValueChangeRemoval:
                [self removeObjectAtIndex:set.lastIndex];
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
    }
    else {
        TRC_OBJ(object);
    }
}

#pragma mark - Sections

- (void)addObject:(id)object atIndex:(NSUInteger)index
{
    ASSERT_MAIN_THREAD;
    
    [self.dataArray insertObject:object atIndex:index];
    
    [self.tableView beginUpdates];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:index]
                  withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    ASSERT_MAIN_THREAD;
    
    [self.dataArray removeObjectAtIndex:index];
    
    [self.tableView beginUpdates];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:index]
                  withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.dataArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[HPTDataService sharedService] randomTitle];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TRC_ENTRY;
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [[HPTDataService sharedService] randomPhone];
    
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
