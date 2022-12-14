#ifdef SHOULD_COMPILE_LOOKIN_SERVER 

//
//  LKS_PerspectiveLayer.m
//  LookinServer
//
//  Created by Li Kai on 2019/5/17.
//  https://lookin.work
//

#import "LKS_PerspectiveLayer.h"



#import "LKS_PerspectiveDataSource.h"
#import "LKS_PerspectiveItemLayer.h"
#import "LookinAppInfo.h"
#import "LookinHierarchyInfo.h"
#import "LookinServerDefines.h"

@interface LookinDisplayItem (LKS_PerspectiveLayer)

@property(nonatomic, weak) LKS_PerspectiveItemLayer *lks_itemLayer;

@end

@implementation LookinDisplayItem (LKS_PerspectiveLayer)

- (void)setLks_itemLayer:(LKS_PerspectiveItemLayer *)lks_itemLayer {
    [self lookin_bindObjectWeakly:lks_itemLayer forKey:@"lks_itemLayer"];
}

- (LKS_PerspectiveItemLayer *)lks_itemLayer {
    return [self lookin_getBindObjectForKey:@"lks_itemLayer"];
}

@end

@interface LKS_PerspectiveLayer ()

@property(nonatomic, strong) CALayer *rotateLayer;

@property(nonatomic, copy) NSArray<LKS_PerspectiveItemLayer *> *itemLayers;

@property(nonatomic, strong) LKS_PerspectiveDataSource *dataSource;

@property(nonatomic, strong) LKS_PerspectiveItemLayer *selectedLayer;

@end

@implementation LKS_PerspectiveLayer

- (instancetype)initWithDataSource:(LKS_PerspectiveDataSource *)dataSource {
    if (self = [self init]) {
        self.dataSource = dataSource;
        dataSource.perspectiveLayer = self;
        
//        [self lookin_removeImplicitAnimations];
        
        self.rotateLayer = [CALayer layer];
        [self addSublayer:self.rotateLayer];
        
        self.itemLayers = [NSArray array];
        
        [self _rebuildPreviewLayers];
    }
    return self;
}

- (void)layoutSublayers {
    [super layoutSublayers];
    LookinAppInfo *appInfo = self.dataSource.rawHierarchyInfo.appInfo;
    CGSize size = CGSizeMake(appInfo.screenWidth, appInfo.screenHeight);
    self.rotateLayer.bounds = CGRectMake(0, 0, size.width, size.height);
    self.rotateLayer.anchorPoint = CGPointMake(.5, .5);
    self.rotateLayer.position = CGPointMake(self.rotateLayer.superlayer.bounds.size.width / 2.0, self.rotateLayer.superlayer.bounds.size.height / 2.0);
}

- (void)setDimension:(LKS_PerspectiveDimension)dimension {
    _dimension = dimension;
    if (dimension == LKS_PerspectiveDimension2D) {
        self.rotateLayer.sublayerTransform = CATransform3DIdentity;
        [self.itemLayers enumerateObjectsUsingBlock:^(LKS_PerspectiveItemLayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
            layer.transform = CATransform3DIdentity;
        }];
        
    } else if (dimension == LKS_PerspectiveDimension3D) {
        CGFloat targetRotation = (self.rotation == 0 ? .6 : self.rotation);
        [self setRotation:targetRotation animated:YES completion:nil];
        [self _updateZIndex];
        
    } else {
        NSAssert(NO, @"");
    }
}

- (void)setRotation:(CGFloat)rotation {
    _rotation = rotation;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = - 1 / 3000.0;
    transform = CATransform3DRotate(transform, rotation, 0, 1, 0);
    self.rotateLayer.sublayerTransform = transform;
}

- (void)setRotation:(CGFloat)rotation animated:(BOOL)animated completion:(void (^)(void))completionBlock {
    [CATransaction begin];
    [CATransaction setCompletionBlock:completionBlock];
    [CATransaction setDisableActions:!animated];
    [self setRotation:rotation];
    [CATransaction commit];
}

- (void)_rebuildPreviewLayers {
    NSArray<LookinDisplayItem *> *validItems = [self.dataSource.flatItems lookin_filter:^BOOL(LookinDisplayItem *obj) {
        return !obj.inNoPreviewHierarchy;
    }];
    self.itemLayers = [self.itemLayers lookin_resizeWithCount:validItems.count add:^LKS_PerspectiveItemLayer *(NSUInteger idx) {
        LKS_PerspectiveItemLayer *layer = [LKS_PerspectiveItemLayer new];
        [self.rotateLayer addSublayer:layer];
        return layer;
        
    } remove:^(NSUInteger idx, LKS_PerspectiveItemLayer *layer) {
        [layer removeFromSuperlayer];
        
    } doNext:^(NSUInteger idx, LKS_PerspectiveItemLayer *layer) {
        LookinDisplayItem *item = validItems[idx];
        layer.displayItem = item;
        layer.frame = item.frameToRoot;
        item.lks_itemLayer = layer;
        
        if (item.isSelected) {
            self.selectedLayer = layer;
        }
    }];
    
    [self _updateZIndex];
}

/**
 ?????????????????? item ??? zIndex????????? zIndex ???????????????????????? z ????????? translation??????????????? fold ????????????????????????????????????
 */
- (void)_updateZIndex {
    [[self.dataSource.flatItems lookin_filter:^BOOL(LookinDisplayItem *obj) {
        return !obj.inNoPreviewHierarchy;
    }] enumerateObjectsUsingBlock:^(LookinDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _updateZIndexForItem:obj];
    }];
    
    [self _updateZTranslationByZIndex];
}

- (void)_updateZIndexForItem:(LookinDisplayItem *)item {
    item.previewZIndex = -1;
    if (item.displayingInHierarchy) {
        LookinDisplayItem *referenceItem = [self _maxZIndexForOverlappedItemUnderItem:item];
        if (referenceItem) {
            // ?????? item ???????????? itemA ??????????????? item.previewZIndex ????????? itemA.previewZIndex ?????????
            item.previewZIndex = referenceItem.previewZIndex + 1;
        } else {
            item.previewZIndex = 0;
        }
        
    } else {
        if (item.superItem) {
            item.previewZIndex = item.superItem.previewZIndex;
        } else {
            NSAssert(NO, @"");
        }
    }
    
    if (item.previewZIndex < 0) {
        NSAssert(NO, @"");
        item.previewZIndex = 0;
    }
}

- (void)_updateZTranslationByZIndex {
    CGFloat interspace = 20;
    
    // key ??? zIndex???value ?????? zIndex ???????????? item????????????????????????????????? offsetToAvoidOverlapBug
    NSMutableDictionary<NSNumber *, NSNumber *> *zIndexAndCountDict = [NSMutableDictionary dictionary];
    
    __block NSUInteger maxZIndex = 0;
    [self.itemLayers enumerateObjectsUsingBlock:^(LKS_PerspectiveItemLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        maxZIndex = MAX(maxZIndex, obj.displayItem.previewZIndex);
    }];
    [self.itemLayers enumerateObjectsUsingBlock:^(LKS_PerspectiveItemLayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
        LookinDisplayItem *item = layer.displayItem;
        // ??? "1, 2, 3, 4, 5 ..." ????????? zIndex ??????????????? ???-2???-1???0???1???2 ...????????????????????? Y ??????????????? zIndex ????????????????????? layer ?????????
        NSInteger adjustedZIndex = item.previewZIndex - round(maxZIndex / 2.0);
        
        NSUInteger countOfCurrentZIndex = [[zIndexAndCountDict objectForKey:@(adjustedZIndex)] unsignedIntegerValue];
        countOfCurrentZIndex++;
        [zIndexAndCountDict setObject:@(countOfCurrentZIndex) forKey:@(adjustedZIndex)];
        
        /// ?????????????????? layer ??? z ????????????????????? translate ??????????????????????????????????????? layer ???????????????????????????????????????????????????????????????????????????????????????????????????????????? bug?????????????????????????????????????????? layer ??? translate ?????????????????????????????? layer ?????????????????? translate ?????????????????? bug
        CGFloat offsetToAvoidOverlapBug = countOfCurrentZIndex * 0.01;
        
        layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, interspace * adjustedZIndex + offsetToAvoidOverlapBug);
    }];
}

/**
 ?????? itemA?????????????????? itemB???itemB ?????????????????????
 - itemB ??? preview ?????????
 - itemB ???????????? itemA ???????????? itemB ??? flatItems ?????? index ?????? itemA ??????
 - itemB ??? itemA ??? frameToRoot ????????????????????????????????????????????????
 - itemB ??????????????????????????????????????? items ?????? zIndex ????????????
 
 @note ??????????????????????????????????????? itemB???????????? nil
 */
- (LookinDisplayItem *)_maxZIndexForOverlappedItemUnderItem:(LookinDisplayItem *)item {
    NSArray<LookinDisplayItem *> *flatItems = [self.dataSource.flatItems lookin_filter:^BOOL(LookinDisplayItem *obj) {
        return !obj.inNoPreviewHierarchy;
    }];
    NSUInteger itemIndex = [flatItems indexOfObject:item];
    if (itemIndex == 0) {
        return nil;
    }
    if (itemIndex == NSNotFound) {
        NSAssert(NO, @"");
        return nil;
    }
    NSIndexSet *indexesBelow = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, itemIndex)];
    __block LookinDisplayItem *targetItem = nil;
    [flatItems enumerateObjectsAtIndexes:indexesBelow options:NSEnumerationReverse usingBlock:^(LookinDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.inHiddenHierarchy) {
            if (CGRectIntersectsRect(item.frameToRoot, obj.frameToRoot)) {
                if (!targetItem) {
                    targetItem = obj;
                } else {
                    if (obj.previewZIndex > targetItem.previewZIndex) {
                        targetItem = obj;
                    }
                }
            }
        }
    }];
    return targetItem;
}

#pragma mark - <LKS_PerspectiveDataSourceDelegate>

- (void)dataSourceDidChangeSelectedItem:(LKS_PerspectiveDataSource *)dataSource {
    [self.selectedLayer reRender];
    
    LookinDisplayItem *item = dataSource.selectedItem;
    [item.lks_itemLayer reRender];
    self.selectedLayer = item.lks_itemLayer;
}

- (void)dataSourceDidChangeDisplayItems:(LKS_PerspectiveDataSource *)dataSource {
    [self _updateZIndex];
    [self.itemLayers enumerateObjectsUsingBlock:^(LKS_PerspectiveItemLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj reRender];
    }];
}

- (void)dataSourceDidChangeNoPreview:(LKS_PerspectiveDataSource *)dataSource {
    [self _rebuildPreviewLayers];
}

@end

#endif /* SHOULD_COMPILE_LOOKIN_SERVER */
