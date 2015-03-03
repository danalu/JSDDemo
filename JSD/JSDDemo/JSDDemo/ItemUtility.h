//
//  ItemUtility.h
//  JSDDemo
//
//  Created by Dana on 15/2/25.
//  Copyright (c) 2015年 Dana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class Item;

@interface ItemUtility : NSObject

+ (void)insertGridWithItem:(Item*)item pageGrid:(NSMutableArray*)grids;

+ (void)deleteGridWithItem:(Item*)item pageGrid:(NSMutableArray*)grids;

+ (NSInteger)getCurrentPageIndexWithColumn:(NSInteger)column;

+ (CGPoint)getItemNewOriginWithItemCenter:(CGPoint)point;

+ (CGSize)getItemViewNewRectWithItem:(Item*)item;

+ (UIImage*)getItemIconWithItem:(Item*)item;

+ (void)saveItemLayoutWithItemModels:(NSArray*)itemModels;

+ (NSArray*)getItemLayout;

+ (Item*)getItemWithItemID:(NSString*)itemID itemModels:(NSArray*)itemModels;

+ (NSArray*)getItemIndexs:(Item*)item;

+ (NSArray*)getDrayItemNewIndexsWithCenter:(CGPoint)point item:(Item*)item;

@end
