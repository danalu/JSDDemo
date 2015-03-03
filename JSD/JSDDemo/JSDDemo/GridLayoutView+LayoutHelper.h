//
//  GridLayoutView+LayoutHelper.h
//  JSDDemo
//
//  Created by Dana on 15/2/26.
//  Copyright (c) 2015年 Dana. All rights reserved.
//

#import "GridLayoutView.h"

@interface GridLayoutView (LayoutHelper)

- (NSString*)getItemIDWithItemView:(ItemView*)itemView;

- (Item*)getItemWithItemView:(ItemView*)itemView;

- (NSArray*)getDrayItemNewIndexs;

- (NSArray*)getItemContainsIndexs;

- (void)handleItemDrayStoping;

- (void)deleteGridWithItem:(Item*)item;

- (NSInteger)getCurrentPage;

- (void)itemSizeChangedWithItemView:(ItemView*)itemView;

- (void)layoutCurrentEditingItem;

@end
