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
        _timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                  target:self
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                 repeats:YES];
    }
    return self;
}
                  
- (void)timerFired:(id)sender
{
    TRC_ENTRY;
    
    self.dataArray = [[self randomPhoneArray] mutableCopy];
}

@end