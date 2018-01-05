//
//  ViewController.m
//  Demo
//
//  Created by deguang.mo on 2018/1/5.
//  Copyright © 2018年 deguang.mo. All rights reserved.
//

#import "ViewController.h"
#import "DemoService.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [DemoService testConnect];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
