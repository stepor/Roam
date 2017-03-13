//
//  WHPopView.h
//  Roam
//
//  Created by 黄文鸿 on 2017/3/9.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DidSelectedBlock)(NSInteger index);

@interface WHPopView : UIView

+ (instancetype)showToView:(UIView *)superView inserts:(UIEdgeInsets)inserts images:(NSArray<NSString *> *)images titles:(NSArray<NSString *> *)titles showBlock:(void (^)())showBlock hideBlock:(void (^)())hideBlock selectedBlock:(DidSelectedBlock)block;

- (void)hide;
@end
