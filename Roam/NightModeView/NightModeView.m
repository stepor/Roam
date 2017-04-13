//
//  NightModeView.m
//  Roam
//
//  Created by 黄文鸿 on 2017/4/12.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "NightModeView.h"
#import "WHScreen.h"

static UIView *_nightView = nil;

@implementation NightModeView

+ (void)show {
    _nightView = [[UIView alloc] initWithFrame:[WHScreen bounds]];
    _nightView.userInteractionEnabled = NO;
    _nightView.backgroundColor = [UIColor colorWithRed:0.23 green:0.23 blue:0.23 alpha:1.0];
    CGFloat alpha = [[NSUserDefaults standardUserDefaults] floatForKey:key_brightness];
    _nightView.alpha = (alpha > 0.1999  && alpha < 0.7001) ? alpha : 0.2;
    [[UIApplication sharedApplication].keyWindow addSubview:_nightView];
}

+ (void)hide {
    if(_nightView) {
        [_nightView removeFromSuperview];
        _nightView = nil;
    }
}

+ (void)setGrayLevel:(CGFloat)num {
    if(_nightView) {
        _nightView.alpha = num;
    }
    [[NSUserDefaults standardUserDefaults] setFloat:num forKey:key_brightness];
}

+ (CGFloat)currentGrayLevel {
    CGFloat level = [[NSUserDefaults standardUserDefaults] floatForKey:key_brightness];
    return (level >= [self minAlpha] && level <= [self maxAlpha]) ? level : [self minAlpha];
}

+ (CGFloat)maxAlpha {
    return 0.7;
}

+ (CGFloat)minAlpha {
    return 0.2;
}
@end
