//
//  CBKLineView.h
//  KLineDemo
//
//  Created by 常 彪 on 13-11-2.
//  Copyright (c) 2013年 常 彪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBDataProvideProtocol.h"


typedef enum {
    KLineTouchEventUnknown = 0,
    KLineTouchEventZoomIn = 1,
    KLineTouchEventZoomOut = 2,
    KLineTouchEventLeft   = 3,
    KLineTouchEventRight  = 4,
} KLineTouchEvent;


@interface CBKLineView : UIView <CBDataProvideProtocol>
{
@public
	// 绘图区域
	CGRect	_rtTopText;          // 顶部区域,绘制
	CGRect	_rtLeftText;         // 左边区域
	CGRect  _rtBottomText;        // 底部区域
	CGRect	_rtKLine;            // K线区域
	CGRect	_rtTech;             // K线指标区域
	
	// 操作参数
	int		_topTextFontSize;
    int     _leftScaleFontSize;
	int		_kItemSize;             // K线大小
	int     _kItemWidth;
	int		_kIndexOffset;            // K线偏移
	int		_curSelectIndex;        // 当前选择位置
    int     _visiableItemCount;     //可见项目的个数
    float   _visiableMinPrice;      //可见区域最低价格
    float   _visiableMaxPrice;      //可见区域最高价格
	float   _maxpricevalue;         //所有数据最大数值
	float   _minpricevalue;         //所有数据最小数值
    int     _visiableMinVolume;      //可见区域最低成交量
    int     _visiableMaxVolume;      //可见区域最高成交量
	int		m_selcycle;             // 当前选择得周期
	int		m_seltech;              // 当前选择的指标
	
    // 颜色信息
    UIColor *_sunColor;  //阳线颜色
    UIColor *_moonColor;  //阴线颜色
    
	// 触摸位置信息
	CGPoint   _startTouchPosition;         // 触摸开始位置
	CGPoint   _movebeginTouchPosition;     // 移动开始位置
	CGPoint   _moveendTouchPosition;       // 移动结束位置
	CGPoint   _endTouchPosition;           // 触摸结束位置
	CGFloat   _originSpace;                // 双指触摸两点间距离
    CGFloat    _startTwoFingerX;            // 双指平均开始横坐标
    CGFloat    _moveendTwoFingerX;           // 双指移动结束横坐标
    /*
	// 浮动面板
	FloatPanelEx		*m_floatpanel;								// 浮动面板
    KLineTechTextView   *klineTipTxtV;
    KLineTechTextView   *klineBottomTxtV;
    UILabel             *lBSText;
    cursorView          *vertCursorV;
    cursorView          *horzCursorV;
     */
     
	CGRect				rtfloatpanel;     // 浮动面板位置
	BOOL				isshowfloatinfo;      // 切换信息面板显示
	int					m_curERIndex;     // 除权数据索引
	BOOL				isReqDecIndex;
    NSTimer             *hideCursorTimer;
}

@property(nonatomic, assign)  CGRect rtTopText;
@property(nonatomic, assign) CGRect rtLeftText;
@property(nonatomic, assign) CGRect rtBottomText;
@property(nonatomic, assign) CGRect rtKLine;
@property(nonatomic, assign) CGRect rtTech;
@property(nonatomic, assign) CGRect rtfloatpanel;
@property(nonatomic, assign) CGPoint startTouchPosition;
@property(nonatomic, assign) CGPoint movebeginTouchPosition;
@property(nonatomic, assign) CGPoint moveendTouchPosition;
@property(nonatomic, assign) CGPoint endTouchPosition;
@property(nonatomic, assign) CGFloat originSpace;
@property(nonatomic, assign) CGFloat AccelerationNum;

@property (nonatomic, retain) NSMutableArray *allKLineItems;

@end
