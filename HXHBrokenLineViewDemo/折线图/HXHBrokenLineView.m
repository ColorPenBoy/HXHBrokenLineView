//
//  HXHBrokenLineView.m
//  折线图
//
//  Created by colorpen on 2016/11/25.
//  Copyright © 2016年 colorpen. All rights reserved.
//

#import "HXHBrokenLineView.h"

// 坐标轴线宽
static CGFloat const lineWidth = 1.0;
// 边界
static CGFloat const topEdgeInsets      = 15.0;
static CGFloat const bottomEdgeInsets   = 15.0;
static CGFloat const leftEdgeInsets     = 15.0;
static CGFloat const rightEdgeInsets    = 15.0;

// 纵轴固定5等分
static NSUInteger const heightPartCount = 5;
// 横轴固定4等分
static NSUInteger const widthPartCount = 4;

@interface HXHBrokenLineView ()

/** 小圆点的坐标 - Y 的数组 */
@property (nonatomic, strong) NSArray<NSNumber *> *roundPointArray;
/** 折线图每个转折点的坐标 - Y 的数组 */
@property (nonatomic, strong) NSArray<NSNumber *> *linePointArray;
/** 阴影区域路径每个转折点的坐标 - Y 的数组 */
@property (nonatomic, strong) NSArray<NSNumber *> *fillLinePointArray;

@end

@implementation HXHBrokenLineView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame data:(NSArray<NSString *> *)dataArray
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // 传入数组
//        NSArray * arr = @[@"13.75",@"24.38",@"30.00"];
//        NSArray * arr = @[@"13.75",@"24.38",@"30.00",@"25.14"];
        NSArray * arr = @[@"13.75",@"24.38",@"30.00",@"25.14",@"18.00"];

        NSArray * resultArray = [self dealWithDataArray:arr];
        // 画线的数组
        self.linePointArray = resultArray;
        // 空心点数组
        NSMutableArray * newArr = [resultArray mutableCopy];
        [newArr removeObjectAtIndex:0];
        if (newArr.count > 4) {// 如果移除了第一个以后，还多于4个，移除最后一个
            [newArr removeLastObject];
        }
        self.roundPointArray = newArr;
        
    }
    return self;
}

- (NSArray<NSNumber *> *)dealWithDataArray:(NSArray<NSString *> *)dataArray {

    /************* 处理数组元素个数（前面加一个，后面修改一个） ************/
    NSMutableArray<NSString *> * newPriceArray = [dataArray mutableCopy];
    float newItem = [newPriceArray.firstObject floatValue] * 1.1;
    [newPriceArray insertObject:[NSString stringWithFormat:@"%@",@(newItem)] atIndex:0];
    
    /** 如果是6个元素，item5 = 0.5 * fabsf(item5 - item4) */
    if (dataArray.count > 5) {
        float lastItem = 0.5 * fabsf([newPriceArray[5] floatValue] - [newPriceArray[4] floatValue]);
        [newPriceArray replaceObjectAtIndex:4 withObject:[NSString stringWithFormat:@"%@",@(lastItem)]];
    }
    
    /************************ 价格数组 -> 坐标Y数组 -> 返回 ****************************/
    return [self priceArrayConvertToPointArray:newPriceArray];
}

/**
 *  数据源处理逻辑
 *  @param priceArray 输入价格数组
 *  @return 每个点纵坐标数组
 */
- (NSArray<NSNumber *> *)priceArrayConvertToPointArray:(NSArray<NSString *> *)priceArray {

    if (priceArray.count <= 0) {
        return @[@0, @0, @0, @0, @0, @0];
    }
 
    // 每个刻度的高度
    CGFloat bounceH = self.bounds.size.height;
    CGFloat point_Y_height = (bounceH - topEdgeInsets - bottomEdgeInsets) / heightPartCount;

    // 每个刻度对应的价格
    float point_Y_Price = [self getMaxValueFrom:priceArray];
    
    // 单位价格对应的高度
    CGFloat unitHeight = point_Y_height / point_Y_Price;
    
    NSMutableArray * resultArray = [NSMutableArray array];
    for (NSString * item in priceArray) {
        // 刻度数值
        float result_Y = bounceH - bottomEdgeInsets - [item floatValue] * unitHeight;
        [resultArray addObject:[NSNumber numberWithFloat:result_Y]];
    }
    
    return resultArray;
}

/** 求Y轴 每个格的刻度(单位) */
- (float)getMaxValueFrom:(NSArray<NSString *> *)priceArray {
    __block float maxItemValue = [[priceArray firstObject] floatValue];
    [priceArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        float itemValue = [obj floatValue];
        if (itemValue > maxItemValue) {
            maxItemValue = itemValue;
        }
    }];
    return (maxItemValue + 20.0) / heightPartCount;
}

- (void)drawRect:(CGRect)rect {
    /** 画固定坐标 */
    CGFloat boundsW = self.bounds.size.width;
    CGFloat boundsH = self.bounds.size.height;
    
    CGPoint point1 = CGPointMake(leftEdgeInsets , 0);
    CGPoint point2 = CGPointMake(leftEdgeInsets , boundsH - bottomEdgeInsets);
    CGPoint point3 = CGPointMake(boundsW - rightEdgeInsets , boundsH - bottomEdgeInsets);
    CGPoint point4 = CGPointMake(boundsW - rightEdgeInsets , topEdgeInsets);
    CGPoint point5 = CGPointMake(leftEdgeInsets , topEdgeInsets);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [[UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00] setStroke];
    path.lineWidth = lineWidth;
    [path moveToPoint:point1];
    [path addLineToPoint:point2];
    [path addLineToPoint:point3];
    [path addLineToPoint:point4];
    [path addLineToPoint:point5];
    [path stroke];
    
    /** X - 刻度轴 */
    CGFloat point_Y_height = (boundsH - topEdgeInsets - bottomEdgeInsets) / heightPartCount;
    for (int i = 1; i < heightPartCount; i++) {
        CGPoint fromPoint = CGPointMake(leftEdgeInsets, boundsH - point_Y_height * i - bottomEdgeInsets);
        CGPoint toPoint = CGPointMake(boundsW - rightEdgeInsets, boundsH - point_Y_height * i - bottomEdgeInsets);
        drawBorderLine(fromPoint, toPoint);
    }
    
    /** Y - 刻度轴 */
    CGFloat part_X_width = (boundsW - rightEdgeInsets - leftEdgeInsets) / widthPartCount;
    for (int i = 1; i < widthPartCount; i++) {
        CGPoint fromPoint = CGPointMake(part_X_width * i + leftEdgeInsets, topEdgeInsets);
        CGPoint toPoint = CGPointMake(part_X_width * i  + leftEdgeInsets, boundsH - bottomEdgeInsets);
        drawBorderLine(fromPoint, toPoint);
    }
    
    CGFloat roundPointWidth = (boundsW - rightEdgeInsets - leftEdgeInsets) / widthPartCount;
    
    /** 画阴影 */
    [self drawShadeWithRoundPointWidth:roundPointWidth];
    
    /** 画折线 */
    [self drawLineWithRoundPointWidth:roundPointWidth];
    
    /** 坐标处小圆点 - 根据数组count绘制 */
    for (int i = 0; i < self.roundPointArray.count; i++) {
        CGPoint point = CGPointMake(leftEdgeInsets + (0.5 + i) * roundPointWidth, [self.roundPointArray[i] floatValue]);
        [self addRoundViewWithPoint:point];
    }
}

/**
 *  画直线
 *
 *  @param fromPoint 起点
 *  @param toPoint   终点
 */
void drawBorderLine(CGPoint fromPoint, CGPoint toPoint) {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [[UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00] setStroke];
    path.lineWidth = lineWidth;
    [path moveToPoint:fromPoint];
    [path addLineToPoint:toPoint];
    [path stroke];
}

- (void)addRoundViewWithPoint:(CGPoint)point {
    HXHRoundView * roundView = [[HXHRoundView alloc] init];
    roundView.bounds = CGRectMake(0, 0, 8.0, 8.0);
    roundView.center = point;
    [self addSubview:roundView];
}

/** 根据Point Array获取折线的 UIBezierPath */
- (void)drawLineWithRoundPointWidth:(CGFloat)roundPointWidth {
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    for (int i = 0; i < self.linePointArray.count; i++) {
        CGPoint point = CGPointZero;
        if (i == 0) {// 第一个点
            point = CGPointMake(leftEdgeInsets, [self.linePointArray[i] floatValue]);
            [linePath moveToPoint:point];
        } else if (i == 5) {// 6个元素的情况
            point = CGPointMake(self.bounds.size.width - rightEdgeInsets, [self.linePointArray[i] floatValue]);
            [linePath addLineToPoint:point];
        } else {
            point = CGPointMake(leftEdgeInsets + (i - 0.5) * roundPointWidth, [self.linePointArray[i] floatValue]);
            [linePath addLineToPoint:point];
        }
    }
    // 画线
    [self drawLineWithPath:linePath
               strockColor:[UIColor orangeColor]
                 fillColor:[UIColor clearColor]];
}

/** 画阴影 */
- (void)drawShadeWithRoundPointWidth:(CGFloat)roundPointWidth {
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(leftEdgeInsets, self.bounds.size.height - bottomEdgeInsets)];
    CGPoint point = CGPointZero;
    for (int i = 0; i < self.linePointArray.count; i++) {
        if (i == 0) {
            point = CGPointMake(leftEdgeInsets, [self.linePointArray[i] floatValue]);
            [linePath addLineToPoint:point];
        } else if (i == 5) {// 6个元素的情况
            point = CGPointMake(self.bounds.size.width - rightEdgeInsets, [self.linePointArray[i] floatValue]);
            [linePath addLineToPoint:point];
        } else {
            point = CGPointMake(leftEdgeInsets + (i - 0.5) * roundPointWidth, [self.linePointArray[i] floatValue]);
            [linePath addLineToPoint:point];
        }
    }
    [linePath addLineToPoint:CGPointMake(point.x, self.bounds.size.height - bottomEdgeInsets)];
    [self drawLineWithPath:linePath
               strockColor:[UIColor clearColor]
                 fillColor:[[UIColor orangeColor] colorWithAlphaComponent:0.3f]];
}

/** 画折线 */
- (void)drawLineWithPath:(UIBezierPath *)path strockColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor {
    
    // 折线图
    CAShapeLayer *progressLayer = [CAShapeLayer layer];
    progressLayer.lineWidth = 2.5f;
    progressLayer.strokeStart = 0;
    progressLayer.strokeEnd = 0.0;
    progressLayer.lineCap = kCALineCapRound;
    progressLayer.fillColor = fillColor.CGColor;
    progressLayer.strokeColor = strokeColor.CGColor;
    progressLayer.path = path.CGPath;
    [self.layer addSublayer:progressLayer];
    
    // 动画
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"strokeEnd";
    animation.fromValue = @(0);
    animation.toValue = @(1);
    animation.duration = 2.5;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [progressLayer addAnimation:animation forKey:@"strokeEnd"];
}

@end


@implementation HXHRoundView

static CGFloat const roundlineWidth = 2.0;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 0.5 * self.bounds.size.width;

    // 画圆形
    CGFloat arcRadius  = MIN(self.bounds.size.height, self.bounds.size.width) * 0.5 - roundlineWidth * 0.5;
    UIBezierPath *path=[UIBezierPath bezierPathWithArcCenter:self.arcCenter radius:arcRadius startAngle:-M_PI endAngle:M_PI clockwise:YES];
    [[UIColor orangeColor] setStroke];
    path.lineWidth = roundlineWidth;
    [path stroke];
}

- (CGPoint)arcCenter {
    return CGPointMake(self.center.x - self.frame.origin.x, self.center.y - self.frame.origin.y);
}

@end
