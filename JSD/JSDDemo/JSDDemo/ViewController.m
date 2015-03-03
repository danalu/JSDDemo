//
//  ViewController.m
//  JSDDemo
//
//  Created by Dana on 15/2/17.
//  Copyright (c) 2015年 Dana. All rights reserved.
//

#import "ViewController.h"
#import "GridLayoutView.h"

@interface ViewController () {
    GridLayoutView *_gridLayoutView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self viewLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewLayout {
    _gridLayoutView = [[GridLayoutView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:_gridLayoutView];
}

@end
