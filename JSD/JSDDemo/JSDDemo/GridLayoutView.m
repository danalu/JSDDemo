//
//  GridLayoutView.m
//  JSDDemo
//
//  Created by Dana on 15/2/17.
//  Copyright (c) 2015年 Dana. All rights reserved.
//

#import "GridLayoutView.h"
#import "ALView+PureLayout.h"
#import "Utility.h"
#import "Item.h"
#import "ItemView.h"
#import "Constant.h"
#import "ItemUtility.h"
#import "GridLayoutView+LayoutHelper.h"

@interface UIScrollView(Event)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@implementation UIScrollView(Event)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.nextResponder touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.nextResponder touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.nextResponder touchesEnded:touches withEvent:event];
}

@end


@interface GridLayoutView()<UIScrollViewDelegate,ItemViewDelegate,UIGestureRecognizerDelegate> {
   
}

@end

@implementation GridLayoutView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(KScreenSize.width - ScontainWidth, KScreenSize.height - ScontainHeight, ScontainWidth, ScontainHeight)];
    if (self) {
        [self viewLayout];
        
        [self requestData];
    }
    return self;
}

- (id)init {
    return [self initWithFrame:CGRectMake(KScreenSize.width - ScontainWidth, KScreenSize.height - ScontentHeight, ScontainWidth, ScontainHeight)];
}

- (void)viewLayout {
    UIScrollView *contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    contentScrollView.delegate = self;
    contentScrollView.pagingEnabled = YES;
    
    [self addSubview:contentScrollView];
    
    [self addConstraints:[contentScrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)]];
    
    self.contentScrollView = contentScrollView;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelEditing)];
    tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:tapGestureRecognizer];
    
    _isEditing = NO;
}

- (void)requestData {
    NSArray *items = [ItemUtility getItemLayout];
    _pageGrids = [NSMutableArray arrayWithCapacity:items.count];
    
    _itemModels = [NSMutableArray arrayWithCapacity:items.count];
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __block NSMutableArray *pageGrid = [NSMutableArray new];
        
        for (NSUInteger i = 0 ; i < KMaxRowOnePage * KMaxColumnOnePage; i++) {
            [pageGrid addObject:[NSNull null]];
        }
        [_pageGrids addObject:pageGrid];
        
        NSArray *itemArray = obj;
        NSMutableArray *itemModel = [NSMutableArray arrayWithCapacity:itemArray.count];
        [itemArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dic = obj;
            
            Item *item = [[Item alloc] init];
            item.itemID = dic[@"id"];
            item.itemName = dic[@"name"];
            item.row = ((NSNumber*)dic[@"row"]).integerValue;
            item.column = ((NSNumber*)dic[@"column"]).integerValue;
            item.currentSizeType = ((NSNumber*)dic[@"type"]).integerValue;
            item.imageNames = dic[@"images"];
            
            [itemModel addObject:item];
            
            [ItemUtility insertGridWithItem:item pageGrid:pageGrid];
        }];
        
        [_itemModels addObject:itemModel];
    }];
    
    _currentPageindex = 0;
    
    _maxPageNumber = _pageGrids.count;
    
    [self reloadView];
}

- (void)reloadView {
    //总共页数
    _itemViews = [NSMutableArray new];
    [_pageGrids enumerateObjectsUsingBlock:^(id obj, NSUInteger page, BOOL *stop) {
        NSArray *items = _itemModels[page];
        
        NSMutableArray *itemViewArray = [NSMutableArray new];
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Item *item = obj;
            
            ItemView *itemView = [[ItemView alloc] initWithFrame:CGRectMake(self.center.x   , self.center.y, 0, 0)];
            itemView.delegate = self;
            itemView.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",item.imageNames[item.currentSizeType]]];
            itemView.tag = baseTag + item.itemID.integerValue;
            [self.contentScrollView addSubview:itemView];
            
            [itemViewArray addObject:itemView];
            
            NSInteger currentPage = page;
            CGFloat offsetX = currentPage * ScontainWidth + offset + item.column % KMaxColumnOnePage * (KOneToOneSize.width + itemGap);
            CGFloat offsetY = offset + item.row * (KOneToOneSize.height + itemGap);
            [UIView animateWithDuration:0.15 * idx animations:^{
                itemView.frame = CGRectMake(offsetX, offsetY , item.currentSizeType == 0 ? KOneToOneSize.width : KOneToTwoSize.width, item.currentSizeType == 2 ? KTwoToTwoSize.height : KOneToOneSize.height);
            }];
        }];

        [_itemViews addObject:itemViewArray];
    }];
    
    self.contentScrollView.contentSize = CGSizeMake(ScontainWidth * _itemModels.count, ScontainHeight);
}

- (void)setEditing:(BOOL)editing {
    [_itemModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *pageItem = obj;
        [pageItem enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Item *item = obj;
            
            ItemView *itemView = (ItemView*)[self.contentScrollView viewWithTag:baseTag + item.itemID.integerValue];
            
            if (_isEditing == editing) {
                if (editing) {
                    //当前已经是出于编辑模式下
                    [itemView setEditing:NO editingItem:NO];
                    
                    [itemView setEditing:editing editingItem:_currentEditingView == itemView];
                } else {
                    //已经不是编辑模式下.
                    *stop = YES;
                }
            } else {
                [itemView setEditing:editing editingItem:_currentEditingView == itemView];
            }
        }];
    }];
    
    _isEditing = editing;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentPageindex = [self getCurrentPage];
}

#pragma mark UITapGesture
- (void)cancelEditing {
    if (_isEditing) {
        self.currentEditingItem = nil;
        self.currentEditingView = nil;
        
        [self setEditing:NO];
        
        [ItemUtility saveItemLayoutWithItemModels:_itemModels];
    }
}

#pragma mark--
#pragma mark--UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([touch.view isKindOfClass:[ItemView class]])
    {
        return NO;
    }
    return YES;
}

#pragma mark ItemViewDelegate
- (void)itemViewDidClicked:(ItemView *)itemView {
    if (!_isEditing) {
        if ([_delegate respondsToSelector:@selector(gridLayoutDidSelected:)]) {
            [_delegate gridLayoutDidSelected:self];
        }
        
        NSLog(@"item %@ clicked!",[self getItemWithItemView:itemView].itemName);
    }
}

- (void)itemViewDidTouchUp:(ItemView*)itemView {
    if (_isEditing) {
        //手指离开屏幕.
        [self handleItemDrayStoping];
        
        [self layoutCurrentEditingItem];
    }
}

- (void)itemViewDidCancelEditing:(ItemView*)itemView {
    if (_isEditing) {
        [self cancelEditing];
    }
}

- (void)itemView:(ItemView *)itemView didLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.currentEditingView = itemView;
        
        self.currentEditingItem = [self getItemWithItemView:itemView];
        
        [ItemUtility deleteGridWithItem:self.currentEditingItem pageGrid:self.pageGrids[self.currentPageindex]];
        
        [self setEditing:YES];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"gesture cancel!");
       
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {

        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(preHandleItemlayout) object:nil];
        
        //手指离开桌面.
        [self handleItemDrayStoping];
        
        [self layoutCurrentEditingItem];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"gesture drag");
        
        [UIView animateWithDuration:0.08 animations:^{
            CGPoint centerPoint = [gestureRecognizer locationInView:self.contentScrollView];
            itemView.center = centerPoint;

        }];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(preHandleItemlayout) object:nil];
        [self performSelector:@selector(preHandleItemlayout) withObject:nil afterDelay:0.5];
    }
}

- (void)itemViewDidCancelTouch:(ItemView *)itemView {
    
}

- (void)itemViewDidDrag:(ItemView*)itemView point:(CGPoint)point {
    if (_isEditing) {
        //转化point为当前的point.
        CGPoint currentPoint = [self.contentScrollView convertPoint:point fromView:itemView];
        
        [UIView animateWithDuration:0.08 animations:^{
            itemView.center = currentPoint;

        }];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(preHandleItemlayout) object:nil];

        [self performSelector:@selector(preHandleItemlayout) withObject:nil afterDelay:0.5];
    }
}

- (void)deleteItem:(ItemView*)itemView {
    [UIView animateWithDuration:0.4 animations:^{
        itemView.alpha = 0;
        itemView.transform = CGAffineTransformMakeScale(0.001, 0.001);
    } completion:^(BOOL finished) {
        [itemView removeFromSuperview];

        NSInteger itemID = itemView.tag - baseTag;
        NSMutableArray *itemModel = _itemModels[_currentPageindex];
        
        NSInteger currentItemModel = [[itemModel valueForKey:@"itemID"] indexOfObject:@(itemID).stringValue];
        Item *item = itemModel[currentItemModel];
        [ItemUtility deleteGridWithItem:item  pageGrid:_pageGrids[_currentPageindex]];
        [itemModel removeObjectAtIndex:currentItemModel];
    }];
}

- (void)itemSizeChanged:(ItemView*)itemView {
    [self itemSizeChangedWithItemView:itemView];
}

- (void)preHandleItemlayout {
//    NSLog(@"begin pre layout");
      [self handleItemDrayStoping];
}

@end
