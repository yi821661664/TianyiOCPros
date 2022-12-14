#ifdef SHOULD_COMPILE_LOOKIN_SERVER 

//
//  UIView+LookinServer.m
//  LookinServer
//
//  Created by Li Kai on 2019/3/19.
//  https://lookin.work
//

#import "UIView+LookinServer.h"
#import <objc/runtime.h>
#import "LookinObject.h"
#import "LookinAutoLayoutConstraint.h"
#import "LookinServerDefines.h"

@implementation UIView (LookinServer)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method oriMethod = class_getInstanceMethod([UIView class], @selector(initWithFrame:));
        Method newMethod = class_getInstanceMethod([UIView class], @selector(initWithFrame_lks:));
        method_exchangeImplementations(oriMethod, newMethod);
        
        oriMethod = class_getInstanceMethod([UIView class], @selector(initWithCoder:));
        newMethod = class_getInstanceMethod([UIView class], @selector(initWithCoder_lks:));
        method_exchangeImplementations(oriMethod, newMethod);
    });
}

- (instancetype)initWithFrame_lks:(CGRect)frame {
    UIView *view = [self initWithFrame_lks:frame];
    view.layer.lks_hostView = view;
    return view;
}

- (instancetype)initWithCoder_lks:(NSCoder *)coder {
    UIView *view = [self initWithCoder_lks:coder];
    view.layer.lks_hostView = view;
    return view;
}

- (void)setLks_hostViewController:(UIViewController *)lks_hostViewController {
    [self lookin_bindObjectWeakly:lks_hostViewController forKey:@"lks_hostViewController"];
}

- (UIViewController *)lks_hostViewController {
    return [self lookin_getBindObjectForKey:@"lks_hostViewController"];
}

- (UIView *)lks_subviewAtPoint:(CGPoint)point preferredClasses:(NSArray<Class> *)preferredClasses {
    BOOL isPreferredClassForSelf = [preferredClasses lookin_any:^BOOL(Class obj) {
        return [self isKindOfClass:obj];
    }];
    if (isPreferredClassForSelf) {
        return self;
    }
    
    UIView *targetView = [self.subviews lookin_lastFiltered:^BOOL(__kindof UIView *obj) {
        if (obj.layer.lks_isLookinPrivateLayer) {
            return NO;
        }
        if (obj.hidden || obj.alpha <= 0.01) {
            return NO;
        }
        BOOL contains = CGRectContainsPoint(obj.frame, point);
        return contains;
    }];
    
    if (!targetView) {
        return self;
    }
    
    CGPoint newPoint = [targetView convertPoint:point fromView:self];
    targetView = [targetView lks_subviewAtPoint:newPoint preferredClasses:preferredClasses];
    return targetView;
}

- (CGSize)lks_bestSize {
    return [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}

- (CGFloat)lks_bestWidth {
    return self.lks_bestSize.width;
}

- (CGFloat)lks_bestHeight {
    return self.lks_bestSize.height;
}

- (void)setLks_isChildrenViewOfTabBar:(BOOL)lks_isChildrenViewOfTabBar {
    [self lookin_bindBOOL:lks_isChildrenViewOfTabBar forKey:@"lks_isChildrenViewOfTabBar"];
}
- (BOOL)lks_isChildrenViewOfTabBar {
    return [self lookin_getBindBOOLForKey:@"lks_isChildrenViewOfTabBar"];
}

- (void)setLks_verticalContentHuggingPriority:(float)lks_verticalContentHuggingPriority {
    [self setContentHuggingPriority:lks_verticalContentHuggingPriority forAxis:UILayoutConstraintAxisVertical];
}
- (float)lks_verticalContentHuggingPriority {
    return [self contentHuggingPriorityForAxis:UILayoutConstraintAxisVertical];
}

- (void)setLks_horizontalContentHuggingPriority:(float)lks_horizontalContentHuggingPriority {
    [self setContentHuggingPriority:lks_horizontalContentHuggingPriority forAxis:UILayoutConstraintAxisHorizontal];
}
- (float)lks_horizontalContentHuggingPriority {
    return [self contentHuggingPriorityForAxis:UILayoutConstraintAxisHorizontal];
}

- (void)setLks_verticalContentCompressionResistancePriority:(float)lks_verticalContentCompressionResistancePriority {
    [self setContentCompressionResistancePriority:lks_verticalContentCompressionResistancePriority forAxis:UILayoutConstraintAxisVertical];
}
- (float)lks_verticalContentCompressionResistancePriority {
    return [self contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisVertical];
}

- (void)setLks_horizontalContentCompressionResistancePriority:(float)lks_horizontalContentCompressionResistancePriority {
    [self setContentCompressionResistancePriority:lks_horizontalContentCompressionResistancePriority forAxis:UILayoutConstraintAxisHorizontal];
}
- (float)lks_horizontalContentCompressionResistancePriority {
    return [self contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisHorizontal];
}

+ (void)lks_rebuildGlobalInvolvedRawConstraints {
    [[[UIApplication sharedApplication].windows copy] enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
        [self lks_removeInvolvedRawConstraintsForViewsRootedByView:window];
    }];
    [[[UIApplication sharedApplication].windows copy] enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
        [self lks_addInvolvedRawConstraintsForViewsRootedByView:window];
    }];
}

+ (void)lks_addInvolvedRawConstraintsForViewsRootedByView:(UIView *)rootView {
    [rootView.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull constraint, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *firstView = constraint.firstItem;
        if ([firstView isKindOfClass:[UIView class]] && ![firstView.lks_involvedRawConstraints containsObject:constraint]) {
            if (!firstView.lks_involvedRawConstraints) {
                firstView.lks_involvedRawConstraints = [NSMutableArray array];
            }
            [firstView.lks_involvedRawConstraints addObject:constraint];
        }
        
        UIView *secondView = constraint.secondItem;
        if ([secondView isKindOfClass:[UIView class]] && ![secondView.lks_involvedRawConstraints containsObject:constraint]) {
            if (!secondView.lks_involvedRawConstraints) {
                secondView.lks_involvedRawConstraints = [NSMutableArray array];
            }
            [secondView.lks_involvedRawConstraints addObject:constraint];
        }
    }];
    
    [rootView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
        [self lks_addInvolvedRawConstraintsForViewsRootedByView:subview];
    }];
}

+ (void)lks_removeInvolvedRawConstraintsForViewsRootedByView:(UIView *)rootView {
    [rootView.lks_involvedRawConstraints removeAllObjects];
    [rootView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
        [self lks_removeInvolvedRawConstraintsForViewsRootedByView:subview];
    }];
}

- (void)setLks_involvedRawConstraints:(NSMutableArray<NSLayoutConstraint *> *)lks_involvedRawConstraints {
    [self lookin_bindObject:lks_involvedRawConstraints forKey:@"lks_involvedRawConstraints"];
}

- (NSMutableArray<NSLayoutConstraint *> *)lks_involvedRawConstraints {
    return [self lookin_getBindObjectForKey:@"lks_involvedRawConstraints"];
}

- (NSArray<LookinAutoLayoutConstraint *> *)lks_constraints {
    /**
     - lks_involvedRawConstraints ????????????????????? self ???????????? constraints???????????????????????????????????? inactive ?????????????????????????????????????????? inactive ??? constraints???
     - ?????? constraintsAffectingLayoutForAxis ????????????????????? self ??????????????????????????? constraints?????????????????? effectiveConstraints???
     - ???????????????????????? constraint ???????????? effectiveConstraints ????????????????????? lks_involvedRawConstraints ???????????????
        ?? UIWindow ?????? minX, minY, width, height ?????? effectiveConstraints?????? lks_involvedRawConstraints ????????????????????? constraints ????????????????????????????????????????????? Xcode Inspector ??? Reveal ?????????????????????????????? constraints???
        ?? ??????????????? View1 ??? center ??? superview ??? center ?????????????????? superview ??? width ??? height ??????????????? effectiveConstraints ???????????????????????? lks_involvedRawConstraints ???????????????????????????????????????????????? superview ??? width ??? height ?????????????????? View1???
     */
    NSMutableArray<NSLayoutConstraint *> *effectiveConstraints = [NSMutableArray array];
    [effectiveConstraints addObjectsFromArray:[self constraintsAffectingLayoutForAxis:UILayoutConstraintAxisHorizontal]];
    [effectiveConstraints addObjectsFromArray:[self constraintsAffectingLayoutForAxis:UILayoutConstraintAxisVertical]];
    
    NSArray<LookinAutoLayoutConstraint *> *lookinConstraints = [self.lks_involvedRawConstraints lookin_map:^id(NSUInteger idx, __kindof NSLayoutConstraint *constraint) {
        BOOL isEffective = [effectiveConstraints containsObject:constraint];
        if ([constraint isActive]) {
            // trying to get firstItem or secondItem of an inactive constraint may cause dangling-pointer crash
            // https://github.com/QMUI/LookinServer/issues/86
            LookinConstraintItemType firstItemType = [self _lks_constraintItemTypeForItem:constraint.firstItem];
            LookinConstraintItemType secondItemType = [self _lks_constraintItemTypeForItem:constraint.secondItem];
            LookinAutoLayoutConstraint *lookinConstraint = [LookinAutoLayoutConstraint instanceFromNSConstraint:constraint isEffective:isEffective firstItemType:firstItemType secondItemType:secondItemType];
            return lookinConstraint;
        }
        return nil;
    }];
    return lookinConstraints.count ? lookinConstraints : nil;
}

- (LookinConstraintItemType)_lks_constraintItemTypeForItem:(id)item {
    if (!item) {
        return LookinConstraintItemTypeNil;
    }
    if (item == self) {
        return LookinConstraintItemTypeSelf;
    }
    if (item == self.superview) {
        return LookinConstraintItemTypeSuper;
    }
    
    // ??? runtime ???????????????????????? UILayoutGuide ??? _UILayoutGuide ????????? UIView ????????????????????????????????????????????????????????????????????????????????? UIView ????????????????????????
    if (@available(iOS 9.0, *)) {
        if ([item isKindOfClass:[UILayoutGuide class]]) {
            return LookinConstraintItemTypeLayoutGuide;
        }
    }
    
    if ([[item lks_shortClassName] isEqualToString:@"_UILayoutGuide"]) {
        return LookinConstraintItemTypeLayoutGuide;
    }
    
    if ([item isKindOfClass:[UIView class]]) {
        return LookinConstraintItemTypeView;
    }
    
    NSAssert(NO, @"");
    return LookinConstraintItemTypeUnknown;
}

@end

#endif /* SHOULD_COMPILE_LOOKIN_SERVER */
