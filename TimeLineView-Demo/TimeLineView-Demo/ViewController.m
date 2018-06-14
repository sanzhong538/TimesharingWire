//
//  ViewController.m
//  TimeLineView-Demo
//
//  Created by 吴三忠 on 2018/6/12.
//  Copyright © 2018年 吴三忠. All rights reserved.
//

#import "ViewController.h"
#import "TimeLineView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"demo1.data" ofType:nil];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    TimeLineView *tlv = [[TimeLineView alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width-40, 200)];
    tlv.dataArray = dict[@"chart_data"];
    [self.view addSubview:tlv];
    
    NSTimeInterval t = [@"1528845475" doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:t];
    NSLog(@"%@", date);
    
    [[NSDate date] timeIntervalSince1970];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
