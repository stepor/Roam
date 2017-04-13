//
//  NavigationController.m
//  Roam
//
//  Created by 黄文鸿 on 2017/4/11.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "NavigationController.h"

@implementation NavigationController


- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

@end
