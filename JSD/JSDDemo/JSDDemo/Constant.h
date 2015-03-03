//
//  Constant.h
//  JSDDemo
//
//  Created by Dana on 15/2/25.
//  Copyright (c) 2015年 Dana. All rights reserved.
//

#ifndef JSDDemo_Constant_h
#define JSDDemo_Constant_h


#define KOneToOneSize CGSizeMake(160,160)
#define KOneToTwoSize CGSizeMake(330,160)
#define KTwoToTwoSize CGSizeMake(330,330)

#define KMaxColumnOnePage  6
#define KMaxRowOnePage 4
#define KScreenSize [UIScreen mainScreen].bounds.size

#define ScontentWidth  1010
#define ScontentHeight  670

#define ScontainWidth  1024
#define ScontainHeight  684

#define offset  7
#define itemGap  10

#define baseTag  101010


#define KItemJsonFileName @"itemConfig.json"

typedef enum : NSUInteger {
    BeyondLeftType,
    BeyondRightType,
    normalType
} ItemDragStopType;

typedef enum : NSUInteger {
    OneToOneType,
    OneToTwoType,
    TwoToTwoType,
} ItemSizeType;

typedef enum : NSUInteger {
    Left,
    Right,
    Top,
    Bottom
} Direction;

#endif
