//
//  GridLayoutView.h
//  JSDDemo
//
//  Created by Dana on 15/2/17.
//  Copyright (c) 2015年 Dana. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ItemView,Item;


@interface GridLayoutView : UIView {
    BOOL _isEditing;
}

@property (nonatomic, weak) id delegate;

@property (nonatomic,weak) UIScrollView *contentScrollView;

@property (nonatomic, strong) NSMutableArray *itemModels;
@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic, strong) NSMutableArray *pageGrids;

@property (nonatomic, strong) ItemView *currentEditingView;
@property (nonatomic, strong) Item *currentEditingItem;

@property (nonatomic) NSInteger maxPageNumber;
@property (nonatomic) NSInteger currentPageindex;

@end

@protocol GridLayoutViewDelegate <NSObject>

- (void)gridLayoutDidSelected:(GridLayoutView*)gridLayoutView;

@end
