//
//  QQHeaderView.m
//  QQUserProfile
//
//  Created by hejiangshan on 16/4/25.
//  Copyright © 2016年 飞兽科技. All rights reserved.
//
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#import "QQHeaderView.h"

static const CGFloat kRadoCount = 2;
static const CGFloat kAnimationDuration = 1;

@interface QQHeaderView ()

//@property(nonatomic,strong)CALayer *animationLayer;
@property(nonatomic,strong)UIImageView *qqHeaderImageView;
@property(nonatomic,strong)UIView *insideView;
@property(nonatomic,strong)UIView *outsideView;
@property(nonatomic,strong)NSMutableArray *sides;

@end

@implementation QQHeaderView

- (instancetype)initWithCenter:(CGPoint)center
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.sides = [NSMutableArray array];
        self.bounds = CGRectMake(0, 0, kScreenWidth/3, kScreenWidth/3);
        self.center = center;
    }
    return self;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self configView];
}

- (void)configView
{
    self.insideView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width-20, self.bounds.size.width-20)];
    self.insideView.backgroundColor = [UIColor clearColor];
    self.insideView.alpha = 0.0;
    self.insideView.layer.cornerRadius = (self.bounds.size.width-20)/2;
    self.insideView.layer.masksToBounds = true;
    self.insideView.layer.borderWidth = 20;
    self.insideView.layer.borderColor = [UIColor colorWithRed:193.0/255 green:186.0/255 blue:194.0/255 alpha:1].CGColor;
    [self addSubview:self.insideView];
    [self.sides addObject:self.insideView];
    
    self.outsideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width)];
    self.outsideView.backgroundColor = [UIColor clearColor];
    self.outsideView.alpha = 0.0;
    self.outsideView.layer.cornerRadius = self.bounds.size.width/2;
    self.outsideView.layer.masksToBounds = true;
    self.outsideView.layer.borderWidth = 20;
    self.outsideView.layer.borderColor = [UIColor colorWithRed:194.0/255 green:174.0/255 blue:172.0/255 alpha:1].CGColor;
    [self addSubview:self.outsideView];
    [self.sides addObject:self.outsideView];
    
    self.qqHeaderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1.jpg"]];
    self.qqHeaderImageView.frame = CGRectMake(20, 20, self.bounds.size.width-40, self.bounds.size.width-40);
    self.qqHeaderImageView.layer.cornerRadius = (self.bounds.size.width-40)/2;
    self.qqHeaderImageView.layer.masksToBounds = true;
    self.qqHeaderImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.qqHeaderImageView.layer.borderWidth = 1;
    [self addSubview:self.qqHeaderImageView];
    [self.qqHeaderImageView setUserInteractionEnabled:true];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.qqHeaderImageView addGestureRecognizer:tap];
}

- (void)tapAction:(UITapGestureRecognizer *)recognizer
{
    if (self.headerClickedBlock != nil) {
        self.headerClickedBlock(self);
    }
}

- (void)appearLayer:(BOOL)isAppear
{
    CGFloat alpha = isAppear?0.75:0;;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.insideView.alpha = alpha;
        self.outsideView.alpha = alpha;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)startScan
{
    for (int i = 0; i < self.sides.count; i++) {
        UIView *sideView = [self.sides objectAtIndex:i];
        CAMediaTimingFunction *defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        
        CAAnimationGroup *animationGroup = [[CAAnimationGroup  alloc] init];
        animationGroup.fillMode = kCAFillModeBackwards;
        animationGroup.beginTime = CACurrentMediaTime() + i * kAnimationDuration / kRadoCount;
        animationGroup.duration = kAnimationDuration;
        animationGroup.repeatCount = HUGE;
        animationGroup.timingFunction = defaultCurve;
        animationGroup.autoreverses = true;
        
//        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//        scaleAnimation.fromValue = @1.0;
//        scaleAnimation.toValue = @1.5;
        CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.values = @[@1.0,@(1.5 - 0.2),@1.0];
        
        CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.values = @[@0.75, @0.3, @0];
//        opacityAnimation.keyTimes = @[@0, @0.5, @1];
        
        animationGroup.animations = @[scaleAnimation, opacityAnimation];
        
        [sideView.layer addAnimation:animationGroup forKey:@"radar"];
    }
}

- (void)endScan
{
    for (int i = 0; i < self.sides.count; i++) {
        UIView *sideView = [self.sides objectAtIndex:i];
        [sideView.layer removeAllAnimations];
    }
}

- (void)drawRect:(CGRect)rect
{
    /*
    CALayer *animationLayer = [[CALayer alloc] init];
    for (int i = 0; i < kRadoCount; i++) {
        CALayer *pulsingLayer = [[CALayer alloc] init];
        pulsingLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        pulsingLayer.borderColor = [UIColor whiteColor].CGColor;
        pulsingLayer.borderWidth = 10;
        pulsingLayer.cornerRadius = rect.size.height /2;
        
        CAMediaTimingFunction *defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        
        CAAnimationGroup *animationGroup = [[CAAnimationGroup  alloc] init];
        animationGroup.fillMode = kCAFillModeBackwards;
        animationGroup.beginTime = CACurrentMediaTime() + i * kAnimationDuration / kRadoCount;
        animationGroup.duration = kAnimationDuration;
        animationGroup.repeatCount = INFINITY;
        animationGroup.timingFunction = defaultCurve;
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.autoreverses = YES;
        scaleAnimation.fromValue = @1.0;
        scaleAnimation.toValue = @1.2;
        
        CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.values = @[@1, @0.7, @0];
        opacityAnimation.keyTimes = @[@0, @0.5, @1];
        
        animationGroup.animations = @[scaleAnimation, opacityAnimation];
        
        [pulsingLayer addAnimation:animationGroup forKey:@"radar"];
        [animationLayer addSublayer:pulsingLayer];
    }
    _animationLayer = animationLayer;
    [self.layer addSublayer:_animationLayer];
     */
}



@end
