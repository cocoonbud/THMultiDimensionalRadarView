//
//  THMultiDimensionalRadarView.m
//
//  Created by cocoon on 2018/9/24.
//  Copyright © 2018 cocoon. All rights reserved.
//

#import "THMultiDimensionalRadarView.h"

@interface THMultiDimensionalRadarView()

@property(nonatomic, assign) CGFloat diameter;

@end

@implementation THMultiDimensionalRadarView

static CGFloat radarW = 0;

static CGFloat radarH = 0;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    switch (self.radarModel.borderLineStyle) {
        case RadarBorderLineStyleMesh:
            [self drawRadarMeshLine];
            break;
        case RadarBorderLineStyleLoop:
            [self drawRadarLoopLineLine];
            break;
    }

    [self drawSkeletonAndDimension];
    [self drawCoverageArea];
}

#pragma mark - private
- (void)drawRadarLoopLineLine {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, self.radarModel.netMapBgColor.CGColor);
    CGContextSetStrokeColorWithColor(context, self.radarModel.netColor.CGColor);
    CGContextSetLineWidth(context, self.radarModel.netLineWidth);
    
    for (int i = 1; i <= self.radarModel.num; i++) {
        CGContextMoveToPoint(context,
                             self.frame.size.width / 2 + self.diameter / self.radarModel.num * i,
                             self.frame.size.height / 2);
        CGContextAddArc(context,
                        self.frame.size.width / 2,
                        self.frame.size.height / 2,
                        self.diameter / self.radarModel.num * i, 0, 2 * M_PI, 0);
    }
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)drawRadarMeshLine {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, self.radarModel.netMapBgColor.CGColor);
    CGContextSetStrokeColorWithColor(context, self.radarModel.netColor.CGColor);
    CGContextSetLineWidth(context, self.radarModel.netLineWidth);
    
    THLRadarCategoryModel *model = ((THLRadarCategoryModel *)self.radarModel.categoryArr.firstObject);

    NSInteger r = self.radarModel.num;
    
    NSInteger dCount = model.dimensionsArr.count;
    
    CGContextMoveToPoint(context, self.frame.size.width / 2, self.frame.size.height / 2 - self.diameter);
    
    CGFloat x = 0, y = 0, angle = 0;
    
    for (int i = 0; i < r; i++) {
        for (int j = 1; j <= dCount; j++) {
            angle = (M_PI * 2.0 / dCount) * j;
            
            calculateXY(angle,
                        self.diameter * (r - i) / r,
                        self.frame.size.width / 2,
                        self.frame.size.height / 2,
                        &x,
                        &y);
            
            if (j == 1) {
                CGContextMoveToPoint(context,
                                     self.frame.size.width / 2,
                                     self.frame.size.height / 2 - self.diameter + self.diameter * i / r);
            }
            
            if (j == dCount) {
                CGContextAddLineToPoint(context,
                                        self.frame.size.width / 2,
                                        self.frame.size.height / 2 - self.diameter + self.diameter * i / r);
            } else {
                CGContextAddLineToPoint(context, x, y);
            }
        }
    }
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)drawSkeletonAndDimension {
    CGFloat w = self.frame.size.width / 2, h = self.frame.size.height / 2;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, self.radarModel.netColor.CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextMoveToPoint(context, w, h);
    if (self.radarModel.isNeedSkeletonLine) {
        CGContextAddLineToPoint(context, w, h - self.diameter);
    }
    
    THLRadarCategoryModel *model = ((THLRadarCategoryModel *)self.radarModel.categoryArr.firstObject);
    
    CGContextSaveGState(context);
    
    NSInteger count = model.dimensionsArr.count;
    
    CGFloat x = 0, x1 = 0, y = 0, y1 = 0, angle = 0;
    
    CGRect frame = CGRectZero;
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine;
    
    for (int i = 0; i < count; i++) {
        THLRadarDimensionModel *dModel = model.dimensionsArr[i];

        angle = (M_PI * 2.0 / count) * i;
        calculateXY(angle, self.diameter, w, h, &x, &y);
        calculateXY(angle, self.diameter + self.radarModel.margin, w, h, &x1, &y1);
        calculateFrame(angle, dModel.size, x > w, x1, y1, &frame);
        [dModel.itemName drawWithRect:frame
                              options:options
                           attributes:@{NSFontAttributeName:dModel.dimensionFont,
                                        NSForegroundColorAttributeName:dModel.dimensionColor}
                              context:nil];
        CGContextMoveToPoint(context, w, h);
        if (self.radarModel.isNeedSkeletonLine) {
            CGContextAddLineToPoint(context, x, y);
        }
    }
    CGContextRestoreGState(context);
    CGContextStrokePath(context);
}

- (void)drawCoverageArea {
    CGContextRef context = UIGraphicsGetCurrentContext();
        
    NSInteger cCount = self.radarModel.categoryArr.count;
    
    for (int i = 0; i < cCount; i++) {
        THLRadarCategoryModel *category = self.radarModel.categoryArr[i];

        if (category.coverageBorderColor) {
            CGContextSetStrokeColorWithColor(context, category.coverageBorderColor.CGColor);
        }
        
        CGContextSetLineWidth(context, self.radarModel.coverageBorderLineW);
        
        CGMutablePathRef path = CGPathCreateMutable();
        
        NSInteger dCount = category.dimensionsArr.count;
        
        CGPoint firstP = CGPointZero;
        
        CGFloat x = 0, y = 0, angle = 0;
        
        CGFloat w = self.frame.size.width / 2, h = self.frame.size.height / 2;
        
        for (int j = 0; j < dCount; j++) {
            THLRadarDimensionModel *dModel = category.dimensionsArr[j];
            
            if (j == 0) {
                firstP = CGPointMake(w, h - self.diameter + self.diameter * (1 - dModel.itemPercent));
                CGPathMoveToPoint(path, NULL, firstP.x, firstP.y);
            }else  {
                angle = (M_PI * 2.0 / dCount) * j;
                calculateXY(angle, self.diameter * dModel.itemPercent, w, h, &x, &y);
                CGPathAddLineToPoint(path, NULL, x, y);
            }
        }
        
        CGPathAddLineToPoint(path, NULL, firstP.x, firstP.y);
        CGContextAddPath(context, path);
        [self drawRadialGradient:context path:path colors:category.coverageFillColorArr];
        if (category.coverageBorderColor) {
            CGContextStrokePath(context);
        }else {
            CGContextDrawPath(context, kCGPathFill);
        }
    }
}

- (void)drawRadialGradient:(CGContextRef)context path:(CGPathRef)path colors:(NSArray <UIColor *>*)colors {
    NSMutableArray *colorsM = [NSMutableArray arrayWithCapacity:colors.count];
    
    for (UIColor *color in colors) {
        [colorsM addObject:(__bridge id)(color.CGColor)];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGFloat locations[] = {1.0, 1.0};
    
    CGGradientRef gradient;
    
    if (colors.count > 1) {
        CGFloat locations1[] = {0.0, 1.0};
        
        gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colorsM, locations1);
    }else {
        gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colorsM, locations);
    }

    CGRect pathRect = CGPathGetBoundingBox(path);

    CGPoint startPoint = CGPointMake(CGRectGetMinX(pathRect), CGRectGetMidY(pathRect));

    CGPoint endPoint = CGPointMake(CGRectGetMaxX(pathRect), CGRectGetMidY(pathRect));

    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

static inline void calculateFrame(CGFloat a, CGSize size, BOOL isLeft, CGFloat x1, CGFloat y1, CGRect *frame) {
    if (compareDouble(a, 0)) {
        *frame = CGRectMake(x1 - size.width / 2, y1 - size.height, size.width, size.height);
    }else if (compareDouble(a, M_PI)){
        *frame = CGRectMake(x1 - size.width / 2, y1, size.width, size.height);
    }else if (compareDouble(a, M_PI_2)) {
        *frame = CGRectMake(x1, y1 - size.height / 2, size.width, size.height);
    }else if (compareDouble(a, M_PI_2 * 3)) {
        *frame = CGRectMake(x1 - size.width, y1 - size.height / 2, size.width, size.height);
    }else {
        if (isLeft) {
            if (a > 0 && a < M_PI_2) {
                *frame = CGRectMake(x1, y1 - size.height, size.width, size.height);
            }else{
                *frame = CGRectMake(x1, y1, size.width, size.height);
            }
        } else {
            if (a > M_PI && a < M_PI_2 * 3) {
                *frame = CGRectMake(x1 - size.width, y1, size.width, size.height);
            }else{
                *frame = CGRectMake(x1 - size.width, y1 - size.height, size.width, size.height);
            }
        }
    }
}

static inline void calculateXY(double a, CGFloat l, CGFloat cW, CGFloat cH, CGFloat *x, CGFloat *y) {
    *x = cW + sinf(a) * l;
    *y = cH - cosf(a) * l;
}

static inline BOOL compareDouble(CGFloat a, CGFloat b) {
    return ((a - b > -0.000001) && (a - b) < 0.000001) ? YES : NO;
}

static inline void getDimensionMaxWAndMaxH(THLRadarCategoryModel *model,
                                           CGFloat dMaxW,
                                           CGFloat dMaxH,
                                           CGFloat *maxW,
                                           CGFloat *maxH) {
    NSInteger count = model.dimensionsArr.count;
    
    CGFloat resW = 0, resH = 0;
    
    for (int i = 0; i < count; i++) {
        THLRadarDimensionModel *dModel = model.dimensionsArr[i];
                
        if (dModel.size.width > resW) {
            resW = dModel.size.width;
        }
        if (dModel.size.height > resH) {
            resH = dModel.size.height;
        }
    }
    *maxW = resW;
    *maxH = resH;
}

#pragma mark - setter
- (void)setRadarModel:(THLRadarViewModel *)radarModel {
    _radarModel = radarModel;
    radarW = self.frame.size.width;
    radarH = self.frame.size.height;
    
    CGFloat dMaxW = 0, dMaxH = 0;
    
    for (NSInteger i = 0; i < radarModel.categoryArr.count; i++) {
        THLRadarCategoryModel *categoryModel = radarModel.categoryArr[i];
        
        for (NSInteger j = 0; j < categoryModel.dimensionsArr.count; j++) {
            THLRadarDimensionModel *dModel = categoryModel.dimensionsArr[j];
            
            if (dModel.size.width < 0.000001 && dModel.size.height < 0.000001) {
                NSDictionary *attributes = @{NSFontAttributeName:dModel.dimensionFont,
                                             NSForegroundColorAttributeName:dModel.dimensionColor};
                
                CGSize itemSize = [dModel.itemName boundingRectWithSize:CGSizeMake(dMaxW, dMaxH)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:attributes
                                                                context:nil].size;
                dModel.size = itemSize;
            }
        }
        
        if (i == 0) {
            getDimensionMaxWAndMaxH(categoryModel, self.frame.size.width, self.frame.size.height, &dMaxW, &dMaxH);
        }
    }
    
    CGFloat d1 = self.frame.size.width / 2 - dMaxW - self.radarModel.margin;
    
    CGFloat d2 = self.frame.size.height / 2 - dMaxH - self.radarModel.margin;
    
    self.diameter = d1 < d2 ? d1 : d2;
    [self setNeedsDisplay];
}

@end
