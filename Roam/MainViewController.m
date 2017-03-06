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
    
    //webView
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    self.webView.allowsBackForwardNavigationGestures = YES;
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.view insertSubview:self.webView belowSubview:self.menuView];
    
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 50.0, 0.0);
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com/"]]];

    //resign button
    self.resignButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.resignButton addTarget:self action:@selector(resignButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.resignButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.headerView addSubview:self.resignButton];
    
    //back and forward button
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
    [self.backButton addTarget:self action:@selector(goBackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton addTarget:self action:@selector(goForwardButton:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
    
    //menu button
    [self.menuButton addTarget:self action:@selector(menuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //textField
    self.searchTextField.delegate = self;
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.KVOController observe:self.webView keyPath:@"title" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.searchTextField.text = change[NSKeyValueChangeNewKey];
    }];
    
    //constraint
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
    [UIView animateWithDuration:0.2 animations:^{
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
    BOOL can = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"www.baidu.com"]];
    NSLog(@"can: %d", can);
}


@end
