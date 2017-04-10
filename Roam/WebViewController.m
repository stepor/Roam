//
//  ViewController.m
//  Roam
//
//  Created by 黄文鸿 on 2017/3/3.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "WHScreen.h"
#import "WebViewController.h"
#import <Masonry/Masonry.h>
#import <KVOController/KVOController.h>
#import "WHPopView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Model+CoreDataModel.h"
#import "CoreDataHelper.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "SegmentViewController.h"
#import "BookmarksViewController.h"
#import "HIstoryViewController.h"
#import "MultitaskViewController.h"
#import "LineLayout.h"

static NSString *const kIsNightMode = @"isNightMode";

typedef NS_ENUM(NSInteger, TagTextField) {
    TagTextFieldTitle = 0,
    TagTextFieldURLString = 1
};

@interface WebViewController ()<WKNavigationDelegate, WKUIDelegate, UITextFieldDelegate, SegmentViewControllerDelegate>

@property (strong, nonatomic) WKWebView *webView;

//header view
@property (strong, nonatomic) UITextField *searchTextField;
@property (strong, nonatomic) UIBarButtonItem *rightItem;
@property (strong, nonatomic) UIProgressView *progressView;

//menu
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *forwardButton;
@property (strong, nonatomic) UIButton *menuButton;
@property (strong, nonatomic) UIButton *homeButton;
@property (strong, nonatomic) UIButton *multiTaskButton;

@property (strong, nonatomic) WHPopView *popView;

@property (strong, nonatomic) UIView *nightModeView;
@end

@implementation WebViewController

static NSString *const prefixSearchString = @"https://m.baidu.com/s?from=1011851a&word=";

#pragma mark - init method
- (instancetype)initWithPrivate:(BOOL)isPrivate {
    self = [super init];
    if(self) {
        _isPrivate = isPrivate;
    }
    return self;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    [self initialization];
    [self configureToolBar];
    [self configureNavigationItem];
    [self configureWebView];//webView
    [self initialProgressView];//progress view;
    [self setUpKVO];//KVO
    [self setUpConstraints];//constraint
    
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _snapshotView = [self.navigationController.view snapshotViewAfterScreenUpdates:YES];
}

#pragma mark - <WKNavigationDelegate>
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
    NSLog(@"%s", __func__);
    NSLog(@"navigation : %@", navigationAction);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __func__);
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
    NSLog(@"%s", __func__);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __func__);
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"%s", __func__);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"%s", __func__);
}


- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __func__);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%s", __func__);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%s", __func__);
    NSLog(@"%@", error);
}

#pragma mark - <WKUIDelegate>
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    
    
    NSLog(@"%s", __func__);
    return nil;
}



#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(textField == self.searchTextField) {
        textField.text = [self.webView.URL absoluteString];
        [self.navigationItem setRightBarButtonItem:self.rightItem animated:YES];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if(textField == self.searchTextField) {
        textField.text = self.webView.title;
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.searchTextField) {
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:textField.text]]) {
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:textField.text]]];
        } else {
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"baidu.com"]]];
            NSString *searchStr = [[prefixSearchString stringByAppendingString:textField.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:searchStr]]];
        }
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - <SegmentViewControllerDelegate>
- (void)SegmentViewController:(SegmentViewController *)segmentViewController didSelectItemAtIndex:(NSInteger)index {
    
    if(index == 0) {
        segmentViewController.navigationItem.rightBarButtonItem = nil;
    } else if(index == 1) {
        HistoryViewController *hvc = (HistoryViewController *)segmentViewController.childViewControllers[index];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStylePlain target:hvc action:@selector(clearAllHistories)];
        segmentViewController.navigationItem.rightBarButtonItem = rightItem;
    }
    
}



#pragma mark - Button Action
- (void)backButtonAction:(UIButton *)button {
    [self.webView goBack];
}

- (void)forwardButtonAction:(UIButton *)button {
    [self.webView goForward];
}


- (void)menuButtonAction:(UIButton *)button {
    static BOOL show = NO;
    __weak typeof(self) weakSelf = self;
    if(!show) {
        show = YES;
        UIEdgeInsets insets = UIEdgeInsetsMake(0.0, 0.0, 44.0, 0.0);
        
        BOOL isFullscreen = [[NSUserDefaults standardUserDefaults] boolForKey:kIsFullscreen];
        NSString *title_f = isFullscreen ? @"关闭全屏" : @"开启全屏";
        BOOL isNightMode = [[NSUserDefaults standardUserDefaults] boolForKey:kIsNightMode];
        NSString *title_n = isNightMode ? @"关闭夜间" : @"开启夜间";
        
        self.popView = [WHPopView showToView:self.view inserts:insets images:@[@"collect", @"bookmark", @"update", @"share", @"setting", @"fullscreen", @"nightMode"] titles:@[@"添加书签", @"书签/历史", @"刷新" , @"分享", @"设置", title_f, title_n] showBlock:^ {
            
        } hideBlock:^{
            typeof(weakSelf) strongSelf = weakSelf;
            show = NO;
            strongSelf.popView= nil;
        } selectedBlock:^(NSInteger index) {
            NSLog(@"seleted item at : %ld", index);
            typeof(weakSelf) strongSelf = weakSelf;
            switch (index) {
                case 0:
                    [strongSelf selectAddingBookmark];
                    break;
                case 1:
                    [strongSelf selectBookmarksAndHistory];
                    break;
                case 2:
                    [strongSelf selectRefresh];
                    break;
                case 3:
                    [strongSelf selectShare];
                    break;
                case 4:
                    [UIApplication sharedApplication].keyWindow.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
                    break;
                case 5:
                    [strongSelf selectFullscreen];
                    break;
                case 6:
                    [strongSelf selectNightMode];
                    break;
                default:
                    break;
            }
            [strongSelf.popView hide];
        
        }];
    } else {
        [self.popView hide];
    }
}

- (void)homeButtonAction:(UIButton *)button {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com/"]]];
}

- (void)multiTaskButtonAction:(UIButton *)button {
    MultitaskViewController *multitaskVC = [[MultitaskViewController alloc] init];
    
    
    CGFloat targetWidth = ([WHScreen width] - 2.0 * [LineLayout sideDistance]) * ([LineLayout zoomFactor] + 1);
    CGFloat targetHeight = targetWidth / [WHScreen whRatio];
    CGFloat targetX = ([WHScreen width] - targetWidth) / 2.0;
    CGFloat targetY = ([WHScreen height] - 44.0 - targetHeight) / 2.0;
    CGRect targetFrame = CGRectMake(targetX, targetY, targetWidth, targetHeight);
    
    UIView *view = [self.navigationController.view snapshotViewAfterScreenUpdates:YES];
    view.frame = [WHScreen bounds];
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [UIView animateWithDuration:0.3 animations:^{
        view.frame = targetFrame;
        view.alpha = 0.5;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
    
    [self presentViewController:multitaskVC animated:NO completion:nil];
}

- (void)rightItemAction {
    [self.searchTextField resignFirstResponder];
}

- (void)rightViewButtonAction:(UIButton *)button {
    if(self.webView.isLoading) {
        [self.webView stopLoading];
    }
}

#pragma mark - Button on menu action
- (void)selectAddingBookmark {
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isHistory == NO"];
    NSFetchRequest *fetchRequest = [WebViewInfo fetchRequest];
    fetchRequest.predicate = predicate;
    NSArray<WebViewInfo *> *arr = [[CoreDataHelper shareInstance].context executeFetchRequest:fetchRequest error:&error];
    if(error) {
        NSLog(@"Context Fail to execute fetch request: %@", error);
        return;
    }
    if(arr.count > 0) {//如果当前页面已经存在标签中，提示用户
        for(WebViewInfo *info in arr) {
            if([info.urlString isEqualToString:self.webView.URL.absoluteString]) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.removeFromSuperViewOnHide = YES;
                hud.mode = MBProgressHUDModeText;
                hud.minShowTime = 2.0;
                hud.label.text = [NSString stringWithFormat:@"已存在标签栏中，其标题为\"%@\"", info.title];
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 2);
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
                return;
            }
        }
    }
    [self showAddingBookmarkAlert];
}

- (void)selectBookmarksAndHistory {
// bookmark view controller
    BookmarksViewController *bookMarkVC = [[BookmarksViewController alloc] initWithStyle:UITableViewStyleGrouped];
    bookMarkVC.webView = self.webView;
    bookMarkVC.navigationItem.title = @"书签";
// history view controller
    HistoryViewController *histortyVC = [[HistoryViewController alloc] initWithStyle:UITableViewStyleGrouped];
    histortyVC.webView = self.webView;
    histortyVC.title = @"历史";
// segment view controller
    SegmentViewController *segmentVC = [[SegmentViewController alloc] initWithViewControllers:@[bookMarkVC, histortyVC]];
    segmentVC.delegate = self;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(leftItemAction:)];
    
    segmentVC.navigationItem.leftBarButtonItem = leftItem;
//navigation controller
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:segmentVC];
    navi.navigationBar.hidden = NO;
    
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)leftItemAction:(id)sender {
    UINavigationController *navi = (UINavigationController *)self.presentedViewController;
    SegmentViewController *segmentVC = (SegmentViewController *)navi.viewControllers[0];
    [self dismissViewControllerAnimated:YES completion:^{
        [segmentVC reomveAllChildViewControllers];
    }];
}

- (void)selectRefresh {
    [self.webView reloadFromOrigin];
}

- (void)selectShare {
    UIActivityViewController *activtyVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.webView.URL] applicationActivities:nil];
    [self presentViewController:activtyVC animated:YES completion:nil];
}

- (void)selectFullscreen {
    BOOL isFullscreen = ![[NSUserDefaults standardUserDefaults] boolForKey:kIsFullscreen];
    
    self.navigationController.hidesBarsOnSwipe = isFullscreen;
    if(self.popView) {
        NSString *title = isFullscreen ? @"关闭全屏" : @"开启全屏";
        [self.popView updateTitle:title atIndex:5];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:isFullscreen forKey:kIsFullscreen];
}

- (void)selectNightMode {
    BOOL isNightMode = ![[NSUserDefaults standardUserDefaults] boolForKey:kIsNightMode];
    
    if(isNightMode) {
        self.nightModeView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.nightModeView.backgroundColor = [UIColor colorWithRed:0.23 green:0.23 blue:0.23 alpha:0.2];
        self.nightModeView.userInteractionEnabled = NO;
        [[UIApplication sharedApplication].keyWindow addSubview:self.nightModeView];
    } else {
        [self.nightModeView removeFromSuperview];
        self.nightModeView = nil;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:isNightMode forKey:kIsNightMode];
}

#pragma mark - public methods




#pragma mark - private methods
- (void)initialization {
    self.navigationController.hidesBarsOnSwipe = [[NSUserDefaults standardUserDefaults] boolForKey:kIsFullscreen]; //全屏模式
    
    BOOL isNightMode = [[NSUserDefaults standardUserDefaults] boolForKey:kIsNightMode];
    if(isNightMode) {
        self.nightModeView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.nightModeView.backgroundColor = [UIColor colorWithRed:0.23 green:0.23 blue:0.23 alpha:0.2];
        self.nightModeView.userInteractionEnabled = NO;
        [[UIApplication sharedApplication].keyWindow addSubview:self.nightModeView];
    }
}

- (void)configureWebView {
    self.webView = [self initializeWebView:_isPrivate];
    [self.view addSubview:self.webView];
    __weak typeof(self) weakSelf = self;
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        typeof(weakSelf) strongSelf = weakSelf;
        make.edges.equalTo(strongSelf.view);
    }];
}

- (void)configureToolBar {
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.tintColor = [UIColor blackColor];
    
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) / 5.0;
    CGFloat heigt = 44.0;
    CGRect buttonFrame = CGRectMake(0.0, 0.0, width, heigt);
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame = buttonFrame;
    [self.backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.enabled = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.forwardButton.frame = buttonFrame;
    [self.forwardButton setImage:[UIImage imageNamed:@"forward"] forState:UIControlStateNormal];
    self.forwardButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.forwardButton addTarget:self action:@selector(forwardButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.forwardButton.enabled = NO;
    UIBarButtonItem *forwardItem = [[UIBarButtonItem alloc] initWithCustomView:self.forwardButton];
    
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = buttonFrame;
    [self.menuButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    self.menuButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.menuButton addTarget:self action:@selector(menuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuItem  = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
    
    self.homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.homeButton.frame = buttonFrame;
    [self.homeButton setImage:[UIImage imageNamed:@"homePage"] forState:UIControlStateNormal];
    self.homeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.homeButton addTarget:self action:@selector(homeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *homeItem = [[UIBarButtonItem alloc] initWithCustomView:self.homeButton];
    
    self.multiTaskButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.multiTaskButton.frame = buttonFrame;
    [self.multiTaskButton setImage:[UIImage imageNamed:@"multiTask"] forState:UIControlStateNormal];
    self.multiTaskButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.multiTaskButton addTarget:self action:@selector(multiTaskButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *multiTaskItem = [[UIBarButtonItem alloc] initWithCustomView:self.multiTaskButton];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
//    NSArray *items = @[backItem, forwardItem, menuItem, homeItem, multiTaskItem];
//    for(UIBarButtonItem *item in items) {
//        item.width = width;
//        
//    }
    
    self.toolbarItems = @[backItem, flexibleItem, forwardItem, flexibleItem, menuItem, flexibleItem, homeItem, flexibleItem, multiTaskItem];
    
}

- (void)configureNavigationItem {
    self.rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemAction)];
    [self setUpSearchTextField];
}


- (void)setUpSearchTextField {
    //textField
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth([UIScreen mainScreen].bounds), 30.0)];
    self.searchTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.navigationItem.titleView = self.searchTextField;
    self.searchTextField.delegate = self;
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;

    //textField right view
    UIButton *rightView = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightView addTarget:self action:@selector(rightViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    rightView.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    [rightView setTitle:@"X" forState:UIControlStateNormal];
    [rightView setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.searchTextField.rightView = rightView;
    self.searchTextField.rightViewMode = UITextFieldViewModeNever;
}

- (void)initialProgressView {
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.view addSubview:self.progressView];
    self.progressView.progressTintColor = [UIColor blueColor];
    self.progressView.progress = 0.0;
}

- (void)setUpKVO {
    //kvo
    FBKVOController *kvoController = [FBKVOController controllerWithObserver:self];
    self.KVOController = kvoController;
    __weak typeof(self) weakSelf = self;
    
    [self.KVOController observe:self.webView keyPath:@"canGoBack" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        typeof(weakSelf) strongSelf = weakSelf;
        NSNumber *num = (NSNumber *)change[NSKeyValueChangeNewKey];
        strongSelf.backButton.enabled = num.boolValue;
    }];
    [self.KVOController observe:self.webView keyPath:@"canGoForward" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        typeof(weakSelf) strongSelf = weakSelf;
        NSNumber *num = (NSNumber *)change[NSKeyValueChangeNewKey];
        strongSelf.forwardButton.enabled = num.boolValue;
    }];
    
    //about progress view and text field right view , history as well
    [self.KVOController observe:self.webView keyPath:@"loading" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        
        typeof(weakSelf) strongSelf = weakSelf;
        NSNumber *num = (NSNumber *)change[NSKeyValueChangeNewKey];
        if(num.boolValue) {
            strongSelf.progressView.hidden =NO; //progress view
            strongSelf.searchTextField.rightViewMode = UITextFieldViewModeUnlessEditing;//text field right view
            
        } else {
            strongSelf.progressView.hidden = YES; //progress view
            strongSelf.searchTextField.rightViewMode = UITextFieldViewModeNever; //text field right view
        }
    }];
    [self.KVOController observe:self.webView keyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        typeof(weakSelf) strongSelf  = weakSelf;
        if(strongSelf.progressView.isHidden) {
            return;
        }
        NSNumber *num = (NSNumber *)change[NSKeyValueChangeNewKey];
        strongSelf.progressView.progress = num.doubleValue;
        if(strongSelf.progressView.progress >= 9.9999) {
            strongSelf.progressView.hidden = YES;
        }
    }];
    
    // observe web view title
    [self.KVOController observe:self.webView keyPath:@"title" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.searchTextField.text = change[NSKeyValueChangeNewKey];
        
        //检查当前页面是否应该加入历史记录
        if(self.webView.title.length > 2) {
            [strongSelf addCurrentWebViewToHistory];
        }
    }];
}

- (void)setUpConstraints {

    id topGuide = self.topLayoutGuide;
    NSDictionary *pDic = NSDictionaryOfVariableBindings(_progressView, topGuide);
    NSArray *pConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide][_progressView(==1.0)]" options:0 metrics:nil views:pDic];
    [self.progressView.superview addConstraints:pConstraints];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressView.superview);
        make.right.equalTo(self.progressView.superview);
    }];
}

- (void)showAddingBookmarkAlert {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加书签" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action0 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        WebViewInfo *info = [NSEntityDescription insertNewObjectForEntityForName:@"WebViewInfo" inManagedObjectContext:[CoreDataHelper shareInstance].context];
        info.imageUrlString = [self iconURLString];
        info.date = [NSDate date];
        info.isHistory = NO;
        for(UITextField *textField in alert.textFields) {
            switch (textField.tag) {
                case TagTextFieldTitle:
                    info.title = textField.text;
                    break;
                case TagTextFieldURLString:
                    info.urlString = textField.text;
                    break;
                default:
                    break;
            }
        }
        
    }];
    [alert addAction:action0];
    [alert addAction:action1];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        typeof(weakSelf) strongSelf = weakSelf;
        textField.text = strongSelf.webView.title;
        textField.tag = TagTextFieldTitle;
        //textField.delegate = strongSelf;
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 18.0, 18.0)];
        textField.leftView = iconView;
        textField.enabled = NO;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        textField.leftViewMode = UITextFieldViewModeAlways;
        NSURL *iconURL = [NSURL URLWithString:[self iconURLString]];
        NSLog(@"url string: %@", [self iconURLString]);
        //[iconView sd_setImageWithURL:iconURL placeholderImage:[UIImage imageNamed:@"defaultIcon"]];
        
        [iconView sd_setImageWithURL:iconURL placeholderImage:[UIImage imageNamed:@"defaultIcon"] options:SDWebImageAllowInvalidSSLCertificates];
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        typeof(weakSelf) strongSelf = weakSelf;
        textField.tag = TagTextFieldURLString;
        //textField.delegate = strongSelf;
        textField.text = strongSelf.webView.URL.absoluteString;
        textField.enabled = NO;
    }];
    [self presentViewController:alert animated:YES completion:^{
        for(UITextField *textField in alert.textFields) {
            textField.enabled = YES;
        }
    }];
}

- (NSString *)iconURLString {
    NSString *absoluteStr = self.webView.URL.absoluteString;
    NSInteger toIndex = 0;
    NSInteger count  = 3;
    
    for(NSInteger i = 0; i < absoluteStr.length; i++) {
        unichar character = [absoluteStr characterAtIndex:i];
        if(character == '/') {
            count--;
            if(count == 0) {
                toIndex = i;
                break;
            }
        }
    }
    return [[absoluteStr substringToIndex:toIndex] stringByAppendingString:@"/favicon.ico"];
}

- (void)addCurrentWebViewToHistory {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K MATCHES %@ && isHistory == YES",@"title", self.webView.title];
    NSFetchRequest *fetchRequest = [WebViewInfo fetchRequest];
    fetchRequest.predicate = predicate;
    NSError *error  = nil;
    NSArray <WebViewInfo *> *arr = [[CoreDataHelper shareInstance].context executeFetchRequest:fetchRequest error:&error];
    if(error) {
        NSLog(@"Fetch request error : %@", error);
    }
    
    if(arr != nil  && arr.count > 0) {
        if(arr.count > 1) {
            @throw [NSException exceptionWithName:@"历史记录有重复" reason:@"不能重复历史记录" userInfo:nil];
        }
        WebViewInfo *info = arr[0];
        info.date = [NSDate date];
    } else {
        WebViewInfo *info = [NSEntityDescription insertNewObjectForEntityForName:@"WebViewInfo" inManagedObjectContext:[CoreDataHelper shareInstance].context];
        info.isHistory = YES;
        info.title = self.webView.title;
        info.imageUrlString = [self iconURLString];
        info.urlString = self.webView.URL.absoluteString;
        info.date = [NSDate date];
    }
}

- (WKWebView *)initializeWebView:(BOOL)isPrivate {
    
    if(isPrivate) {
        return nil;
    } else {
        WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
        configuration.allowsInlineMediaPlayback = YES;
        configuration.allowsAirPlayForMediaPlayback = YES;
        configuration.allowsPictureInPictureMediaPlayback = YES;
        configuration.mediaPlaybackRequiresUserAction = NO;
        configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
        
        WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        webView.allowsBackForwardNavigationGestures = YES;
        webView.UIDelegate = self;
        webView.navigationDelegate = self;
        [webView  loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com/"]]];
        
        return webView;
    }
}

@end
