//
//  WebViewCell.h
//  Roam
//
//  Created by 黄文鸿 on 2017/4/8.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WebViewCellDelegate;

@interface WebViewCell : UICollectionViewCell

@property (weak, nonatomic) id<WebViewCellDelegate> delegate;
- (void)setDisplayView:(UIView *)view;

@end




@protocol WebViewCellDelegate <NSObject>

@required

- (void)WebViewCellDidSelectRomove:(WebViewCell *)webViewCell;

@end
