//
//  IndividualLabelMenu.m
//  QQUserProfile
//
//  Created by hejiangshan on 16/4/21.
//  Copyright © 2016年 飞兽科技. All rights reserved.
//

#import "IndividualLabelMenu.h"

static const CGFloat kMAXSIZE = 80;
static const CGFloat kMINSIZE = 60;

@interface IndividualLabelMenu ()

@property(nonatomic,copy)NSString *showText;

@end


@implementation IndividualLabelMenu

- (instancetype)initWithContent:(NSString *)text
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        self.alpha = 0.75;
        CGRect rect = self.frame;
        float width = text.length > 3 ? kMAXSIZE : kMINSIZE;
        rect.size = CGSizeMake(width, width);
        self.frame = rect;
        self.showText = text;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startTap:)];
        [self addGestureRecognizer:tapGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self addGestureRecognizer:panGesture];
        
    }
    return self;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self configSelfAndSubViews];
}

- (void)configSelfAndSubViews
{
    self.layer.cornerRadius = self.bounds.size.width/2;
    self.layer.masksToBounds = true;
//    self.layer.borderWidth = 1;
//    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.shadowRadius = 5;
    self.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.layer.shadowOpacity = 0.75;
    self.layer.shadowOffset = CGSizeMake(3, 3);
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:self.bounds];
    bottomView.backgroundColor = [UIColor clearColor];
    [self addSubview:bottomView];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.frame.size.width - 20, self.frame.size.height - 10)];
    contentLabel.text = self.showText;
    contentLabel.textColor = [UIColor whiteColor];
    contentLabel.font = [UIFont systemFontOfSize:17];
    contentLabel.numberOfLines = 3;
    contentLabel.textAlignment = NSTextAlignmentCenter;
    [bottomView addSubview:contentLabel];
}

- (void)startTap:(UITapGestureRecognizer *)gesture
{
    if (self.tapBlock != nil) {
        self.tapBlock(gesture,self);
    }
}

- (void)panAction:(UIPanGestureRecognizer *)gesture
{
    if (self.panBlock != nil) {
        self.panBlock(gesture,self);
    }
}

@end
