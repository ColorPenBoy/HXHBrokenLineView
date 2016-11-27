//
//  ViewController.m
//  折线图
//
//  Created by colorpen on 2016/11/25.
//  Copyright © 2016年 colorpen. All rights reserved.
//

#import "ViewController.h"
#import "HXHBrokenLineView.h"


@interface ViewController ()

@property (nonatomic, strong) HXHBrokenLineView * lineView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

   
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    self.lineView = [[HXHBrokenLineView alloc] initWithFrame:CGRectMake(25, 100, self.view.bounds.size.width - 50, 215) data:@[@0, @0, @0, @0, @0, @0]];
    self.lineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.lineView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
