//
//  WHPopView.h
//  Roam
//
//  Created by 黄文鸿 on 2017/3/9.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DidSelectedBlock)(NSInteger index);
static NSString *const kIsFullscreen = @"isFullScreen";

@interface WHPopView : UIView

+ (instancetype)showToView:(UIView *)superView inserts:(UIEdgeInsets)inserts images:(NSArray<NSString *> *)images titles:(NSArray<NSString *> *)titles showBlock:(void (^)())showBlock hideBlock:(void (^)())hideBlock selectedBlock:(DidSelectedBlock)block;

- (void)updateTitle:(NSString *)title atIndex:(NSInteger)index;
- (void)updateImage:(NSString *)imageName atIndex:(NSInteger)index;

- (void)hide;
@end
