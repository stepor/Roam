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

@interface WebViewController : UIViewController


- (WKWebView *)initializeWebView:(BOOL)isPrivate;

@end

NS_ASSUME_NONNULL_END

