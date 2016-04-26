//
//  QQProfileMagicView.m
//  QQUserProfile
//
//  Created by hejiangshan on 16/4/21.
//  Copyright © 2016年 飞兽科技. All rights reserved.
//

#import "QQProfileMagicView.h"
#import "IndividualLabelMenu.h"
#import "QQHeaderView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

static const CGFloat kRadius = 140;
static const CGFloat kAngleOffset = M_PI_4;
static const CGFloat kDuration = 0.6;
static const CGFloat damping = 0.3;

@interface QQProfileMagicView ()<UICollisionBehaviorDelegate>



@property(nonatomic,assign)NSInteger count;
@property(nonatomic,strong)NSArray *contents;
@property(nonatomic,strong)NSMutableArray *menuItems;
@property(nonatomic,strong)NSMutableArray *snaps;
@property(nonatomic,strong)NSMutableArray *positions;

@property(nonatomic,strong)UIDynamicAnimator *animator;
@property(nonatomic,strong)UICollisionBehavior *collision;
@property(nonatomic,strong)UIDynamicItemBehavior *itemBehavior;

@property(nonatomic,strong)IndividualLabelMenu *currentDraggingMenu;
@property(nonatomic,strong)QQHeaderView *qqHeaderView;

@property(nonatomic,assign)BOOL expanded;

@end

@implementation QQProfileMagicView

- (instancetype)initWithContents:(NSArray *)contents
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contents = contents;
        self.count = contents.count;
    }
    return self;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self configSubViews];
}

- (void)configSubViews
{
    self.snaps = [NSMutableArray arrayWithCapacity:self.count];
    self.menuItems = [NSMutableArray arrayWithCapacity:self.count];
    self.positions = [NSMutableArray arrayWithCapacity:self.count];
    __weak QQProfileMagicView *magicView = self;
    for (int i = 0; i < self.count; i++) {
        NSString *content = self.contents[i];
        IndividualLabelMenu *individualMenu = [[IndividualLabelMenu alloc] initWithContent:content];
        individualMenu.panBlock = ^(UIPanGestureRecognizer *panGesture,IndividualLabelMenu *menu) {
            if (!magicView.expanded) {
                return;
            }
            magicView.currentDraggingMenu = menu;
            if (panGesture.state == UIGestureRecognizerStateBegan) {
                [magicView.animator removeBehavior:magicView.itemBehavior];
                [magicView.animator removeBehavior:magicView.collision];
                [magicView removeAllSnaps];
                [magicView.qqHeaderView startScan];
            } else if (panGesture.state == UIGestureRecognizerStateChanged) {
                CGPoint center = [panGesture locationInView:magicView];
                menu.center = center;
            } else if (panGesture.state == UIGestureRecognizerStateEnded) {
                [magicView.animator addBehavior:magicView.collision];
                [self.qqHeaderView endScan];
                NSInteger index = [magicView.menuItems indexOfObject:menu];
                if (index != NSNotFound) {
                    [magicView snapToPostionsWithIndex:index];
                }
            }
        };
        individualMenu.tapBlock = ^(UITapGestureRecognizer *tapGesture,IndividualLabelMenu *menu) {
            [magicView.animator removeBehavior:magicView.collision];
            [magicView.animator removeBehavior:magicView.itemBehavior];
            [magicView removeAllSnaps];
            if (magicView.expanded) {
                [magicView foldMenu];
            } else {
                [magicView expandedMenu];
            }
        };
        individualMenu.center = self.center;
        NSValue *pointValue = [NSValue valueWithCGPoint:[self centerForQQMagicViewAtIndex:i]];
        [self.positions addObject:pointValue];
        [self addSubview:individualMenu];
        [self.menuItems addObject:individualMenu];
        individualMenu.layer.transform = CATransform3DScale(individualMenu.layer.transform, 0.01, 0.01, 0.01);
    }
    
    self.qqHeaderView = [[QQHeaderView alloc] initWithCenter:self.center];
    self.qqHeaderView.backgroundColor = [UIColor clearColor];
    self.qqHeaderView.headerClickedBlock = ^(QQHeaderView *headerView) {
        [magicView.animator removeBehavior:magicView.collision];
        [magicView.animator removeBehavior:magicView.itemBehavior];
        [magicView removeAllSnaps];
        if (magicView.expanded) {
            [magicView foldMenu];
        } else {
            [magicView expandedMenu];
        }
    };
    [self addSubview:self.qqHeaderView];
    
    [self sendSubviewToBack:self.qqHeaderView];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    
    self.collision = [[UICollisionBehavior alloc] initWithItems:self.menuItems];
    self.collision.translatesReferenceBoundsIntoBoundary = true;
    self.collision.collisionDelegate = self;
    
    for (int i = 0; i < self.count; i++) {
        IndividualLabelMenu *menu = [self.menuItems objectAtIndex:i];
        UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:menu snapToPoint:self.center];
        snap.damping = damping;
        [self.snaps addObject:snap];
    }
    
    self.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:self.menuItems];
    self.itemBehavior.allowsRotation = NO;
    self.itemBehavior.elasticity = 1.2;
    self.itemBehavior.density = 0.5;
    self.itemBehavior.angularResistance = 5;
    self.itemBehavior.resistance = 10;
    self.itemBehavior.elasticity = 0.8;
    self.itemBehavior.friction = 0.5;
}

- (CGPoint)centerForQQMagicViewAtIndex:(int)index
{
    CGFloat startAngle = M_PI + (M_PI - kAngleOffset) + index * kAngleOffset;
    CGPoint startCenter = self.center;
    CGFloat x = startCenter.x + cos(startAngle)*kRadius;
    CGFloat y = startCenter.y + sin(startAngle)*kRadius;
    return CGPointMake(x, y);
}

- (void)expandedMenu
{
    [self.qqHeaderView appearLayer:YES];
    for (int i = 0; i < self.count; i++) {
        [self arcExpandedMenuToIndex:i];
    }
    self.expanded = YES;
}

- (void)foldMenu
{
    [self.qqHeaderView appearLayer:NO];
    for (int i = 0; i < self.count; i++) {
        [self arcFoldedMenuToIndex:i];
    }
    self.expanded = false;
}

- (void)snapToPostionsWithIndex:(NSUInteger)index
{
    id positionValue = self.positions[index];
    CGPoint position = [positionValue CGPointValue];
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.menuItems[index] snapToPoint:position];
    snap.damping = damping;
    UISnapBehavior *snapToRemove = self.snaps[index];
    self.snaps[index] = snap;
    [self.animator removeBehavior:snapToRemove];
    [self.animator addBehavior:snap];
}

- (void)arcExpandedMenuToIndex:(int)index
{
    IndividualLabelMenu *menu = self.menuItems[index];
    
    CGPoint startCenter = self.center;
    CGPoint controlCenter = [self controlCenterAtIndex:index];
    CGPoint targetCenter = [(NSValue *)[self.positions objectAtIndex:index] CGPointValue];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:startCenter];
    [bezierPath addQuadCurveToPoint:targetCenter controlPoint:controlCenter];

    [menu.layer addAnimation:[self pathForAnimation:@"expandAni" widthPath:bezierPath] forKey:nil];
}

- (void)arcFoldedMenuToIndex:(int)index
{
    IndividualLabelMenu *menu = self.menuItems[index];
    
    CGPoint controlCenter = [self controlCenterAtIndex:index];
    CGPoint targetCenter = [(NSValue *)[self.positions objectAtIndex:index] CGPointValue];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:targetCenter];
    [bezierPath addQuadCurveToPoint:self.center controlPoint:controlCenter];
    
    [menu.layer addAnimation:[self pathForAnimation:@"foldAni" widthPath:bezierPath] forKey:nil];
}

- (CGPoint)controlCenterAtIndex:(int)index
{
    CGFloat targetAngle = M_PI + (M_PI - kAngleOffset) + index * kAngleOffset;
    CGFloat controlAngle = targetAngle - M_PI/3;
    CGPoint startCenter = self.center;
    CGFloat controlCenterX = startCenter.x + cos(controlAngle)*kRadius/2;
    CGFloat controlCenterY = startCenter.y + sin(controlAngle)*kRadius/2;
    CGPoint controlCenter = CGPointMake(controlCenterX, controlCenterY);
    return controlCenter;
}

- (CAAnimationGroup *)pathForAnimation:(NSString *)valueString widthPath:(UIBezierPath *)bezierPath {
    CGFloat fromScale = self.expanded ? 1 : 0.01;
    CGFloat toScale = self.expanded ? 0.01 : 1;
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.path = bezierPath.CGPath;
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @(fromScale);
    scaleAnimation.toValue = @(toScale);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[positionAnimation,scaleAnimation];
    group.delegate = self;
    [group setValue:valueString forKey:@"expand"];
    group.duration = kDuration;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.autoreverses = NO;
    
    return group;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        NSString *expand = [anim valueForKey:@"expand"];
        if ([expand isEqualToString:@"expandAni"]) {
            for (int i = 0; i < self.count; i++) {
                CGPoint targetCenter = [(NSValue *)[self.positions objectAtIndex:i] CGPointValue];
                IndividualLabelMenu *menu = self.menuItems[i];
                menu.center = targetCenter;
                menu.layer.transform = CATransform3DIdentity;
                [menu.layer removeAllAnimations];
            }
        } else if ([expand isEqualToString:@"foldAni"]) {
            for (int i = 0; i < self.count; i++) {
                IndividualLabelMenu *menu = self.menuItems[i];
                menu.center = self.center;
                menu.layer.transform = CATransform3DScale(menu.layer.transform, 0.01, 0.01, 0.01);
                [menu.layer removeAllAnimations];
            }
        }
    }
    
}

#pragma mark UICollisionBehavior delegate
- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id <UIDynamicItem>)item1 withItem:(id <UIDynamicItem>)item2
{
    [self.animator addBehavior:self.itemBehavior];
    
    /*
    if (item1 != self.currentDraggingMenu) {
        NSUInteger index = (int)[self.menuItems indexOfObject:item1];
        if (index != NSNotFound) {
            [self snapToPostionsWithIndex:index];
        }
    }
    
    if (item2 != self.currentDraggingMenu) {
        NSUInteger index = (int)[self.menuItems indexOfObject:item2];
        if (index != NSNotFound) {
            [self snapToPostionsWithIndex:index];
        }
    }
     */
    for (int i = 0; i < self.count; i++) {
        [self snapToPostionsWithIndex:i];
    }
}

- (void)removeAllSnaps
{
    for (int i = 0; i < self.count; i++) {
        UISnapBehavior *snap = [self.snaps objectAtIndex:i];
        [self.animator removeBehavior:snap];
    }
}

@end
