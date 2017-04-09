//
//  ViewController.h
//  Roam
//
//  Created by 黄文鸿 on 2017/3/3.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : UIViewController

@property (strong, nonatomic, readonly) NSArray<UIView *> *snapshotViews;

- (WKWebView *)initializeWebView:(BOOL)isPrivate;

- (NSArray<WKWebView *> *)webViews;
- (NSArray<WKWebView *> *)privateWebViews;

- (void)displayNewWebView:(BOOL)isPrivate;

- (void)removeWebView:( WKWebView *)webView;
- (void)removeWebViewAtIndex:(NSUInteger)index;
- (void)removePrivateWebView:(WKWebView *)privateWebView;
- (void)removePrivateWebViewAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END

