//
//  TimeLineView.m
//  TimeLineView-Demo
//
//  Created by 吴三忠 on 2018/6/12.
//  Copyright © 2018年 吴三忠. All rights reserved.
//

#import "TimeLineView.h"

@interface TimeLineView()

@property (nonatomic, assign) int xAxisNumber;
@property (nonatomic, assign) int yAxisNumber;
@property (nonatomic, assign) CGFloat topMargin;
@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat bottomMargin;
@property (nonatomic, assign) CGFloat rightMargin;
@property (nonatomic, strong) NSArray *orderArray;
@property (nonatomic, strong) NSMutableArray *xLabels;
@property (nonatomic, strong) NSMutableArray *yLabels;


@property (nonatomic, strong) CAShapeLayer *lineChartLayer;
@property (nonatomic, strong) CAShapeLayer *coverLayer;

@end

@implementation TimeLineView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.xAxisNumber = 6;
        self.yAxisNumber = 5;
        self.topMargin = 10;
        self.leftMargin = 40;
        self.bottomMargin = 30;
        self.rightMargin = 40;
        [self drawAxisLines:frame];
    }
    return self;
}

- (void)setDataArray:(NSArray *)dataArray {
    
    _dataArray = dataArray;
    [self drawLineLayer];
    [self addLabels];
}

- (void)drawAxisLines:(CGRect)frame {
    
    CGFloat x_margin = (frame.size.height - self.topMargin - self.bottomMargin)*1.0/self.yAxisNumber;
    CGFloat x_width = frame.size.width - self.leftMargin - self.rightMargin + 20;
    for (int i = 0; i <= self.yAxisNumber; i++) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(self.leftMargin, self.topMargin+x_margin*i, x_width, 1)];
        v.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        [self addSubview:v];
    }
    
    CGFloat y_margin = (frame.size.width - self.leftMargin - self.rightMargin-1)*1.0/self.xAxisNumber;
    for (int i = 0; i <= self.xAxisNumber; i++) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(self.leftMargin+y_margin*i, i?frame.size.height-self.bottomMargin:0, 1, i?10:frame.size.height-self.bottomMargin+10)];
        v.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        [self addSubview:v];
    }
}

- (void)drawLineLayer
{
    UIBezierPath *path = [self linePath];
    if (self.lineChartLayer) {
        [self.lineChartLayer removeFromSuperlayer];
        self.lineChartLayer = nil;
    }
    self.lineChartLayer = [CAShapeLayer layer];
    self.lineChartLayer.path = path.CGPath;
    self.lineChartLayer.strokeColor = [UIColor blueColor].CGColor;
    self.lineChartLayer.fillColor = [[UIColor clearColor] CGColor];
    self.lineChartLayer.lineWidth = 1;
    self.lineChartLayer.lineCap = kCALineCapRound;
    self.lineChartLayer.lineJoin = kCALineJoinRound;
    self.lineChartLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:self.lineChartLayer];
    [path addLineToPoint:CGPointMake(self.bounds.size.width-self.rightMargin, self.bounds.size.height-self.bottomMargin)];
    [path addLineToPoint:CGPointMake(self.leftMargin, self.bounds.size.height-self.bottomMargin)];
    [path closePath];
    if (self.coverLayer) {
        [self.coverLayer removeFromSuperlayer];
        self.coverLayer = nil;
    }
    self.coverLayer = [CAShapeLayer layer];
    self.coverLayer.path = path.CGPath;
    self.coverLayer.strokeColor = [UIColor clearColor].CGColor;
    self.coverLayer.fillColor = [UIColor magentaColor].CGColor;
    self.coverLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:self.coverLayer];
}

- (UIBezierPath *)linePath {
    
    self.orderArray = [self.dataArray sortedArrayUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
        float value1 = [obj1.lastObject floatValue];
        float value2 = [obj2.lastObject floatValue];
        if (value1 < value2) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    float yMinValue = [((NSArray *)self.orderArray.firstObject).lastObject floatValue]*(1 - 0.05);
    float yMaxValue = [((NSArray *)self.orderArray.lastObject).lastObject floatValue]*(1 + 0.05);
    CGFloat x_margin = (self.bounds.size.width - self.leftMargin - self.rightMargin)/(self.dataArray.count-1);
    CGFloat y_margin = (self.bounds.size.height-self.topMargin-self.bottomMargin)/(yMaxValue-yMinValue-1);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [self.dataArray enumerateObjectsUsingBlock:^(NSArray* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat delY = [obj.lastObject floatValue] - yMinValue;
        if (idx == 0) {
            [path moveToPoint:CGPointMake(self.leftMargin, self.bounds.size.height-self.bottomMargin-delY*y_margin)];
        } else {
            [path addLineToPoint:CGPointMake(self.leftMargin+idx*x_margin,self.bounds.size.height-self.bottomMargin-delY*y_margin)];
        }
    }];
    return path;
}

- (void)addLabels {
    
    if (self.xLabels) {
        [self.xLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.xLabels = nil;
    }
    self.xLabels = [NSMutableArray array];
    if (self.yLabels) {
        [self.yLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.yLabels = nil;
    }
    self.yLabels = [NSMutableArray array];
    int yMinValue = (int)[((NSArray *)self.orderArray.firstObject).lastObject integerValue]*(1 - 0.05);
    int yMaxValue = (int)[((NSArray *)self.orderArray.lastObject).lastObject integerValue]*(1 + 0.05);
    int yPartValue = (yMaxValue - yMinValue)/self.yAxisNumber;
    CGFloat lblH = (self.bounds.size.height-self.topMargin-self.bottomMargin)*1.0/self.yAxisNumber;
    for (int i = 0; i <= self.yAxisNumber; i++) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, self.topMargin-lblH*0.5+lblH*i, self.leftMargin-3, lblH)];
        lbl.text = [NSString stringWithFormat:@"%d", yMaxValue-yPartValue*i];
        lbl.font = [UIFont systemFontOfSize:8];
        lbl.textAlignment = NSTextAlignmentRight;
        [self addSubview:lbl];
        [self.yLabels addObject:lbl];
    }
    double xMinValue = [((NSArray *)self.dataArray.firstObject).firstObject doubleValue];
    double xMaxValue = [((NSArray *)self.dataArray.lastObject).firstObject doubleValue];
    double xPartValue = (xMaxValue - xMinValue)/self.xAxisNumber;
    NSString *ft = [self timeFormat:xPartValue];
    CGFloat lblW = (self.bounds.size.width-self.leftMargin-self.rightMargin)*1.0/self.xAxisNumber;
    for (int i = 0; i <= self.xAxisNumber; i++) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(self.leftMargin-lblW*0.5+lblW*i, self.bounds.size.height-self.bottomMargin+10, lblW, self.bottomMargin-10)];
        lbl.text = [self timeString:xMinValue+xPartValue*i format:ft];
        lbl.font = [UIFont systemFontOfSize:8];
        lbl.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lbl];
        [self.xLabels addObject:lbl];
    }
}

- (NSString *)timeString:(double)timeInterval format:(NSString *)format {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval/1000];
    NSDateFormatter *ft = [[NSDateFormatter alloc] init];
    ft.dateFormat = format;
    return [ft stringFromDate:date];
}

- (NSString *)timeFormat:(double)timeInterval {
    
    int value = (int)(timeInterval/(1000*3600*24));
    if (value <= 1) {
        return @"HH:mm";
    } else if (value >= 365) {
        return @"YY-MM";
    } else {
        return @"MM-dd";
    }
}

@end
