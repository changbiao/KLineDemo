//
//  CBDataProvider.h
//  KLineDemo
//
//  Created by 常 彪 on 13-11-2.
//  Copyright (c) 2013年 常 彪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBDataProvideProtocol.h"
 

@interface CBDataProvider : NSObject

- (void)provideForView:(NSObject<CBDataProvideProtocol> *)view;

@end
