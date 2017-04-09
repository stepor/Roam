//
//  MultitaskViewController.m
//  Roam
//
//  Created by 黄文鸿 on 2017/4/7.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "MultitaskViewController.h"
#import <Masonry/Masonry.h>
#import "LineLayout.h"
#import "WebViewCell.h"
#import "WebViewManager.h"


static NSString *const reuse_ID = @"UICollectionViewCell_MultitaskViewController";

@interface MultitaskViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, WebViewCellDelegate>

@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UICollectionView *collectionView;

@end


@implementation MultitaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeCollectionView];
    [self setUpToolBar];
    [self setUpConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [WebViewManager shareInstance].webViewControllers.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WebViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuse_ID forIndexPath:indexPath];
    [cell setDisplayView:[WebViewManager shareInstance].webViewControllers[indexPath.row].snapshotView];
    return cell;
}

#pragma mark - <WebViewCellDelegate> 
- (void)WebViewCellDidSelectRomove:(WebViewCell *)webViewCell {
    NSLog(@"web view cell delegate!");
}

#pragma mark - initialize
- (void)initializeCollectionView {
    LineLayout *layout = [LineLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.view addSubview:self.collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor blackColor];
    [self.collectionView registerClass:[WebViewCell class] forCellWithReuseIdentifier:reuse_ID];
}

- (void)setUpToolBar {
    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.tintColor = [UIColor whiteColor];
    self.toolbar.barTintColor = [UIColor blackColor];
    [self.view addSubview:self.toolbar];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭全部" style:UIBarButtonItemStylePlain target:self action:@selector(closeItemAction)];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemAction)];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneItemAction)];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbar.items = @[closeItem, flexibleItem, addItem, flexibleItem, doneItem];
}


- (void)setUpConstraints {
    __weak typeof(self) weakSelf = self;
    [self.toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        typeof(weakSelf) strongSelf = weakSelf;
        make.left.right.and.bottom.equalTo(strongSelf.toolbar.superview);
        make.height.equalTo(@44.0);
    }];
    
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        typeof(weakSelf) strongSelf = weakSelf;
        make.left.right.and.top.equalTo(strongSelf.collectionView.superview);
        make.bottom.equalTo(strongSelf.toolbar.mas_top);
        
    }];
}

#pragma mark - bar button action
- (void)closeItemAction {
    
}

- (void)addItemAction {
    WebViewController *webViewVC = [[WebViewManager shareInstance] produceWebViewController:NO];
    UINavigationController *navi = (UINavigationController *)self.presentingViewController;
    [navi pushViewController:webViewVC animated:NO];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneItemAction {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
}


@end




