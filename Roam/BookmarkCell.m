//
//  BookmarkCell.m
//  Roam
//
//  Created by 黄文鸿 on 2017/3/21.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "BookmarkCell.h"
#import <Masonry/Masonry.h>

@implementation BookmarkCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        _iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconImageView];
        
        _titleLabel = [UILabel new];
        [self.contentView addSubview:_titleLabel];
        _titleLabel.font = [UIFont systemFontOfSize:12.0];
        
        _urlLabel = [UILabel new];
        [self.contentView addSubview:_urlLabel];
        _urlLabel.font = [UIFont systemFontOfSize:12.0];
        
        [self setUpConstraints];
    }
    return self;
}

- (void)setUpConstraints {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.equalTo(self.iconImageView.superview).offset(10);
        make.bottom.equalTo(self.iconImageView.superview).offset(-10);
        make.height.equalTo(self.iconImageView.mas_width);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.superview).offset(4);
        make.right.equalTo(self.titleLabel.superview).offset(-4);
        make.left.equalTo(self.iconImageView.mas_right).offset(8);
    }];
    [self.urlLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self.iconImageView.mas_right).offset(8);
        make.bottom.equalTo(self.urlLabel.superview).offset(-4);
        make.right.equalTo(self.urlLabel.superview).offset(-4);
        make.height.equalTo(self.titleLabel.mas_height);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
