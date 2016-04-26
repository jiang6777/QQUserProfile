//
//  IndividualLabelMenu.h
//  QQUserProfile
//
//  Created by hejiangshan on 16/4/21.
//  Copyright © 2016年 飞兽科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndividualLabelMenu : UIView

@property(nonatomic,copy)void(^panBlock)(UIPanGestureRecognizer *panGesture,IndividualLabelMenu *indiMenu);

@property(nonatomic,copy)void(^tapBlock)(UITapGestureRecognizer *panGesture,IndividualLabelMenu *indiMenu);

- (instancetype)initWithContent:(NSString *)text;

@end
