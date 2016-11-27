//
//  HXHBrokenLineView.h
//  折线图
//
//  Created by colorpen on 2016/11/25.
//  Copyright © 2016年 colorpen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXHBrokenLineView : UIView

/**
 *  必须使用此方法进行构造，保证有数据源传入，否则无Y轴
 *
 *  dataArray的个数：
 *      2个以下 - 不处理
 *      3个、4个、5个 - 正常传入
 *      6个以上 - 传入前五个
 */
- (instancetype)initWithFrame:(CGRect)frame data:(NSArray<NSString *> *)dataArray;

@end


@interface HXHRoundView : UIView

@end
