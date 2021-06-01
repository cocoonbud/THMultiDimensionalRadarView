//
//  ViewController.m
//  THMultiDimensionalRadar
//
//  Created by Terence Yang on 2021/6/1.
//

#import "ViewController.h"
#import "THMultiDimensionalRadarView.h"

@interface ViewController ()

@property(nonatomic, strong) THMultiDimensionalRadarView *radarView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"multi dimensional radar";
    [self.view addSubview:self.radarView];
    self.radarView.frame = CGRectMake((self.view.frame.size.width - 300) / 2,
                                      (self.view.frame.size.height - 300) / 2,
                                      300,
                                      300);
    self.radarView.radarModel = [self makeAndAssignData2RadarView];
}

#pragma mark - privace
- (THLRadarViewModel *)makeAndAssignData2RadarView {
    THLRadarViewModel *model = [[THLRadarViewModel alloc] init];
    
    model.borderLineStyle = RadarBorderLineStyleMesh;
    model.margin = 4;
    model.num = 3;
    model.netMapBgColor = [UIColor greenColor];
    model.netColor = [UIColor blackColor];
    model.highestScore = 10;
    model.dimensionStrArr = @[@"d1", @"d2", @"d3", @"d4", @"d5", @"d6", @"d7", @"d8", @"d9", @"d10"];
    
    NSMutableArray *categoryArrM = [NSMutableArray array];
    
    NSArray *colorArr = @[@[[[UIColor redColor] colorWithAlphaComponent:0.3],
                            [[UIColor redColor] colorWithAlphaComponent:0.5]],
                          @[[[UIColor blueColor] colorWithAlphaComponent:0.3],
                            [[UIColor blueColor] colorWithAlphaComponent:0.5]]];
    
    NSArray *valueArr = @[@[@(0), @(10), @(8), @(7), @(6), @(5), @(4), @(3), @(2), @(1)],
                          @[@(0), @(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8), @(10)]];
    
    for (NSInteger i = 0; i < valueArr.count; i++) {
        THLRadarCategoryModel *valueModel = [THLRadarCategoryModel new];

        valueModel.valueArr = valueArr[i];
        valueModel.coverageFillColorArr = colorArr[i];
        [categoryArrM addObject:valueModel];
    }
    
    model.categoryArr = [categoryArrM copy];
    return model;
}

#pragma mark - lazy load
- (THMultiDimensionalRadarView *)radarView {
    if (!_radarView) {
        _radarView = [[THMultiDimensionalRadarView alloc] init];
        _radarView.backgroundColor = [UIColor whiteColor];
    }
    return _radarView;
}
@end
