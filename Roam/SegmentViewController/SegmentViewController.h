//
//  SegmentViewController.h
//  Roam
//
//  Created by 黄文鸿 on 2017/3/18.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SegmentViewControllerDelegate;

@interface SegmentViewController : UIViewController

@property (nonatomic, weak) id<SegmentViewControllerDelegate> delegate;
- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)vcs;

@property (assign, nonatomic) NSInteger defautIndex;//index of view controller showed when this vc show up

- (void)showChildViewAtInex:(NSInteger)index;
- (void)reomveAllChildViewControllers;

@end

@protocol SegmentViewControllerDelegate <NSObject>

@optional
- (void)SegmentViewController:(SegmentViewController *)segmentViewController didSelectItemAtIndex:(NSInteger)index;

@end
