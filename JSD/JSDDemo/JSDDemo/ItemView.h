//
//  ItemViewControl.h
//  JSDDemo
//
//  Created by Dana on 15/2/19.
//  Copyright (c) 2015年 Dana. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ItemView;

@protocol ItemViewDelegate <NSObject>

- (void)itemViewDidClicked:(ItemView*)itemView;

- (void)itemView:(ItemView*)itemView didLongPressed:(UILongPressGestureRecognizer*)gestureRecognizer;

- (void)itemViewDidTouchUp:(ItemView*)itemView;

- (void)itemViewDidCancelEditing:(ItemView*)itemView;

- (void)itemViewDidDrag:(ItemView*)itemView point:(CGPoint)point;

- (void)deleteItem:(ItemView*)itemView;

- (void)itemSizeChanged:(ItemView*)itemView;

@end

@interface ItemView : UIControl

@property (nonatomic, weak) id<ItemViewDelegate> delegate;

@property (nonatomic, weak) UIButton *closeButton;
@property (nonatomic, weak) UIButton *sizeChangeButton;

@property (nonatomic, strong) UIImageView *icon;


- (void)setEditing:(BOOL)editing editingItem:(BOOL)editingItem;

@end
