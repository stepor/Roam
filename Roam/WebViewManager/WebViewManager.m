//
//  WebViewManager.m
//  Roam
//
//  Created by 黄文鸿 on 2017/4/9.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "WebViewManager.h"
#import "WebViewController.h"

@implementation WebViewManager {
    NSMutableArray<WebViewController *> *_webViewControllers;
    NSMutableArray<WebViewController *> *_privateWebViewConstrollers;
}

#pragma mark - init methods

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static WebViewManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initPrivate];
    });
    return instance;
}

- (instancetype)initPrivate {
    self = [super init];
    if(self) {
        _webViewControllers = [NSMutableArray array];
        _privateWebViewConstrollers = [NSMutableArray array];
    }
    return self;
}

- (instancetype)init {
    return [WebViewManager shareInstance];
}

- (instancetype)copy {
    return [WebViewManager shareInstance];
}



@end
