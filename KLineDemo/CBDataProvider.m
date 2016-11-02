//
//  CBDataProvider.m
//  KLineDemo
//
//  Created by 常 彪 on 13-11-2.
//  Copyright (c) 2013年 常 彪. All rights reserved.
//

#import "CBDataProvider.h"
#import "CBKLineItem.h"
#import "CBTestKData.h"

@implementation CBDataProvider

- (void)provideForView:(NSObject<CBDataProvideProtocol> *)view
{
    [view displayWithKDataDict:[CBTestKData getKLData]];
}

@end
