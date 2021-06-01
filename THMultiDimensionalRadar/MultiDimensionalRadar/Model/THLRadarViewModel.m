//
//  THLRadarViewModel.m
//  THMultiDimensionalRadar
//
//  Created by Terence Yang on 2021/6/1.
//

#import "THLRadarViewModel.h"

@implementation THLRadarDimensionModel

- (UIFont *)dimensionFont {
    if (!_dimensionFont) {
        _dimensionFont = [UIFont systemFontOfSize:13];
    }
    return _dimensionFont;
}

- (UIColor *)dimensionColor {
    if (!_dimensionColor) {
        _dimensionColor = [UIColor grayColor];
    }
    return _dimensionColor;
}


@end



/// Data of each layer
@interface THLRadarCategoryModel ()

@property(nonatomic, strong, readwrite) NSArray <THLRadarDimensionModel *> *dimensionsArr;

@end

@implementation THLRadarCategoryModel

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

- (NSArray<UIColor *> *)coverageFillColorArr {
    if (!_coverageFillColorArr) {
        _coverageFillColorArr = @[[[UIColor grayColor] colorWithAlphaComponent:0.5]];
    }
    return _coverageFillColorArr;
}

@end





@implementation THLRadarViewModel

@synthesize categoryArr = _categoryArr;

- (instancetype)init {
    if (self = [super init]) {
        self.borderLineStyle = RadarBorderLineStyleLoop;
        self.num = 2;
        self.margin = 4;
        self.netLineWidth = 1.f;
        self.isNeedShowValue = NO;
        self.isNeedSkeletonLine = YES;
        self.netMapBgColor = [UIColor clearColor];
        self.dimensionColor = [UIColor blackColor];
        self.netColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.dimensionFont = [UIFont systemFontOfSize:15];
        self.coverageBorderLineW = 1.f;
    }
    return self;
}

- (CGFloat)dimensionMaxWidth {
    if (_dimensionMaxWidth < 0.000001) {
        _dimensionMaxWidth = 40;
    }
    return _dimensionMaxWidth;
}

- (NSArray <THLRadarCategoryModel *> *)categoryArr {
    NSInteger count = _categoryArr.count;
    
    if (count > 0) {
        NSArray *dSizeArr = [NSArray new];
        
        BOOL isNeedCustomDimensionSize = YES;
        
        if (CGSizeEqualToSize(self.dimensionSize, CGSizeZero)) {
            isNeedCustomDimensionSize = NO;
            dSizeArr = [self calDimensionSizeWithMaxWidth:self.dimensionMaxWidth];
        }
        
        NSInteger dValueCount = 0;
        
        CGFloat percent = 0;
        
        NSNumber *value = 0;
        
        NSString *str = @"";
        
        NSMutableArray *dimensionsArrM = [NSMutableArray array];
        
        for (NSInteger i = 0; i < count; i++) {
            THLRadarCategoryModel *categoryModel = _categoryArr[i];
            
            dValueCount = categoryModel.valueArr.count;

            if (!isNeedCustomDimensionSize) {
                NSAssert(dSizeArr.count == dValueCount, @"radar dimension text count and radar dimension values count is different !");
            }
            
            [dimensionsArrM removeAllObjects];
            for (NSInteger j = 0; j < dValueCount; j++) {
                THLRadarDimensionModel *dModel = [THLRadarDimensionModel new];
                
                value = categoryModel.valueArr[j];
                calculateItemPercent(self.highestScore, [value doubleValue], &percent);
                dModel.itemPercent = percent;
                dModel.dimensionColor = self.dimensionColor;
                dModel.dimensionFont = self.dimensionFont;
                
                if (!isNeedCustomDimensionSize) {
                    NSValue *value = dSizeArr[j];
                    
                    dModel.size = [value CGSizeValue];
                }else {
                    dModel.size = self.dimensionSize;
                }
                
                str = j < self.dimensionStrArr.count ? self.dimensionStrArr[j] : @"";
                if (self.isNeedShowValue && count == 1) {
                    dModel.itemName = [NSString stringWithFormat:@"%@ %ld", str, [value integerValue]];
                }else {
                    dModel.itemName = str;
                }
                [dimensionsArrM addObject:dModel];
            }
            categoryModel.dimensionsArr = [dimensionsArrM copy];
        }
    }

    return _categoryArr;
}

- (NSArray *)calDimensionSizeWithMaxWidth:(CGFloat)maxW {
    NSMutableArray *arrM = [NSMutableArray array];
    
    for (NSInteger i = 0; i < self.dimensionStrArr.count; i++) {
        NSString *str = self.dimensionStrArr[i];
        
        NSDictionary *attributes = @{NSFontAttributeName:self.dimensionFont,
                                     NSForegroundColorAttributeName:self.dimensionColor};
        
        CGSize itemSize = [str boundingRectWithSize:CGSizeMake(maxW, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:attributes
                                            context:nil].size;
        NSValue *value = [NSValue valueWithCGSize:itemSize];
        
        [arrM addObject:value];
    }
    
    return [arrM copy];
}

static inline void calculateItemPercent(CGFloat highestscore, CGFloat orginValue, CGFloat *result) {
    CGFloat r = highestscore > 0 ? (orginValue / highestscore) : 0;
    
    *result = r > 1 ? 1 : r;
}

@end


