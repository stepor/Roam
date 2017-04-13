//
//  NightModeView.h
//  Roam
//
//  Created by 黄文鸿 on 2017/4/12.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const key_brightness = @"brightness";

@interface NightModeView : NSObject

+ (void)show;
+ (void)hide;
+ (void)setGrayLevel:(CGFloat)num;
+ (CGFloat)maxAlpha;
+ (CGFloat)minAlpha;
+ (CGFloat)currentGrayLevel;

@end
