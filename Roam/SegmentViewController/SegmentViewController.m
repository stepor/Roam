//
//  SegmentViewController.m
//  Roam
//
//  Created by 黄文鸿 on 2017/3/18.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "SegmentViewController.h"
#import <Masonry/Masonry.h>

@interface SegmentViewController ()

@property (strong, nonatomic) UISegmentedControl *segmentControl;
@property (copy, nonatomic) NSArray<UIViewController *> *viewControllers;

@end

@implementation SegmentViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSMutableArray *titles = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    for(UIViewController *viewController in self.viewControllers) {
        [self addChildViewController:viewController];
        [self.view addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
//        NSInteger index = [self.viewControllers indexOfObject:viewController];
        [viewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            typeof(weakSelf) strongSelf = weakSelf;
//            if(index == 0) {
//                make.edges.equalTo(strongSelf.view);
//            } else {
//                make.top.equalTo(strongSelf.view).offset(64.0);
//                make.left.bottom.and.right.equalTo(self.view);
//            }
            
            make.edges.equalTo(strongSelf.view);
        }];
        [titles addObject:viewController.navigationItem.title];
    }
    [self showChildViewAtInex:0];
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:titles];
    [self.segmentControl addTarget:self action:@selector(segmentControlValueChangedAction:) forControlEvents:UIControlEventValueChanged];
    self.segmentControl.selectedSegmentIndex = 0;// 配合默认选项
    self.navigationItem.titleView = self.segmentControl;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view layoutIfNeeded];
}
#pragma mark - Initial
- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)vcs {
    self = [super init];
    if(self) {
        self.viewControllers = vcs;
    }
    return self;
}

#pragma mark - segment control action
- (void)segmentControlValueChangedAction:(UISegmentedControl *)sControl {
    [self showChildViewAtInex:sControl.selectedSegmentIndex];
    if([self.delegate respondsToSelector:@selector(SegmentViewController:didSelectItemAtIndex:)]) {
        [self.delegate SegmentViewController:self didSelectItemAtIndex:sControl.selectedSegmentIndex];
    }
}

#pragma mark - public methods
- (void)showChildViewAtInex:(NSInteger)index {
    for (NSInteger i = 0; i < self.childViewControllers.count; i++) {
        BOOL hidden = NO;
        if(index == i) {
            hidden = NO;
        } else {
            hidden = YES;
        }
        
        self.childViewControllers[i].view.hidden = hidden;
    }
}


- (void)reomveAllChildViewControllers {
    for(UIViewController *vc in self.childViewControllers) {
        [vc.view removeFromSuperview];
        [vc willMoveToParentViewController:nil];
        [vc removeFromParentViewController];
    }
}




@end
