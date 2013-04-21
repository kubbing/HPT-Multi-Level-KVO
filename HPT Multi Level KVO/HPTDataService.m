//
//  HPTDataService.m
//  HPT Multi Level KVO
//
//  Created by Jakub Hladík on 18.04.13.
//  Copyright (c) 2013 Hippotaps s.r.o. All rights reserved.
//

#import "HPTDataService.h"

@implementation HPTDataService
{
    NSTimer *_timer;
}

- (NSArray *)titleArray
{
    return @[@"Apple",
                        @"Samsung",
                        @"LG",
                        @"Nokia",
                        @"BB",
                        @"Hippotaps",
                        @"Motorola",
                        @"Sony",
                        @"Ericsson",
                        @"Panasonic"
                        ];
}

- (NSString *)randomTitle
{
    NSArray *titleArray = [self titleArray];
    NSUInteger count = titleArray.count;
    
    return titleArray[rand() % count];
}

- (NSArray *)phoneArray
{
    NSArray *array = @[@"Sony Ericsson Moment Slide Plus",
                       @"HTC Moment Touch",
                       @"Sony Ericsson Legend 3D G1",
                       @"Samsung Infuse Slide One",
                       @"HTC Sensation Optimus Prime G2",
                       @"LG Aria Black 4G+ G1",
                       @"Samsung Aria Incredible Pro",
                       @"Acer Devour Vibrant",
                       @"HTC Rezound Black 4G",
                       @"LG Xperia Slide V 4G",
                       @"Acer Wildfire Vivid II",
                       @"LG Aria Epic Plus V One",
                       @"HTC Dream Vibrant II Prime Pro",
                       @"HTC Defy Touch One Z S",
                       @"LG Infuse Vivid",
                       @"Samsung Xperia Incredible II 3D",
                       @"Motorola Thunderbolt Slide Pro E",
                       @"Sony Ericsson Atrix Vibrant Prime Pro",
                       @"LG Dream Optimus G1 Prime II",
                       @"LG Bionic Plus V XT",
                       @"Samsung Mesmerize Epic 3D",
                       @"Acer Legend Vibrant II E",
                       @"HTC Legend Vibrant G1 S E",
                       @"Sony Ericsson Galaxy Incredible V"
                       ];
    
    return array;
}

- (NSArray *)randomPhoneArray
{
    NSMutableArray *array = [[self phoneArray] mutableCopy];
    for (NSUInteger i = array.count - 1; i > 0; i--) {
        [array exchangeObjectAtIndex:i withObjectAtIndex:(random() % array.count)];
    }
    
    return array;
}

- (NSString *)randomPhone
{
    NSArray *array = [self phoneArray];
    
    return array[rand() % array.count];
}

+ (HPTDataService *)sharedService
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    self = [super init];
    if (self) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                 repeats:YES];
    }
    return self;
}

- (void)reset
{
    self.dataArray = [NSMutableArray array];
}
                  
- (void)timerFired:(id)sender
{
    ASSERT_MAIN_THREAD;
    
    if (!self.dataArray) {
        self.dataArray = [NSMutableArray array];
    }
    
    if (rand() % 3 == 0) {
        NSUInteger count = self.dataArray.count;
        if (!count) {
            [self timerFired:sender];
            return;
        }
        
        NSUInteger section = rand() % count;
        NSArray *array = self.dataArray[section];
        NSUInteger row = rand() % array.count;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [self removeDataObjectAtIndexPath:indexPath];
    }
    else {
        NSUInteger count = self.dataArray.count;
        NSUInteger section = rand() % (count+1);
        NSUInteger row = 0;
        if (section < count) {
            NSArray *array = self.dataArray[section];
            row = rand() % (array.count+1);
        }

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [self insertDataObject:[self randomPhone] atIndexPath:indexPath];
    }
}

- (void)insertDataObject:(id)object atIndex:(NSUInteger)index
{
    NSMutableArray *KVCArray = [self mutableArrayValueForKey:@"dataArray"];
    [KVCArray insertObject:object atIndex:index];
}

- (void)removeDataObjectAtIndex:(NSUInteger)index
{
    NSMutableArray *KVCArray = [self mutableArrayValueForKey:@"dataArray"];
    [KVCArray removeObjectAtIndex:index];
}

- (void)insertDataObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.section == self.dataArray.count) {
        [self insertDataObject:[NSMutableArray array] atIndex:indexPath.section];
    }
    
    [self willChange:NSKeyValueChangeInsertion
     valuesAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]
              forKey:[@(indexPath.section) description]];
    
    NSMutableArray *array = self.dataArray[indexPath.section];
    [array insertObject:object atIndex:indexPath.row];
    
    [self didChange:NSKeyValueChangeInsertion
    valuesAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]
             forKey:[@(indexPath.section) description]];
}

- (void)removeDataObjectAtIndexPath:(NSIndexPath *)indexPath
{
//    TRC_LOG(@"remove at: [%d, %d], total: %d, %@", indexPath.section, indexPath.row, [self.dataArray[indexPath.section] count], self.dataArray[indexPath.section]);
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:indexPath.row];
    
    [self willChange:NSKeyValueChangeRemoval
     valuesAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]
              forKey:[@(indexPath.section) description]];
    
    NSMutableArray *array = self.dataArray[indexPath.section];
    if ([array[indexPath.row] isEqualToString:@"Acer Legend Vibrant II E"]) {
        TRC_ENTRY;
    }
    
    [array removeObjectAtIndex:indexPath.row];

    [self didChange:NSKeyValueChangeRemoval
    valuesAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]
             forKey:[@(indexPath.section) description]];
    
    if (!array.count) {
        [self removeDataObjectAtIndex:indexPath.section];
    }
}

- (id)valueForUndefinedKey:(NSString *)key
{
    NSUInteger i = [key integerValue];
    return self.dataArray[i];
}

@end
