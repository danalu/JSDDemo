//
//  GridLayoutView+LayoutHelper.m
//  JSDDemo
//
//  Created by Dana on 15/2/26.
//  Copyright (c) 2015年 Dana. All rights reserved.
//

#import "GridLayoutView+LayoutHelper.h"
#import "Item.h"
#import "Constant.h"
#import "ItemView.h"
#import "ItemUtility.h"
#import "ItemRect.h"

@implementation GridLayoutView (LayoutHelper)

- (NSString*)getItemIDWithItemView:(ItemView*)itemView {
    NSInteger itemID = itemView.tag - baseTag;
    
    return @(itemID).stringValue;
}

- (Item*)getItemWithItemView:(ItemView*)itemView {
    NSArray *itemModel = self.itemModels[self.currentPageindex];
    
    NSInteger currentItemModel = [[itemModel valueForKey:@"itemID"] indexOfObject:[self getItemIDWithItemView:itemView]];

    return itemModel[currentItemModel];
}


- (NSArray*)getItemContainsIndexsWithItem:(Item*)item {
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

- (NSArray*)getDrayItemOveredItemsWithItem:(Item*)item {
    NSArray *indexs = [self getItemContainsIndexsWithItem:item];
    
    NSMutableArray *overedItems = [NSMutableArray new];
    
    NSArray *currentPageItem = self.itemModels[self.currentPageindex];
    NSArray *pageGrid = self.pageGrids[self.currentPageindex];
    [indexs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id indexObj = pageGrid[((NSNumber*)obj).integerValue];
        
        if (indexObj && ![indexObj isKindOfClass:[NSNull class]]) {
            NSString *itemID = indexObj;
            
            NSInteger index = [[currentPageItem valueForKey:@"itemID"] indexOfObject:itemID];
            if (index != NSNotFound) {
                Item *item = currentPageItem[index];
                [overedItems removeObject:item];
                [overedItems addObject:item];
            }
        }
        
    }];
    
    return overedItems;
}

- (void)deleteGridWithItem:(Item*)item {
    NSMutableArray *currentPageGrid = self.pageGrids[self.currentPageindex];

    NSArray *indexs = [self getItemContainsIndexsWithItem:self.currentEditingItem];
    [indexs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [currentPageGrid replaceObjectAtIndex:((NSNumber*)obj).integerValue withObject:[NSNull null]];
    }];
}

//拖曳item之后，算出新的起始坐标.
- (CGPoint)getItemNewOrigin {
    CGPoint point = self.currentEditingView.center;
    
    //获取item新的(x,y)
    
    NSInteger offsetRow = 0;
    NSInteger offsetColumn = 0;
    if (self.currentEditingItem.currentSizeType == OneToTwoType) {
        point.x -= KOneToOneSize.width / 2;
        offsetColumn = 1;
    } else if (self.currentEditingItem.currentSizeType == TwoToTwoType) {
        point.x -= KOneToOneSize.width / 2;
        point.y -= KOneToOneSize.height / 2;
        
        offsetRow = 1;
        offsetColumn = 1;
    }
    
    //得出当前页相对坐标
    CGFloat currentOffsetX = point.x - self.currentPageindex * ScontainWidth;
    
    //得出相对于当前页的列
    NSInteger currentColumn = (currentOffsetX - offset) / (KOneToOneSize.width + itemGap);
    
    //得出当前页相对y坐标
    CGFloat currentOffsetY = point.y - offset;
    
    //得出相对于当前页的行
    NSInteger currentRow = currentOffsetY / (KOneToOneSize.height + itemGap);
    
    if (currentRow + offsetRow >= KMaxRowOnePage) {
        currentRow = KMaxRowOnePage - 1 - offsetRow;
    }
    
    if (currentColumn + offsetColumn >= KMaxColumnOnePage) {
        currentColumn = KMaxColumnOnePage - 1 - offsetColumn;
    }
    
    return CGPointMake(currentRow, currentColumn);
}

//根据起始坐标算出当前所在的区域.
- (ItemDragStopType)getItemDragStopType {
    CGPoint origin = self.currentEditingView.frame.origin;
    
    CGFloat originX = origin.x - self.currentPageindex * ScontainWidth;
    CGFloat originY = origin.y;
    
    ItemSizeType sizeType = self.currentEditingItem.currentSizeType;
    
    ItemDragStopType stopType = normalType;
    
    CGRect pageRect = CGRectMake(0, 0, ScontainWidth, ScontainHeight);
    
    CGFloat width,height;
    if (sizeType == OneToOneType) {
        width = KOneToOneSize.width;
        height = KOneToOneSize.height;
    } else if (sizeType == OneToTwoType) {
        width = KOneToTwoSize.width;
        height = KOneToTwoSize.height;
    } else {
        width = KTwoToTwoSize.width;
        height = KTwoToTwoSize.height;
    }
    
    CGRect itemRect = CGRectMake(originX, originY, width, height);

    if (CGRectContainsRect(pageRect, itemRect)) {
        stopType = normalType;
    } else {
        if (originX < - (width / 2 - 20) && self.currentPageindex != 0) {
            //超出左边界
            stopType = BeyondLeftType;
        } else if (originX + width > ScontainWidth + width / 2 - 20) {
            //超出右边界
            stopType = BeyondRightType;
        }
    }
    
    return stopType;
}

//处理item停放操作
- (void)handleItemDrayStoping {
    ItemDragStopType itemStopType = [self getItemDragStopType];
    if (itemStopType == BeyondRightType) {
        //向右翻页
        [self handleItemRightLayout];
    } else if (itemStopType == BeyondLeftType) {
        //向左翻页
        [self handleItemLeftLayout];
    } else {
        //停留.
        CGPoint origin = [self getItemNewOrigin];
        self.currentEditingItem.row = origin.x;
        self.currentEditingItem.column = origin.y;
        
        [self layoutItemView];
    }
}

- (void)layoutCurrentEditingItem {
    [self updateCurrentEditItemFrame];
}

//动画放置item
- (void)layoutItemView {
    
    //layout其他
    NSArray *items = [self getDrayItemOveredItemsWithItem:self.currentEditingItem];
    
    if (items.count == 0) {
        //空白区域.就地放置
    } else {
        __block Item *cannotMovedItem = nil;
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![self layoutItemWithItem:obj]) {
                cannotMovedItem = obj;
                *stop = YES;
            }
        }];
        
        if (cannotMovedItem) {
            [self handleNeededMovedItemsWithMoveColumnIndex:self.currentEditingItem.column moveColumnNum:[self getItemColumnsWithItem:self.currentEditingItem] movedItems:nil pageIndex:self.currentPageindex cannotMoveItem:cannotMovedItem];
        }
    }
}

- (BOOL)layoutItemWithItem:(Item*)item {
    static NSInteger direction = -1;
    
    direction++;
    
    if (direction == 4) {
        direction = -1;
        return NO;
    }
    
    //先左，后右，然后上，最后下
    //得到左边的坐标.
    ItemRect *currentItemRect = [self getItemRectWithItem:self.currentEditingItem];
    ItemRect *itemRect = [self getItemRectWithItem:item];
    
    Item *copyItem = [item copy];
    if (direction == Top) {
        //row
        NSInteger topRow = currentItemRect.y - itemRect.height;
        
        if (topRow >= 0) {
            copyItem.row = topRow;
        } else {
            return [self layoutItemWithItem:item];
        }
    } else if (direction == Left) {
        //column
        NSInteger leftColumn = currentItemRect.x - itemRect.width;
        
        if (leftColumn >= 0) {
            copyItem.column = leftColumn;
        } else {
            return [self layoutItemWithItem:item];
        }
    } else if (direction == Bottom) {
        NSInteger bottomRow = currentItemRect.y + currentItemRect.height - 1 + itemRect.height;

        if (bottomRow < KMaxRowOnePage) {
            copyItem.row = currentItemRect.y + currentItemRect.height - 1 + 1;
        } else {
            return NO;
        }
    } else {
        NSInteger RightColumn = currentItemRect.x + currentItemRect.width - 1 + itemRect.width;
        
        if (RightColumn < KMaxColumnOnePage) {
            copyItem.column = currentItemRect.x + currentItemRect.width - 1 + 1;
        } else {
            return [self layoutItemWithItem:item];
        }
    }
    
    NSArray *items = [self getDrayItemOveredItemsWithItem:copyItem];
    
    if (items.count == 0) {
        [ItemUtility deleteGridWithItem:item pageGrid:self.pageGrids[self.currentPageindex]];
        
        item.row = copyItem.row;
        item.column  = copyItem.column;
        [self updateOveredItemFrameWithItem:item];
        
        direction = -1;
        
        return YES;
    } else {
        return [self layoutItemWithItem:item];
    }
}

- (void)updateCurrentEditItemFrame {
    CGRect rect = self.currentEditingView.frame;
    rect.origin.x = self.currentPageindex * ScontainWidth + offset + self.currentEditingItem.column * (KOneToOneSize.width + itemGap);
    rect.origin.y = offset + self.currentEditingItem.row * (KOneToOneSize.height + itemGap);
    
    [ItemUtility insertGridWithItem:self.currentEditingItem pageGrid:self.pageGrids[self.currentPageindex]];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.currentEditingView.frame = rect;
    } completion:^(BOOL finished) {
        
    }];

}

- (void)updateOveredItemFrameWithItem:(Item*)item {
    ItemView *itemView = (ItemView*)([self.contentScrollView viewWithTag:baseTag + item.itemID.integerValue]);
    itemView.transform = CGAffineTransformIdentity;

    [ItemUtility insertGridWithItem:item pageGrid:self.pageGrids[self.currentPageindex]];
    
    CGRect rect;
    rect.origin.x = self.currentPageindex * ScontainWidth + offset + item.column * (KOneToOneSize.width + itemGap);
    rect.origin.y = offset + item.row * (KOneToOneSize.height + itemGap);
    rect.size = [self getItemSizeWithItem:item];
    
    [UIView animateWithDuration:0.3 animations:^{
        itemView.frame = rect;
        itemView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)updateItemFrameWithItem:(Item*)item pageIndex:(NSInteger)pageIndex animated:(BOOL)isAnimation {
    if (item == self.currentEditingItem) {
        return;
    }
    
    ItemView *itemView = (ItemView*)([self.contentScrollView viewWithTag:baseTag + item.itemID.integerValue]);
    itemView.transform = CGAffineTransformIdentity;
    
    CGRect rect;
    rect.origin.x = pageIndex * ScontainWidth + offset + item.column * (KOneToOneSize.width + itemGap);
    rect.origin.y = offset + item.row * (KOneToOneSize.height + itemGap);
    rect.size = [self getItemSizeWithItem:item];
    
    if (isAnimation) {
        [UIView animateWithDuration:0.4 animations:^{
            itemView.frame = rect;
            itemView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        } completion:^(BOOL finished) {
            
        }];
    } else {
        itemView.frame = rect;
        itemView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    }
}

//得到item的
- (ItemRect*)getItemRectWithItem:(Item*)item {
    
    ItemRect *itemRect = [[ItemRect alloc] init];
    
    itemRect.x = item.column;
    itemRect.y = item.row;
    NSInteger type = item.currentSizeType;

    if (type == OneToOneType) {
        // 1 * 1
        itemRect.width = 1;
        itemRect.height = 1;
    } else if (type == OneToTwoType) {
        //(row, colunm + 1)
        itemRect.width = 2;
        itemRect.height = 1;
    } else {
        itemRect.width = 2;
        itemRect.height = 2;
    }
    
    return itemRect;
}

//超出左边界的操作
- (void)handleItemLeftLayout {
    NSMutableArray *lastpageItemModelArray = self.itemModels[self.currentPageindex];
    [lastpageItemModelArray removeObject:self.currentEditingItem];
    
    self.currentPageindex--;
    
    NSMutableArray *currentpageItemModelArray = self.itemModels[self.currentPageindex];
    [currentpageItemModelArray addObject:self.currentEditingItem];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentScrollView scrollRectToVisible:CGRectMake(ScontainWidth * self.currentPageindex, 0, ScontainWidth, ScontainHeight) animated:YES];
    }];
    
    [self layoutItemView];
}

//超出右边界的操作
- (void)handleItemRightLayout {
    NSMutableArray *lastpageItemModelArray = self.itemModels[self.currentPageindex];
    [lastpageItemModelArray removeObject:self.currentEditingItem];
    
    self.currentPageindex++;
    
    if (self.currentPageindex + 1 > self.maxPageNumber) {
        NSMutableArray *newPageItemModelArray = [NSMutableArray new];
        [self.itemModels addObject:newPageItemModelArray];
        
        [self addNewPage];
    }
    
    NSMutableArray *currentpageItemModelArray = self.itemModels[self.currentPageindex];
    [currentpageItemModelArray addObject:self.currentEditingItem];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentScrollView scrollRectToVisible:CGRectMake(ScontainWidth * self.currentPageindex, 0, ScontainWidth, ScontainHeight) animated:NO];
    }];
    
    [self layoutItemView];

}

- (NSInteger)getCurrentPage {
    CGFloat offsetX = self.contentScrollView.contentOffset.x;
    CGFloat indexFloat = offsetX / ScontainWidth;
    
    NSInteger index = offsetX / ScontainWidth;
    
    CGFloat off = indexFloat - index;
    if (off > 0.0) {
        index += 1;
    }
    
    return index;
}

- (CGSize)getItemSizeWithItem:(Item*)item {
    CGSize itemSize;
    if (item.currentSizeType == OneToOneType) {
        itemSize = CGSizeMake(KOneToOneSize.width, KOneToOneSize.height);
    } else if (item.currentSizeType == OneToTwoType) {
        itemSize = CGSizeMake(KOneToTwoSize.width, KOneToOneSize.height);
    } else {
        itemSize = CGSizeMake(KTwoToTwoSize.width, KTwoToTwoSize.height);
    }
    
    return itemSize;
}

- (NSInteger)getItemColumnsWithItem:(Item*)item {
    return item.currentSizeType == OneToOneType ? 1 : 2;
}

- (void)addNewPage {
    NSMutableArray *newpage = [NSMutableArray new];
    for (NSUInteger i = 0 ; i < KMaxRowOnePage * KMaxColumnOnePage; i++) {
        [newpage addObject:[NSNull null]];
    }
    
    NSMutableArray *itemModel = [NSMutableArray new];
    
    [self.itemModels addObject:itemModel];
    [self.pageGrids addObject:newpage];
    
    self.maxPageNumber++;
    
    self.contentScrollView.contentSize = CGSizeMake(ScontainWidth * self.maxPageNumber, ScontainHeight);
}


- (void)handleNeededMovedItemsWithMoveColumnIndex:(NSInteger)columnIndex moveColumnNum:(NSInteger)needMoveNum movedItems:(NSArray*)items pageIndex:(NSInteger)pageIndex cannotMoveItem:(Item*)cannotMoveItem {
    NSMutableArray *pageItemModels = self.itemModels[pageIndex];
    NSMutableArray *pageGrid = self.pageGrids[pageIndex];
    
    //得到需要从那列开始移动
    NSInteger column = columnIndex;
    
    //得到了本页所有需要右移的item.
    NSMutableArray *waitMovedItems = [NSMutableArray new];
    [pageItemModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Item *item = obj;
        
        if (item.column >= column && self.currentEditingItem != item) {
            [waitMovedItems addObject:item];
            
            [ItemUtility deleteGridWithItem:item pageGrid:pageGrid];
        }
    }];
    
    if (cannotMoveItem && cannotMoveItem.column < self.currentEditingItem.column) {
        [ItemUtility deleteGridWithItem:cannotMoveItem pageGrid:pageGrid];
        [waitMovedItems addObject:cannotMoveItem];
        NSInteger currentEditingItemColumnNum = [self getItemColumnsWithItem:self.currentEditingItem];

        NSInteger offsetColumnNum = self.currentEditingItem.column + currentEditingItemColumnNum - cannotMoveItem.column;
        
        needMoveNum = MAX(currentEditingItemColumnNum, offsetColumnNum);
    }
    
   //得到需要移动的列数
    NSInteger needMovedColumns = needMoveNum;
    
    NSMutableArray *beyondItems = [NSMutableArray new];
    
    __block NSInteger needMoveColumnIndex = 0;
    __block NSInteger needMoveColumnNumber = 0;
    __block NSInteger lastItemColumn = 0;
    
    __block BOOL needMoveThreeLines = NO;
    [waitMovedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Item *item = obj;
        NSInteger column = item.column + needMovedColumns;
        
        //得到超出本页的item
        NSInteger itemColumn = [self getItemColumnsWithItem:item];
        if (item.column >= KMaxColumnOnePage || item.column + (itemColumn - 1) >= KMaxColumnOnePage) {
            if (itemColumn == 2 && column == 5) {
                needMoveThreeLines = YES;
            }
        }
    }];

    
    [waitMovedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Item *item = obj;
        
        item.column += needMovedColumns;
        
        //得到超出本页的item
        NSInteger itemColumn = [self getItemColumnsWithItem:item];
        if (item.column >= KMaxColumnOnePage || item.column + (itemColumn - 1) >= KMaxColumnOnePage) {
            [beyondItems addObject:item];
            
            if (itemColumn == 2) {
                lastItemColumn = 2;
                
                item.column = 0;
            } else if (item.column == 7 && needMoveThreeLines) {
                lastItemColumn = 3;
                
                item.column = 2;
            } else {
                lastItemColumn = needMoveColumnNumber ;
                
                item.column = item.column % KMaxColumnOnePage;
            }
            
            needMoveColumnNumber = needMoveColumnNumber > lastItemColumn ? needMoveColumnNumber : lastItemColumn;
            
            [pageItemModels removeObject:item];
        } else {
            [ItemUtility insertGridWithItem:item pageGrid:pageGrid];
        }
        
    }];
    
    //加上上一页的models.
    if (items.count > 0 && pageIndex > 0) {
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Item *item = obj;
            
            [pageItemModels addObject:item];
            
            [ItemUtility insertGridWithItem:item pageGrid:pageGrid];
        }];
    }
    
    [pageItemModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (self.currentPageindex == pageIndex || self.currentPageindex == pageIndex - 1) {
            [self updateItemFrameWithItem:obj pageIndex:pageIndex animated:YES];
        } else {
            [self updateItemFrameWithItem:obj pageIndex:pageIndex animated:NO];
        }
    }];
    
    //移动后，本页容纳不下的，需要移动到下一页
    if (beyondItems.count > 0) {
        if (self.maxPageNumber > pageIndex + 1) {
            //不需要增加一页
        } else {
            //需要增加新页
            [self addNewPage];
        }
        
        //移动到下一页.
        [self handleNeededMovedItemsWithMoveColumnIndex:needMoveColumnIndex moveColumnNum:needMoveColumnNumber movedItems:beyondItems pageIndex:pageIndex + 1 cannotMoveItem:nil];
    } else {
        //移动完毕
        
    }
}

- (void)itemSizeChangedWithItemView:(ItemView*)itemView {
    [ItemUtility deleteGridWithItem:self.currentEditingItem pageGrid:self.pageGrids[self.currentPageindex]];
    
    //计算新的尺寸，以及改变item的currentSizeType
    CGSize newSize = [ItemUtility getItemViewNewRectWithItem:self.currentEditingItem];
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect rect  = itemView.frame;
        rect.size = newSize;
        itemView.frame = rect;
    }];
    
    //change icon.
    itemView.icon.image = [ItemUtility getItemIconWithItem:self.currentEditingItem];
    
    //开始布局.
    ItemDragStopType itemStopType = [self getItemDragStopType];
    if (itemStopType == BeyondRightType) {
        //超出右边界.
        self.currentEditingItem.column = 0;
        [self handleItemRightLayout];
    } else {
        //停留.
        CGPoint origin = [self getItemNewOrigin];
        self.currentEditingItem.row = origin.x;
        self.currentEditingItem.column = origin.y;
        
        [self layoutItemView];
    }
}

@end
