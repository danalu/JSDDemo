//
//  ItemUtility.m
//  JSDDemo
//
//  Created by Dana on 15/2/25.
//  Copyright (c) 2015年 Dana. All rights reserved.
//

#import "ItemUtility.h"
#import "Item.h"
#import "Constant.h"
#import "HSFileHelper.h"
#import "ItemView.h"

@implementation ItemUtility

+ (void)insertGridWithItem:(Item*)item pageGrid:(NSMutableArray*)grids {
    NSArray *indexs = [[self class] getItemIndexs:item];
    [indexs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [grids replaceObjectAtIndex:((NSNumber*)obj).integerValue withObject:item.itemID];
    }];
}

+ (void)deleteGridWithItem:(Item*)item pageGrid:(NSMutableArray*)grids {
    NSArray *indexs = [[self class] getItemIndexs:item];
    [indexs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [grids replaceObjectAtIndex:((NSNumber*)obj).integerValue withObject:[NSNull null]];
    }];
}

+ (NSInteger)getCurrentPageIndexWithColumn:(NSInteger)column {
    CGFloat floatPage = (CGFloat)column / KMaxColumnOnePage;
    NSInteger intPage = column % KMaxColumnOnePage;
    return floatPage - intPage > 0.0 ? intPage + 1 : intPage;
}

+ (CGPoint)getItemNewOriginWithItemCenter:(CGPoint)point {
    NSInteger currentPageIndex = point.x / ScontainWidth;
    
    CGFloat currentOffsetX = point.x - currentPageIndex * ScontainWidth;
    
    NSInteger currentColumn = (currentOffsetX - offset) / (KOneToOneSize.width + itemGap);
    
    CGFloat currentOffsetY = point.y - offset;
    NSInteger currentRow = currentOffsetY / (KOneToOneSize.height + itemGap);
    
    return CGPointMake(currentRow, currentColumn);
}

+ (CGSize)getItemViewNewRectWithItem:(Item*)item {
    CGSize size;
    NSInteger sizeType = item.currentSizeType;

    sizeType++;
    sizeType = sizeType % 3;
    
    item.currentSizeType = sizeType;
    
    if (sizeType == 0) {
        size = CGSizeMake(KOneToOneSize.width, KOneToOneSize.height);
    } else if (sizeType == 1) {
        size = CGSizeMake(KOneToTwoSize.width, KOneToOneSize.height);
    } else {
        size = CGSizeMake(KTwoToTwoSize.width, KTwoToTwoSize.height);
    }
    
    return size;
}

+ (UIImage*)getItemIconWithItem:(Item*)item {    
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",item.imageNames[item.currentSizeType]]];
}

+ (void)saveItemLayoutWithItemModels:(NSArray*)itemModels {
    dispatch_queue_t queue = dispatch_queue_create("saveItemLayout",NULL);
    dispatch_async(queue, ^{
        NSMutableArray *allPage = [NSMutableArray array];
        [itemModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSArray *items = obj;
            
            NSMutableArray *onePage = [NSMutableArray new];
            [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSMutableDictionary *itemDic = [NSMutableDictionary new];
                
                Item *item = obj;
                
                itemDic[@"id"] = item.itemID;
                itemDic[@"name"] = item.itemName;
                itemDic[@"row"] = @(item.row);
                itemDic[@"column"] = @(item.column);
                itemDic[@"type"] = @(item.currentSizeType);
                itemDic[@"images"] = item.imageNames;
                
                [onePage addObject:itemDic];
            }];
            
            [allPage addObject:onePage];
        }];
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:allPage options:0 error:nil];
        
        if (data && data.length != 0) {
            NSString *filePath = [[HSFileHelper getDocumentDirectory] stringByAppendingPathComponent:KItemJsonFileName];
            [HSFileHelper saveData:data toFile:filePath];
        }
    });
}

+ (NSArray*)getItemLayout {
    NSString *filePath = [[HSFileHelper getDocumentDirectory] stringByAppendingPathComponent:KItemJsonFileName];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    
    if (data && data.length != 0) {
        NSArray *items = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        return items;
    } else {
        NSString *filepath = [[NSBundle mainBundle] pathForResource:@"itemConfig" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filepath];
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
}

+ (NSArray*)getItemIndexs:(Item*)item {
    NSInteger row = item.row;
    NSInteger column = item.column;
    NSInteger type = item.currentSizeType;

    NSMutableArray *indexs = [NSMutableArray new];
    // (row,column)
    NSInteger leftIndex = column * KMaxRowOnePage + row;
    
    [indexs addObject:@(leftIndex)];
    
    if (type == 0) {
        // 1 * 1
    } else {
        //(row, colunm + 1)
        NSInteger rightIndex = (column + 1) * KMaxRowOnePage + row;
        [indexs addObject:@(rightIndex)];
        
        if (type == 1) {
            // 1 * 2
        } else {
            // 2 * 2
            
            // (row + 1, column)
            NSInteger leftBottomIndex = leftIndex + 1;
            
            // (row + 1, column + 1)
            NSInteger rightBottomIndex = rightIndex + 1;
            
            [indexs addObject:@(leftBottomIndex)];
            [indexs addObject:@(rightBottomIndex)];
        }
    }

    return indexs;
}

+ (Item*)getItemWithItemID:(NSString*)itemID itemModels:(NSArray*)itemModels {
    NSInteger currentItemModel = [[itemModels valueForKey:@"itemID"] indexOfObject:itemID];
    
    Item *item = itemModels[currentItemModel];
    
    return item;
}

@end
