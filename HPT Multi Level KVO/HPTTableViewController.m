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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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

- (void)objectRemovedAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
}

- (void)objectInsertedAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"dataArray"]) {
        
        NSIndexSet *set = change[NSKeyValueChangeIndexesKey];        
        NSKeyValueChange valueChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
        NSArray *newObject = change[NSKeyValueChangeNewKey];
        
//        if (valueChange == NSKeyValueChangeSetting ||
//            (newObject.count == 1 &&
//            [newObject.lastObject isKindOfClass:[NSArray class]])) {
//            
//        }
//        else {
//            TRC_ENTRY;
//        }
        
//        TRC_LOG(@"section [%d], change %d, total: %d",
//                set.lastIndex,
//                valueChange,
//                [self.dataArray count]);
        
        switch (valueChange) {
            case NSKeyValueChangeInsertion:
                [self addObject:[NSMutableArray array] atIndex:set.lastIndex];
                break;
            case NSKeyValueChangeRemoval:
                [self removeObjectAtIndex:set.lastIndex];
                break;
            case NSKeyValueChangeReplacement:
                ;
                break;
            case NSKeyValueChangeSetting:
                self.dataArray = [NSMutableArray array];
                [self removeAllObservers];
                [self.tableView reloadData];
                break;
            default:
                break;
        }
    }
    else {
        NSUInteger section = [keyPath integerValue];
        NSIndexSet *set = change[NSKeyValueChangeIndexesKey];
        NSKeyValueChange valueChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
        NSArray *newObject = change[NSKeyValueChangeNewKey];
        
//        TRC_LOG(@"[%d, %d], change %d, total: %d, new: %@",
//                section,
//                set.lastIndex,
//                valueChange,
//                [self.dataArray[section] count],
//                newObject.lastObject);
        
        switch (valueChange) {
            case NSKeyValueChangeInsertion:
            {
                NSMutableArray *array = self.dataArray[section];
                [array insertObject:newObject.lastObject atIndex:set.lastIndex];
                [self objectInsertedAtIndexPath:[NSIndexPath indexPathForRow:set.lastIndex inSection:section]];
                break;
            }
            case NSKeyValueChangeRemoval:
            {
                NSMutableArray *array = self.dataArray[section];
                [array removeObjectAtIndex:set.lastIndex];
                [self objectRemovedAtIndexPath:[NSIndexPath indexPathForRow:set.lastIndex inSection:section]];
                break;
            }
            case NSKeyValueChangeReplacement:
                ;
                break;
            case NSKeyValueChangeSetting:
                TRC_ENTRY;
                break;
            default:
                break;
        }
    }
}

#pragma mark - Sections

- (void)addObserverForKey:(NSString *)key
{
    fprintf(stderr, "add %d ", [key integerValue]);
    if ([key integerValue] == self.dataArray.count-1) {
        fprintf(stderr, "done\n");
        [[HPTDataService sharedService] addObserver:self
                                         forKeyPath:key
                                            options:NSKeyValueObservingOptionNew
                                            context:NULL];
        return;
    }
    fprintf(stderr, "\n");
}

- (void)removeObserverForKey:(NSString *)key
{
    fprintf(stderr, "rem %d ", [key integerValue]);
    if ([key integerValue] == self.dataArray.count-1) {
        fprintf(stderr, "done\n");
        [[HPTDataService sharedService] removeObserver:self
                                            forKeyPath:key
                                               context:NULL];
        return;
    }
    fprintf(stderr, "\n");
}

- (void)removeAllObservers
{
    for (NSUInteger i = 0; i < self.dataArray.count; i++) {
        [self removeObserverForKey:[@(i) description]];
    }
}

- (void)addObject:(id)object atIndex:(NSUInteger)index
{
    ASSERT_MAIN_THREAD;
    
    [self.dataArray insertObject:object atIndex:index];
    [self addObserverForKey:[@(index) description]];
    
    [self.tableView beginUpdates];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:index]
                  withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    ASSERT_MAIN_THREAD;
    
    [self removeObserverForKey:[@(index) description]];
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
    NSArray *array = self.dataArray[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
