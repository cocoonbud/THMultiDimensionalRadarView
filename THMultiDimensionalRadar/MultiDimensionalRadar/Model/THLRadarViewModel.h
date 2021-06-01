//
//  THLRadarViewModel.h
//  THMultiDimensionalRadar
//
//  Created by Terence Yang on 2021/6/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RadarBorderLineStyle) {
    RadarBorderLineStyleMesh        = 0,
    RadarBorderLineStyleLoop        = 1,
};



@interface THLRadarDimensionModel : NSObject

@property(nonatomic, copy) NSString *itemName;

@property(nonatomic, assign) double itemPercent;

@property(nonatomic, assign) CGSize size;

@property(nonatomic, strong) UIFont *dimensionFont;

@property(nonatomic, strong) UIColor *dimensionColor;

@end





/// Data of each layer
@interface THLRadarCategoryModel : NSObject

@property(nonatomic, strong) NSArray <NSNumber *> *valueArr;

@property(nonatomic, strong) UIColor *coverageBorderColor;

@property(nonatomic, strong) NSArray <UIColor *> *coverageFillColorArr;

@property(nonatomic, strong, readonly) NSArray <THLRadarDimensionModel *> *dimensionsArr;

@end





@interface THLRadarViewModel : NSObject

@property(nonatomic, assign) RadarBorderLineStyle borderLineStyle;

@property(nonatomic, strong) UIColor *netColor;

@property(nonatomic, strong) UIColor *netMapBgColor;

/// The spacing between the radar map and the dimension text
@property(nonatomic, assign) CGFloat margin;

/// number of equal parts
@property(nonatomic, assign) NSInteger num;

@property(nonatomic, assign) CGFloat netLineWidth;

@property(nonatomic, assign) CGFloat coverageBorderLineW;

@property(nonatomic, strong) UIFont *dimensionFont;

@property(nonatomic, strong) UIColor *dimensionColor;

@property(nonatomic, assign) CGSize dimensionSize;

@property(nonatomic, assign) CGFloat highestScore;

///Maximum width of text in each dimension
@property(nonatomic, assign) CGFloat dimensionMaxWidth;

@property(nonatomic, strong) NSArray <NSString *> *dimensionStrArr;

@property(nonatomic, strong) NSArray <THLRadarCategoryModel*> *categoryArr;

///Control whether to display the score of each dimension   default NO
@property(nonatomic, assign) BOOL isNeedShowValue;

@property(nonatomic, assign) BOOL isNeedSkeletonLine;

@end

NS_ASSUME_NONNULL_END
