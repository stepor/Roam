//
//  ItemCell.m
//  Roam
//
//  Created by 黄文鸿 on 2017/3/9.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "ItemCell.h"
#import "WHScreen.h"

@implementation ItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    CGFloat fontSize = 14.0;
    CGFloat screenWidth = [WHScreen width];
    if(screenWidth == 568.0) {
        fontSize = 11.0;
    } else if (screenWidth == 667.0) {
        fontSize = 12.0;
    }
    self.titleLabel.font = [UIFont systemFontOfSize:fontSize];
}

@end
