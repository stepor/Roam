//
//  WebViewManager.h
//  Roam
//
//  Created by 黄文鸿 on 2017/4/9.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebViewManager : NSObject

+ (instancetype)shareInstance;
- (WebViewController *)produceWebViewController:(BOOL)isPrivate; //产生的 web view controller 添加至对应的array中

- (NSArray<WebViewController *> *)webViewControllers;
- (NSArray<WebViewController *> *)privateWebViewControllers;

- (void)deleteWebViewController:(WebViewController *)webViewVC;
- (void)deleteWebViewcontrollerAtIndex:(NSUInteger)index;

- (void)deletePrivateWebViewController:(WebViewController *)webViewVC;
- (void)deletePrivateWEbViewControllerAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
