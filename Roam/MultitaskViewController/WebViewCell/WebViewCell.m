//
//  WebViewCell.m
//  Roam
//
//  Created by 黄文鸿 on 2017/4/8.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "WebViewCell.h"
#import <Masonry/Masonry.h>

@interface WebViewCell ()

@property (strong, nonatomic) UIButton *removeButton;


@end

@implementation WebViewCell {
    UIView *_displayView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self =  [super initWithFrame:frame];
    if(self) {
        self.removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.removeButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.416 blue:0.416 alpha:0.8];
        [self.removeButton setTitle:@"移除" forState:UIControlStateNormal];
        [self.removeButton addTarget:self action:@selector(removeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.removeButton.frame = self.contentView.bounds;
        [self.contentView addSubview: self.removeButton];
                __weak typeof(self) weakSelf = self;
                [self.removeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    typeof(weakSelf) strongSelf = weakSelf;
                    make.left.right.and.bottom.equalTo(strongSelf.removeButton.superview);
                    make.height.equalTo(@44.0);
                }];
    }
    return self;
}


- (void)setDisplayView:(UIView *)view {
    if(_displayView) {
        [_displayView removeFromSuperview];
    }
    
    _displayView = view;
    [self.contentView insertSubview:view belowSubview:self.removeButton];
    __weak typeof(view) weakView = view;
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        typeof(weakView) strongView = weakView;
        make.edges.equalTo(strongView.superview);
    }];
}

- (void)removeButtonAction:(UIButton *)button {
    if(self.delegate && [self.delegate respondsToSelector:@selector(WebViewCellDidSelectRomove:)]) {
        [self.delegate WebViewCellDidSelectRomove:self];
    }
    
    NSLog(@"Cell remove button did select");
}

@end
