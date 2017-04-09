//
//  RootViewController.m
//  Roam
//
//  Created by 黄文鸿 on 2017/4/9.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "RootViewController.h"
#import "WebViewManager.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController pushViewController:[[WebViewManager shareInstance] produceWebViewController:NO] animated:NO];
}


@end
