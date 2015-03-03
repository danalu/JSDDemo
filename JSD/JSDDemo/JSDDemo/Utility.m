//
//  Utility.m
//  JSDDemo
//
//  Created by Dana on 15/2/17.
//  Copyright (c) 2015年 Dana. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (NSArray*)getItemConfig {
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"itemConfig" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filepath];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

@end
