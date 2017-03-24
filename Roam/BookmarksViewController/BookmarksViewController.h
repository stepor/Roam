//
//  BookmarksViewController.h
//  Roam
//
//  Created by 黄文鸿 on 2017/3/21.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface BookmarksViewController : UITableViewController

@property (nonatomic, strong) WKWebView *currentWebView;

@end
