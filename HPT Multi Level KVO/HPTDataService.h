//
//  HPTDataService.h
//  HPT Multi Level KVO
//
//  Created by Jakub Hladík on 18.04.13.
//  Copyright (c) 2013 Hippotaps s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPTDataService : NSObject

@property (strong, nonatomic) NSMutableArray *dataArray;

+ (HPTDataService *)sharedService;

- (void)reset;

@end
