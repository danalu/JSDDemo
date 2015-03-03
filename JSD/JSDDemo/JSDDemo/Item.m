//
//  DeskThemeView.m
//  JSDDemo
//
//  Created by Dana on 15/2/17.
//  Copyright (c) 2015年 Dana. All rights reserved.
//

#import "Item.h"

@implementation Item

- (id)copyWithZone:(NSZone *)zone {
    Item *item = [[[self class] allocWithZone:zone] init];
    
    item.itemID = _itemID;
    item.itemName = _itemName;
    item.row = _row;
    item.column = _column;
    item.itemSizeTypes = _itemSizeTypes;
    item.currentSizeType = _currentSizeType ;
    item.imageNames = _imageNames;
    
    return item;
}

@end
