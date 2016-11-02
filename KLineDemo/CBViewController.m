//
//  CBViewController.m
//  KLineDemo
//
//  Created by 常 彪 on 13-11-2.
//  Copyright (c) 2013年 常 彪. All rights reserved.
//

#import "CBViewController.h"

#import "CBKLineView.h"
#import "CBDataProvider.h"

@interface CBViewController ()

@end

@implementation CBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.autoresizesSubviews = YES;
    CGSize winSize = [UIScreen mainScreen].applicationFrame.size;
    _kLineView = [[CBKLineView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
    _kLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_kLineView];
    
    CBDataProvider *dataProvider = [[CBDataProvider alloc] init];
    [dataProvider provideForView:_kLineView];
    
    
    
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGSize winSize = [UIScreen mainScreen].applicationFrame.size;
    NSLog(@"app frame is %@", NSStringFromCGSize(winSize));
    if (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)) {
        _kLineView.frame = CGRectMake(0, 0, winSize.height, winSize.width);
    }else{
        _kLineView.frame = CGRectMake(0, 0, winSize.width, winSize.height);
    }
    NSLog(@"KlineView frame is %@", NSStringFromCGRect(_kLineView.frame));
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0){
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
