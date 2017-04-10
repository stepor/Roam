//
//  WHScreen.m
//  Roam
//
//  Created by 黄文鸿 on 2017/4/9.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "WHScreen.h"

@implementation WHScreen

+ (CGFloat)width {
    return CGRectGetWidth([UIScreen mainScreen].bounds);
}
+ (CGFloat)height {
    return CGRectGetHeight([UIScreen mainScreen].bounds);
}
+ (CGRect)bounds {
    return [UIScreen mainScreen].bounds;
}
+ (CGFloat)whRatio {
    return [self width] / [self height];
}

@end
