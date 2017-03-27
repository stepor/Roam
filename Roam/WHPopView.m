//
//  WHPopView.m
//  Roam
//
//  Created by 黄文鸿 on 2017/3/9.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "WHPopView.h"
#import "ItemCell.h"

@interface WHPopView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray<NSString *> *images;
@property (strong, nonatomic) NSMutableArray<NSString *> *titles;
@property (copy, nonatomic) DidSelectedBlock selectedBlock;
@property (copy, nonatomic) void (^showBlock)();
@property (copy, nonatomic) void (^hideBblock)();

@end

@implementation WHPopView

static NSString *const reuseID_itemCell = @"itemCell";

+ (instancetype)showToView:(UIView *)superView inserts:(UIEdgeInsets)inserts images:(NSArray<NSString *> *)images titles:(NSArray<NSString *> *)titles showBlock:(void (^)())showBlock hideBlock:(void (^)())hideBlock selectedBlock:(DidSelectedBlock)block {
    
    // trunslucent view
    CGRect originalFrame = superView.bounds;
    CGRect frame = CGRectMake(CGRectGetMinX(originalFrame) + inserts.left, CGRectGetMinY(originalFrame) + inserts.top, CGRectGetWidth(originalFrame) - inserts.left - inserts.right, CGRectGetHeight(originalFrame) - inserts.top - inserts.bottom);
    WHPopView *view  = [[WHPopView alloc] initWithFrame:frame];
    [superView addSubview:view];
    view.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3];
    view.clipsToBounds = YES;
    
    // images , title  , block
    view.images = [NSMutableArray arrayWithArray:images];
    view.titles = [NSMutableArray arrayWithArray:titles];
    view.selectedBlock = block;
    view.showBlock = showBlock;
    view.hideBblock = hideBlock;
    
    //collection view
      // flow layout
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat itemSize = CGRectGetWidth(view.bounds) / 4.0;
    flowLayout.itemSize = CGSizeMake(itemSize, itemSize * 0.75);
    flowLayout.minimumLineSpacing = 10.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    
    CGFloat rows = ceil(view.images.count / 4.0);
    CGFloat height = rows * itemSize * 0.75 + rows * flowLayout.minimumLineSpacing;
    CGFloat width = CGRectGetWidth(view.bounds);
    
    CGRect aFrame = CGRectMake(0.0, CGRectGetHeight(view.bounds), width, height);
    view.collectionView = [[UICollectionView alloc] initWithFrame:aFrame collectionViewLayout:flowLayout];
    [view addSubview: view.collectionView];
    view.collectionView.scrollEnabled = NO;
    view.collectionView.dataSource = view;
    view.collectionView.delegate = view;
    view.collectionView.backgroundColor = [UIColor whiteColor];
    
    [view.collectionView registerNib:[UINib nibWithNibName:@"ItemCell" bundle:nil] forCellWithReuseIdentifier:reuseID_itemCell];

    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
         view.collectionView.transform = CGAffineTransformMakeTranslation(0.0, -height);
    } completion:^(BOOL finished) {
        if(finished) {
            view.showBlock();
        }
    }];
    
    return view;
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if(self.images) {
        return self.images.count;
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseID_itemCell forIndexPath:indexPath];
    UIImage *image = [UIImage imageNamed:self.images[indexPath.row]];
    cell.iconImageView.image = image;
    cell.titleLabel.text = self.titles[indexPath.row];
    
    return cell;
}

- (void)hide{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.collectionView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if(finished) {
            self.hideBblock();
            [self removeFromSuperview];
        }
    }];
}




#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedBlock(indexPath.row);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hide];
}

#pragma mark - Public methods
- (void)updateTitle:(NSString *)title atIndex:(NSInteger)index {
    [self.titles replaceObjectAtIndex:index withObject:title];
    [self.collectionView reloadData];
}

- (void)updateImage:(NSString *)imageName atIndex:(NSInteger)index {
    [self.images replaceObjectAtIndex:index withObject:imageName];
    [self.collectionView reloadData];
}

@end
