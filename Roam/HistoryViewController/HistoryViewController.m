//
//  HIstoryViewController.m
//  Roam
//
//  Created by 黄文鸿 on 2017/3/23.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "HistoryViewController.h"
#import "Model+CoreDataModel.h"
#import "CoreDataHelper.h"
#import "BookmarkCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HistoryViewController ()

@property (nonatomic, strong) NSMutableArray<WebViewInfo *> *historyArray;

@end

@implementation HistoryViewController

static NSString *const reuseID = @"HistoryCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[BookmarkCell class] forCellReuseIdentifier:reuseID];
    [self updateHistoryArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.historyArray != nil && self.historyArray.count > 0) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.historyArray) {
        return self.historyArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BookmarkCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    WebViewInfo *info = self.historyArray[indexPath.row];
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:info.imageUrlString] placeholderImage:[UIImage imageNamed:@"defaultIcon"]];
    cell.titleLabel.text = info.title;
    cell.urlLabel.text = info.urlString;
    
    return cell;
}

#pragma mark - <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.currentWebView) {
        NSURL *url = [NSURL URLWithString:self.historyArray[indexPath.row].urlString];
        [self.currentWebView loadRequest:[NSURLRequest requestWithURL:url]];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 104.0;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        WebViewInfo *info = self.historyArray[indexPath.row];
        [self.historyArray removeObjectAtIndex:indexPath.row];
        [[CoreDataHelper shareInstance].context deleteObject:info];
        [tableView endUpdates];
    }];
    
    return @[deleteAction];
}

#pragma mark -  Public methods 

- (void)clearAllHistories {
    if(self.historyArray == nil || self.historyArray.count < 1) {
        return;
    }
    [self.tableView beginUpdates];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    for(WebViewInfo *info in self.historyArray) {
        [[CoreDataHelper shareInstance].context deleteObject:info];
    }
    [self.historyArray removeAllObjects];
    [self.tableView endUpdates];
}

#pragma mark - Private metods 
- (void)updateHistoryArray {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isHistory == YES"];
    NSSortDescriptor *sort  = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSFetchRequest *fetchRequest = [WebViewInfo fetchRequest];
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = @[sort];
    NSError *error  = nil;
    NSArray *arr = [[CoreDataHelper shareInstance].context executeFetchRequest:fetchRequest error:&error];
    if(error) {
        NSLog(@"%s Fail to execute fetch request : %@", object_getClassName([self class]), error);
    }
    
    self.historyArray = [NSMutableArray arrayWithArray:arr];
}

@end
