//
//  MasterViewController.m
//  QQUserProfile
//
//  Created by hejiangshan on 16/4/21.
//  Copyright © 2016年 飞兽科技. All rights reserved.
//

#import "MasterViewController.h"
#import "QQProfileMagicView.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBlurEffect];
    
    QQProfileMagicView *magicView = [[QQProfileMagicView alloc] initWithContents:@[@"技术宅",@"成熟",@"IT民工",@"电视剧",@"读书",@"有为青年",@"直率",@"吐槽"]];
    [self.view addSubview:magicView];
    
}

// 定义毛玻璃效果
- (void)setupBlurEffect
{
    // 定义毛玻璃效果
    UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView * effe = [[UIVisualEffectView alloc]initWithEffect:blur];
    effe.frame = self.view.bounds;
    // 添加毛玻璃
    [self.blurEffectImageView addSubview:effe];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
