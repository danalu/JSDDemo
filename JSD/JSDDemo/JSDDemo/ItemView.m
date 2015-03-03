//
//  ItemViewControl.m
//  JSDDemo
//
//  Created by Dana on 15/2/19.
//  Copyright (c) 2015年 Dana. All rights reserved.
//

#import "ItemView.h"
#import "ALView+PureLayout.h"

@interface ItemView() {
    BOOL _isDraging;
    BOOL _isEditing;
}

@end

@implementation ItemView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self viewLayout];
    }
    return self;
}

- (void)viewLayout {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    [self addSubview:imageView];
    
    [self addConstraints:[imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)]];
    
    self.icon = imageView;
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(deleteItem) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton = closeButton;
    [self.closeButton sizeToFit];
    [self addSubview:closeButton];
    [self addConstraint:[closeButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:-5]];
    [self addConstraint:[closeButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:-5]];
    closeButton.hidden = YES;
    
    UIButton *sizeChangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sizeChangeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [sizeChangeButton addTarget:self action:@selector(sizeChange) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sizeChangeButton];
    
    self.sizeChangeButton = sizeChangeButton;
    self.sizeChangeButton.hidden = YES;
    
    [self addConstraint:[sizeChangeButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:-5]];
    [self addConstraint:[sizeChangeButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:-5]];
    
    [self addTarget:self action:@selector(itemTouchClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(itemTouchDrag:event:) forControlEvents:UIControlEventTouchDragInside];
    
    UILongPressGestureRecognizer *longPressGetureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressItem:)];
    [self addGestureRecognizer:longPressGetureRecognizer];
    
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTouchClicked)];
//    [self addGestureRecognizer:tapGestureRecognizer];
    
    _isDraging = NO;
}

- (void)setEditing:(BOOL)editing editingItem:(BOOL)editingItem {
    _isEditing = editing;
    if (editing) {
        if (editingItem) {
            self.closeButton.hidden = NO;
            self.sizeChangeButton.hidden = NO;
        } else {
            //开始动画.
            [UIView animateWithDuration:0.4 animations:^{
                self.transform = CGAffineTransformMakeScale(0.8, 0.8);
                self.closeButton.hidden = YES;
                self.sizeChangeButton.hidden = YES;
            }];
            
            CABasicAnimation* rotationAnimation;
            rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.fromValue = [NSNumber numberWithFloat:-M_PI / 72];
            rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI/ 72];
            rotationAnimation.duration = 4;
            rotationAnimation.autoreverses = YES;
            rotationAnimation.repeatCount = MAXFLOAT;
            
            [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        }
    } else {
        if (editingItem) {
            self.closeButton.hidden = YES;
            self.sizeChangeButton.hidden = YES;
        } else {
            [UIView animateWithDuration:0.4 animations:^{
                self.closeButton.hidden = YES;
                self.sizeChangeButton.hidden = YES;
                self.transform = CGAffineTransformIdentity;
            }];
            
            [self.layer removeAnimationForKey:@"rotationAnimation"];
        }
    }
}

#pragma mark Event
- (void)itemTouchClicked:(UIControl*)control {
    if (_isEditing) {
        if (_isDraging) {
            if ([_delegate respondsToSelector:@selector(itemViewDidTouchUp:)]) {
                [_delegate itemViewDidTouchUp:self];
            }
        } else {
            if ([_delegate respondsToSelector:@selector(itemViewDidCancelEditing:)]) {
                [_delegate itemViewDidCancelEditing:self];
            }
        }
        
        _isDraging = NO;
    } else {
        if ([_delegate respondsToSelector:@selector(itemViewDidClicked:)]) {
            [_delegate itemViewDidClicked:self];
        }
    }
}

//- (void)itemTouchClicked {
//    if ([_delegate respondsToSelector:@selector(itemViewDidClicked:)]) {
//        [_delegate itemViewDidClicked:self];
//    }
//}


- (void)itemTouchDrag:(UIControl*)control event:(UIEvent*)event {
    UITouch *touch = [event allTouches].anyObject;
    CGPoint point = [touch locationInView:self];
    
    _isDraging = YES;
    
    if ([_delegate respondsToSelector:@selector(itemViewDidDrag:point:)]) {
        [_delegate itemViewDidDrag:self point:point];
    }
}

- (void)longPressItem:(UILongPressGestureRecognizer*)gestureRecognzier {
    if ([_delegate respondsToSelector:@selector(itemView:didLongPressed:)]) {
        [_delegate itemView:self didLongPressed:gestureRecognzier];
    }
    
    if (gestureRecognzier.state == UIGestureRecognizerStateBegan) {
        NSLog(@"gesture begin!");
        self.closeButton.hidden = NO;
        self.sizeChangeButton.hidden = NO;

     } else if (gestureRecognzier.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"gesture cancel!");
    } else if (gestureRecognzier.state == UIGestureRecognizerStateEnded) {
        NSLog(@"gesture end!");
    } else if (gestureRecognzier.state == UIGestureRecognizerStateChanged) {
        NSLog(@"gesture drag");
    }

}

- (void)deleteItem {
    if ([_delegate respondsToSelector:@selector(deleteItem:)]) {
        [_delegate deleteItem:self];
    }
}

- (void)sizeChange {
    if ([_delegate respondsToSelector:@selector(itemSizeChanged:)]) {
        [_delegate itemSizeChanged:self];
    }
}

@end
