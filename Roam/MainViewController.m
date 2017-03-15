//
//  ViewController.m
//  Roam
//
//  Created by 黄文鸿 on 2017/3/3.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "MainViewController.h"
#import <WebKit/WebKit.h>
#import <Masonry/Masonry.h>
#import <KVOController/KVOController.h>
#import <BHBPopView/BHBPopView.h>
#import "WHPopView.h"

@interface MainViewController ()<WKNavigationDelegate, WKUIDelegate, UITextFieldDelegate>

@property (strong, nonatomic) WKWebView *webView;
//header view
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) UIButton *resignButton;
@property (strong, nonatomic) UIProgressView *progressView;

//menu
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

//constraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingOfSearchTextField;

@end

@implementation MainViewController {
    CGFloat _offsetOfSearchTextFieldTrailing;
}

static NSString *const prefixSearchString = @"https://m.baidu.com/s?from=1011851a&word=";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeWebView];//webView
    [self initializeResignButton];//resign button
    [self setUpBackForwardAndMenuButton];//back , forward and menu button
    [self setUpSearchTextField];//search text field
    [self initialProgressView];//progress view;
    [self setUpKVO];//KVO
    [self setUpConstraints];//constraint
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <WKNavigationDelegate>
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
    NSLog(@"%s", __func__);
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

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    CGFloat constant = self.trailingOfSearchTextField.constant;
    textField.text = [self.webView.URL absoluteString];
    _offsetOfSearchTextFieldTrailing = CGRectGetWidth(self.resignButton.bounds) + constant;
    self.trailingOfSearchTextField.constant += _offsetOfSearchTextFieldTrailing;
    [UIView animateWithDuration:0.5 animations:^{
        [self.headerView layoutIfNeeded];
    }];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    textField.text = self.webView.title;
    self.trailingOfSearchTextField.constant -= _offsetOfSearchTextFieldTrailing;
    [UIView animateWithDuration:0.5 animations:^{
        [self.headerView layoutIfNeeded];
    }];
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
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:textField.text]]) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:textField.text]]];
    } else {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"baidu.com"]]];
        NSString *searchStr = [[prefixSearchString stringByAppendingString:textField.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:searchStr]]];
    }
    return YES;
}

#pragma mark - Button Action
- (void)goBackButtonAction:(UIButton *)button {
    
    WKNavigation *navi = [self.webView goBack];
    NSLog(@"%@",navi);
}

- (void)goForwardButton:(UIButton *)button {
    WKNavigation *navi = [self.webView goForward];
    //[self updateBackForwardButtonState];
    NSLog(@"%@", navi);
}

- (void)resignButtonAction:(UIButton *)button {
    [self.searchTextField resignFirstResponder];
}

- (void)menuButtonAction:(UIButton *)button {
    static BOOL show = NO;
    static WHPopView *popView = nil;
    __weak typeof(self) weakSelf = self;
    if(!show) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0.0, 0.0, CGRectGetHeight(self.menuView.bounds), 0.0);
        
        popView = [WHPopView showToView:self.view inserts:insets images:@[@"collect", @"bookmark", @"update", @"share", @"setting"] titles:@[@"添加书签", @"书签/历史", @"刷新" , @"分享", @"设置"] showBlock:^ {
            show = YES;
        } hideBlock:^{
            show = NO;
            popView= nil;
        } selectedBlock:^(NSInteger index) {
            
            NSLog(@"seleted item at : %ld", index);
            typeof(weakSelf) strongSelf = weakSelf;
            if(index == 0) {
                [popView hide];
                [strongSelf showAddingBookmarkAlert];
            }
        }];
    } else {
        [popView hide];
    }
}

- (void)rightViewButtonAction:(UIButton *)button {
    if(self.webView.isLoading) {
        [self.webView stopLoading];
    }
}

#pragma mark - private methods
- (void)initializeWebView {
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    self.webView.allowsBackForwardNavigationGestures = YES;
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.view insertSubview:self.webView belowSubview:self.menuView];
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 50.0, 0.0);
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com/"]]];
}

- (void)initializeResignButton {
    self.resignButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.resignButton addTarget:self action:@selector(resignButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.resignButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.headerView addSubview:self.resignButton];
}

- (void)setUpBackForwardAndMenuButton {
    //back and forward button
    [self.backButton addTarget:self action:@selector(goBackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton addTarget:self action:@selector(goForwardButton:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
    
    //menu button
    [self.menuButton addTarget:self action:@selector(menuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.menuButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setUpSearchTextField {
    //textField
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
    [self.headerView addSubview:self.progressView];
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
    
    //about progress view and text field right view
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
    }];
}

- (void)setUpConstraints {
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [self.resignButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchTextField.mas_right).offset(8.0);
        make.top.equalTo(self.searchTextField.mas_top);
        make.bottom.equalTo(self.searchTextField.mas_bottom);
        make.width.equalTo(@40.0);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView);
        make.bottom.equalTo(self.headerView);
        make.right.equalTo(self.headerView);
        make.height.equalTo(@3.0);
    }];
}

- (void)showAddingBookmarkAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加书签" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action0 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"absolutely: %@", self.webView.URL.absoluteString);
    }];
    [alert addAction:action0];
    [alert addAction:action1];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"have a try!";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"one more time!";
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
