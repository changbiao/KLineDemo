//
//  CBKLineItem.h
//  KLineDemo
//
//  Created by 常 彪 on 13-11-2.
//  Copyright (c) 2013年 常 彪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBKLineItem : NSObject
{
@public
	int ktype;
	int date;							// K线时间
	float open;							// 开盘价
	float high;							// 最高价
	float low;							    // 最低价
	float close;							// 收盘价
	int vol;                            // 成交量
	int amount;							// 成交额
	int eropen;							// 除权开盘价
	int erhigh;							// 除权最高价
	int erlow;							// 除权最低价
	int erclose;					     	// 除权收盘价
    int ervol;
	int position;						// 持仓量
	float	ddxvalue;					// DDX值
	float	ddyvalue;					// DDY值
	float	ddzvalue;					// DDZ值
	float	suplvalue;					// SUPL值
    short   ddzwidth;
	CBKLineItem *preKItem;				// 前一天的K线项
}
@property (nonatomic, retain) NSString * strdate;
@property (nonatomic, retain) NSString * stropen;
@property (nonatomic, retain) NSString * strhigh;
@property (nonatomic, retain) NSString * strlow;
@property (nonatomic, retain) NSString * strclose;
@property (nonatomic, retain) NSString * strvol;
@property (nonatomic, retain) NSString * stramount;
@property (nonatomic, retain) NSString * strposition;
@property (nonatomic, retain) NSString * strincstock;
@property (nonatomic, retain) NSString * strzf;
@property (nonatomic, retain) NSString * strhs;
@property (nonatomic, retain) NSString * strddxvalue;
@property (nonatomic, retain) NSString * strddyvalue;
@property (nonatomic, retain) NSString * strddzvalue;
@property (nonatomic, retain) NSString * strsuplvalue;
@property (nonatomic, retain) NSString * streropen;
@property (nonatomic, retain) NSString * strerhigh;
@property (nonatomic, retain) NSString * strerlow;
@property (nonatomic, retain) NSString * strerclose;
@property (nonatomic, retain) NSString * strerzf;
@property (nonatomic, retain) NSString * strervol;



@end



