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
static BrowsingMode _browsingMode = BrowsingModeNonprivate;

@interface MultitaskViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, WebViewCellDelegate>

@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UICollectionView *collectionView;

//tool bar item
@property (strong, nonatomic) UIBarButtonItem *privateBrowsingItem;
@property (strong, nonatomic) UIBarButtonItem *doneItem;

@end




@implementation MultitaskViewController

#pragma mark -  Initialization
- (instancetype)initWithBrowsingMode:(BrowsingMode)browsingMode {
    self = [super init];
    if(self) {
        _browsingMode = browsingMode;
    }
    return self;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self initializeCollectionView];
    [self setUpToolBar];
    [self setUpConstraints];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //让 collection view 滚动到对应的 web view 的 cell
    UINavigationController *navi = (UINavigationController *)self.presentingViewController;
    NSArray *array = nil;
    if(_browsingMode == BrowsingModePrivate) {
        array = [WebViewManager shareInstance].privateWebViewControllers;
    } else {
        array = [WebViewManager shareInstance].webViewControllers;
    }
    NSUInteger row = [array indexOfObject:navi.topViewController];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically|UICollectionViewScrollPositionCenteredHorizontally animated:NO];
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
    if(_browsingMode == BrowsingModePrivate) {
        return [WebViewManager shareInstance].privateWebViewControllers.count;
    } else {
        return [WebViewManager shareInstance].webViewControllers.count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WebViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuse_ID forIndexPath:indexPath];
    if(_browsingMode == BrowsingModePrivate) {
        [cell setDisplayView:[WebViewManager shareInstance].privateWebViewControllers[indexPath.row].snapshotView];
    } else {
        [cell setDisplayView:[WebViewManager shareInstance].webViewControllers[indexPath.row].snapshotView];
    }
    if(cell.delegate == nil) {
        cell.delegate = self;
    }
    return cell;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    UINavigationController *navi = (UINavigationController *)self.presentingViewController;
    WebViewController *webViewVC = nil;
    if(_browsingMode == BrowsingModePrivate) {
        webViewVC = [WebViewManager shareInstance].privateWebViewControllers[indexPath.row];
    } else {
        webViewVC = [WebViewManager shareInstance].webViewControllers[indexPath.row];
    }
    [navi setViewControllers:@[webViewVC]];
}

#pragma mark - <WebViewCellDelegate> 
- (void)WebViewCellDidSelectRomove:(WebViewCell *)webViewCell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:webViewCell];
    if(_browsingMode == BrowsingModePrivate) {
        [[WebViewManager shareInstance] deletePrivateWEbViewControllerAtIndex:indexPath.row];
    } else {
        [[WebViewManager shareInstance] deleteWebViewcontrollerAtIndex:indexPath.row];
    }
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        if(finished) {
            //如果所有的 web view controller 都被移出，则新建一个 并 dismiss 多任务窗口
            if([WebViewManager shareInstance].webViewControllers.count < 1 && _browsingMode == BrowsingModeNonprivate) {
                WebViewController *vc = [[WebViewManager shareInstance] produceWebViewController:NO];
                UINavigationController *navi = (UINavigationController *)self.presentingViewController;
                [navi setViewControllers:@[vc]];
                [navi dismissViewControllerAnimated:YES completion:nil];
            } else if(_browsingMode == BrowsingModePrivate) {
                if([WebViewManager shareInstance].privateWebViewControllers.count < 1) {
                    self.doneItem.enabled = NO;
                } else {
                    self.doneItem.enabled = YES;
                }
            }
        }
    }];
    
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
    
    NSString *title = (_browsingMode == BrowsingModePrivate? @"关闭无痕浏览" : @"开启无痕浏览");
    self.privateBrowsingItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(privateBrowsingItemAction)];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemAction)];
    
    self.doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneItemAction)];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbar.items = @[self.privateBrowsingItem, flexibleItem, addItem, flexibleItem, self.doneItem];
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
- (void)privateBrowsingItemAction {
    _browsingMode = (_browsingMode == BrowsingModeNonprivate ? BrowsingModePrivate : BrowsingModeNonprivate);
    if(_browsingMode == BrowsingModePrivate) {
        self.privateBrowsingItem.title = @"关闭无痕浏览";
        if([WebViewManager shareInstance].privateWebViewControllers.count < 1) {
            self.doneItem.enabled = NO;
        }
        
    } else {
        self.privateBrowsingItem.title = @"开启无痕浏览";
        if(self.doneItem.enabled == NO) {
            self.doneItem.enabled = YES;
        }
    }
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:0]];
        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
}

- (void)addItemAction {
    WebViewController *webViewVC = nil;
    if(_browsingMode == BrowsingModePrivate) {
        webViewVC = [[WebViewManager shareInstance] produceWebViewController:YES];
    } else {
        webViewVC = [[WebViewManager shareInstance] produceWebViewController:NO];
    }
    UINavigationController *navi = (UINavigationController *)self.presentingViewController;
    [navi setViewControllers:@[webViewVC]];
    [navi dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneItemAction {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end




