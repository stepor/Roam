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
#import <SDWebImage/UIImageView+WebCache.h>
#import "Model+CoreDataModel.h"
#import "CoreDataHelper.h"
#import <MBProgressHUD/MBProgressHUD.h>

typedef NS_ENUM(NSInteger, TagTextField) {
    TagTextFieldTitle = 0,
    TagTextFieldURLString = 1
};

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
    if(textField == self.searchTextField) {
        CGFloat constant = self.trailingOfSearchTextField.constant;
        textField.text = [self.webView.URL absoluteString];
        _offsetOfSearchTextFieldTrailing = CGRectGetWidth(self.resignButton.bounds) + constant;
        self.trailingOfSearchTextField.constant += _offsetOfSearchTextFieldTrailing;
        [UIView animateWithDuration:0.5 animations:^{
            [self.headerView layoutIfNeeded];
        }];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if(textField == self.searchTextField) {
        textField.text = self.webView.title;
        self.trailingOfSearchTextField.constant -= _offsetOfSearchTextFieldTrailing;
        [UIView animateWithDuration:0.5 animations:^{
            [self.headerView layoutIfNeeded];
        }];
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
        
            [popView hide];
            if(index == 0) {
                NSError *error = nil;
                NSArray<WebViewInfo *> *arr = [[CoreDataHelper shareInstance].context executeFetchRequest:[WebViewInfo fetchRequest] error:&error];
                if(error) {
                    NSLog(@"Context Fail to execute fetch request: %@", error);
                    return;
                }
                if(arr.count > 0) {//如果当前页面已经存在标签中，提示用户
                    for(WebViewInfo *info in arr) {
                        if([info.urlString isEqualToString:strongSelf.webView.URL.absoluteString]) {
                            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
                            hud.removeFromSuperViewOnHide = YES;
                            hud.mode = MBProgressHUDModeText;
                            hud.minShowTime = 2.0;
                            hud.label.text = [NSString stringWithFormat:@"已存在标签栏中，其标题为\"%@\"", info.title];
                            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 2);
                            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                                [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                            });
                            return;
                        }
                    }
                }
                
                
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
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加书签" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action0 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        WebViewInfo *info = [NSEntityDescription insertNewObjectForEntityForName:@"WebViewInfo" inManagedObjectContext:[CoreDataHelper shareInstance].context];
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
        [iconView sd_setImageWithURL:iconURL placeholderImage:[UIImage imageNamed:@"defaultIcon"]];
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

@end
