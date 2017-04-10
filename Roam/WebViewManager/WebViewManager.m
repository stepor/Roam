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


#pragma mark - public
- (WebViewController *)produceWebViewController:(BOOL)isPrivate {
    WebViewController *vc = [[WebViewController alloc] initWithPrivate:isPrivate];
    if(isPrivate) {
        [_privateWebViewConstrollers addObject:vc];
    } else {
        [_webViewControllers addObject:vc];
    }
    return vc;
}

- (NSArray<WebViewController *> *)webViewControllers {
    return [_webViewControllers copy];
}

- (NSArray<WebViewController *> *)privateWebViewControllers {
    return [_privateWebViewConstrollers copy];
}

- (void)deleteWebViewController:(WebViewController *)webViewVC {
    [_webViewControllers removeObject:webViewVC];
}
- (void)deleteWebViewcontrollerAtIndex:(NSUInteger)index {
    [_webViewControllers removeObjectAtIndex:index];
}

- (void)deletePrivateWebViewController:(WebViewController *)webViewVC {
    [_privateWebViewConstrollers removeObject:webViewVC];
}
- (void)deletePrivateWEbViewControllerAtIndex:(NSUInteger)index {
    [_privateWebViewConstrollers removeObjectAtIndex:index];
}

@end
