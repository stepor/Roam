//
//  ItemCell.m
//  Roam
//
//  Created by 黄文鸿 on 2017/3/9.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "ItemCell.h"

@implementation ItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    CGFloat fontSize = 17.0;
    if(CGRectGetHeight([UIScreen mainScreen].bounds) == 568.0) {
        fontSize = 12.0;
    }
    self.titleLabel.font = [UIFont systemFontOfSize:fontSize];
}

@end
