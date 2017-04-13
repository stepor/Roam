//
//  SettingsViewController.m
//  Roam
//
//  Created by 黄文鸿 on 2017/4/12.
//  Copyright © 2017年 黄文鸿. All rights reserved.
//

#import "SettingsViewController.h"
#import "NightModeView.h"
#import <SDWebImage/SDImageCache.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (weak, nonatomic) IBOutlet UILabel *cacheLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //title
    self.title = @"设置";
    
    //dismiss
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //brightness slider
    self.brightnessSlider.minimumValue = [NightModeView minAlpha];
    self.brightnessSlider.maximumValue = [NightModeView maxAlpha];
    self.brightnessSlider.continuous = YES;
    self.brightnessSlider.value = [NightModeView currentGrayLevel];
    [self.brightnessSlider addTarget:self action:@selector(brightnessSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    
    //cache label
    self.cacheLabel.text = [NSString stringWithFormat:@"%.2fM",[[SDImageCache sharedImageCache] getSize] / 1024.0];
}

- (void)dismiss {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)brightnessSliderValueChange:(UISlider *)slider {
    [NightModeView setGrayLevel:slider.value];
}


#pragma mark - <UITableViewDelegate>
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(indexPath.section == 1 && indexPath.row == 0) {
        return indexPath;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1 && indexPath.row == 0) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.removeFromSuperViewOnHide = YES;
        [hud showAnimated:YES];
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
            [hud hideAnimated:YES];
            self.cacheLabel.text = [NSString stringWithFormat:@"%.2fM",[[SDImageCache sharedImageCache] getSize] / 1024.0];
        }];
    }
}



@end
