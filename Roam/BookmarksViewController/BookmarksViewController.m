//
//  BookmarksViewController.m
//  Roam
//
//  Created by 黄文鸿 on 2017/3/21.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "BookmarksViewController.h"
#import "BookmarkCell.h"
#import "Model+CoreDataModel.h"
#import "CoreDataHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface BookmarksViewController ()

@property (nonatomic, strong) NSMutableArray<WebViewInfo *> *favoriteArray;

@end

@implementation BookmarksViewController

static NSString *const reuseID = @"Bookmarkcell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[BookmarkCell class] forCellReuseIdentifier:reuseID];
    [self updateFavoriteArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.favoriteArray) {
        return self.favoriteArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BookmarkCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    WebViewInfo *info = self.favoriteArray[indexPath.row];
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
        NSURL *url = [NSURL URLWithString:self.favoriteArray[indexPath.row].urlString];
        [self.currentWebView loadRequest:[NSURLRequest requestWithURL:url]];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}
- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
       
        [tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        WebViewInfo *info = [self.favoriteArray objectAtIndex:indexPath.row];
        [self.favoriteArray removeObject:info];
        [[CoreDataHelper shareInstance].context deleteObject:info];
        
        [tableView endUpdates];
        
    }];
    
    return @[deleteAction];
}

#pragma mark - private methods
- (void)updateFavoriteArray {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSPredicate *prediate = [NSPredicate predicateWithFormat:@"isHistory == NO"];
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [WebViewInfo fetchRequest];
    fetchRequest.sortDescriptors = @[sort];
    fetchRequest.predicate = prediate;
    NSArray *arr= [[CoreDataHelper shareInstance].context executeFetchRequest:fetchRequest error:&error];
    self.favoriteArray = [NSMutableArray arrayWithArray:arr];
    if(error) {
        NSLog(@"Fetch request of entity named \"WebViewInfo\" : %@", error);
    }
}

@end
