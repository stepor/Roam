//
//  HIstoryViewController.h
//  Roam
//
//  Created by 黄文鸿 on 2017/3/23.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface HistoryViewController : UITableViewController

@property (nonatomic, strong) WKWebView *webView;
- (void)clearAllHistories;

@end
