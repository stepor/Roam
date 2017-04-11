//
//  MultitaskViewController.h
//  Roam
//
//  Created by 黄文鸿 on 2017/4/7.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"

typedef NS_ENUM(NSUInteger, BrowsingMode) {
    BrowsingModePrivate = 0,
    BrowsingModeNonprivate
};

@interface MultitaskViewController : UIViewController

- (instancetype)initWithBrowsingMode:(BrowsingMode)browsingMode;

@end

