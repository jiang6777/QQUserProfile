//
//  QQHeaderView.h
//  QQUserProfile
//
//  Created by hejiangshan on 16/4/25.
//  Copyright © 2016年 飞兽科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QQHeaderView : UIView

- (instancetype)initWithCenter:(CGPoint)center;

- (void)startScan;

- (void)endScan;

- (void)appearLayer:(BOOL)isAppear;

@property(nonatomic,copy)void(^headerClickedBlock)(QQHeaderView *view);

@end
