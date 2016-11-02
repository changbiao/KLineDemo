//
//  main.m
//  KLineDemo
//
//  Created by 常 彪 on 13-11-2.
//  Copyright (c) 2013年 常 彪. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CBAppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        
        int iPrice = 1235;
        NSString *priceString = nil;
        for (int i=0; i<18; i++) {
            if (iPrice > 9999999) {
                priceString = [NSString stringWithFormat:@"%.2f千万", iPrice*0.0000001f];
            }else if (iPrice > 9999){
                priceString = [NSString stringWithFormat:@"%.2f万", iPrice*0.0001f];
            }else{
                priceString = [NSString stringWithFormat:@"%d", iPrice];
            }
            NSLog(@"%d:%@", iPrice, priceString);
            iPrice += iPrice;
        }

        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([CBAppDelegate class]));
    }
}
