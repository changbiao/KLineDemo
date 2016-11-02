//
//  CBKLineView.m
//  KLineDemo
//
//  Created by 常 彪 on 13-11-2.
//  Copyright (c) 2013年 常 彪. All rights reserved.
//

#import "CBKLineView.h"
#import "CBKLineItem.h"

//#define changbiao_debug

#ifdef changbiao_debug
#define CBPrintf(fmt, ...) printf(fmt, ##__VA_ARGS__)
#define CBDebugKLineDraw
#else //changbiao_debug
#define CBPrintf(fmt, ...) do{}while(0)
#ifdef CBDebugKLineDraw
#undef CBDebugKLineDraw
#endif
#endif //changbiao_debug

#define CBDistanceOfPoints(p1, p2) sqrt((p1.x-p2.x)*(p1.x-p2.x) + (p1.y-p2.y)*(p1.y-p2.y));
#define CBAverageTwoPointX(p1, p2) ((p1.x + p2.x) / 2.0f)


@implementation CBKLineView
@synthesize rtTopText = _rtTopText;
@synthesize rtLeftText = _rtLeftText;
@synthesize rtBottomText = _rtBottomText;
@synthesize rtKLine = _rtKLine;
@synthesize rtTech = _rtTech;
@synthesize rtfloatpanel;
@synthesize startTouchPosition = _startTouchPosition;
@synthesize movebeginTouchPosition = _movebeginTouchPosition;
@synthesize moveendTouchPosition = _moveendTouchPosition;
@synthesize endTouchPosition = _endTouchPosition;
@synthesize originSpace = _originSpace;
@synthesize allKLineItems;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        _topTextFontSize           = 12;
        _leftScaleFontSize         = 13;
		_kItemSize                 = 1;
		_kItemWidth            = _kItemSize + 2;
		_kIndexOffset                = 0;
		_curSelectIndex                = -1;
		_maxpricevalue           = 0;
		_minpricevalue           = 0;
		self.AccelerationNum	   = 1.0;
		isshowfloatinfo         = YES;
		isReqDecIndex           = NO;
        
        //_sunColor = [[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f] retain];
        //_moonColor = [[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1.0f] retain];
        _sunColor = [[UIColor colorWithRed:249/255.0f green:15/255.0f blue:1/255.0f alpha:1.0f] retain];
        _moonColor = [[UIColor colorWithRed:32/255.0f green:128/255.0f blue:0.0f alpha:1.0f] retain];
        
        self.multipleTouchEnabled = YES;
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    //rect init;
    CGFloat top_height = 20;
    CGFloat bottom_height = 20;
    CGFloat left_width = 80;
    CGFloat container_height = self.frame.size.height-top_height-bottom_height;
    CGFloat perKLineHeight = 0.7;
    
    self.rtTopText = CGRectMake(0, 0, self.frame.size.width, top_height);
    self.rtBottomText = CGRectMake(0, self.frame.size.height-bottom_height, self.bounds.size.width, bottom_height);
    self.rtLeftText = CGRectMake(0, top_height, left_width, container_height);
    
    self.rtKLine = CGRectMake(left_width, top_height, self.frame.size.width-left_width, container_height*perKLineHeight);
    self.rtTech = CGRectMake(left_width, CGRectGetMaxY(self.rtKLine), self.frame.size.width-left_width, container_height*(1-perKLineHeight));

    [self setNeedsDisplay];
}


#pragma mark 触摸处理
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
	if ([touches count] == 2)
	{
		// 双指触摸
		NSArray *twoTouches = [touches allObjects];
        CGPoint pointOne = [[twoTouches objectAtIndex:0] locationInView:self];
		CGPoint pointTwo = [[twoTouches objectAtIndex:1] locationInView:self];
        
		CGFloat currSpace = CBDistanceOfPoints(pointOne, pointTwo);
        _startTwoFingerX = CBAverageTwoPointX(pointOne, pointTwo);
        
        _curSelectIndex = -1;
        
		self.originSpace = currSpace;
        CBPrintf("\n双指触摸【开始】----> %.1f averageX:%f", currSpace, _startTwoFingerX);
	}
	else if ([touches count] == 1)
	{
		// 单指触摸
		UITouch * touch = [touches anyObject];
		self.startTouchPosition = [touch locationInView:self];
		self.movebeginTouchPosition = _startTouchPosition;
        self.moveendTouchPosition = _startTouchPosition;
		// 单击
		_curSelectIndex = [self calcCurrentSelectIndex:_startTouchPosition];
		if (_curSelectIndex >= 0)
		{
			// 创建浮动面板并调整位置
            CBPrintf("\nSelect item is = %d %s", _curSelectIndex, [[[self.allKLineItems objectAtIndex:_curSelectIndex] description] UTF8String]);
            
		}
		else
		{
			//隐藏选项信息
            
		}
        [self setNeedsDisplay];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{	
	if ([touches count] == 2)
	{
		NSArray* twoTouches=[touches allObjects];
		CGPoint pointOne = [[twoTouches objectAtIndex:0] locationInView:self];
		CGPoint pointTwo = [[twoTouches objectAtIndex:1] locationInView:self];
		
        CGFloat currSpace = CBDistanceOfPoints(pointOne, pointTwo);
        _moveendTwoFingerX = CBAverageTwoPointX(pointOne, pointTwo);
        
		if (self.originSpace == 0)
		{
			self.originSpace = currSpace;
		}
        
        _curSelectIndex = -1;
		
		CGFloat fstep = currSpace-self.originSpace;
        CBPrintf("\n双指触摸【移动】----> %.1f Scale:%.1f averageX:%f Xoffset:%.1f",
                 currSpace, fstep,
                 _moveendTwoFingerX, _moveendTwoFingerX-_startTwoFingerX);
        
		if (fabsf(fstep) >= 15.0)
		{
			if (fstep > 0.0)
			{
				[self zoomInKLine];
				self.originSpace = currSpace;
			}
			else if (fstep < 0.0)
			{
				[self zoomOutKLine];
				self.originSpace = currSpace;
			}
            _startTwoFingerX = _moveendTwoFingerX;
		}
        else
        {
            [self moveKLine];
        }
	}
	else if ([touches count] == 1)
	{
		UITouch * touch = [touches anyObject];
		self.moveendTouchPosition = [touch locationInView:self];

		_curSelectIndex = [self calcCurrentSelectIndex:_moveendTouchPosition];
		
		if (_curSelectIndex >= 0)
		{
			// 创建浮动面板并调整位置
            CBPrintf("\nMove to item is = %d %s", _curSelectIndex, [[[self.allKLineItems objectAtIndex:_curSelectIndex] description] UTF8String]);
		}
		else
		{
            
		}
        [self setNeedsDisplay];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.originSpace = 0;
    
	UITouch * touch = [touches anyObject];
	self.endTouchPosition = [touch locationInView:self];
    
    _moveendTwoFingerX = 0.0f;
    _startTwoFingerX  = 0.0f;
}

- (int)judgeTouchMoveBigSmallOperation
{
	int ymoveHeight = self.rtKLine.size.height / 4;
	int xmoveHeight	= self.rtKLine.size.width / 6;
	
	int ytouch1movedistance = _moveendTouchPosition.y - _movebeginTouchPosition.y;
	int xtouch1movedistance = _moveendTouchPosition.x - _movebeginTouchPosition.x;
	
	if (abs(ytouch1movedistance) > ymoveHeight && abs(xtouch1movedistance) <= xmoveHeight)
	{
		if (ytouch1movedistance > 0)
		{
			self.movebeginTouchPosition = _moveendTouchPosition;
			return KLineTouchEventZoomIn;
		}
		else if (ytouch1movedistance < 0)
		{
			self.movebeginTouchPosition = _moveendTouchPosition;
			return KLineTouchEventZoomOut;
		}
	}
	
	return KLineTouchEventUnknown;
}

- (int)judgeTouchLeftRightOperation
{
	int ypagewidth = self.rtKLine.size.width / 3;
	
	int ytouch1movedistance = _endTouchPosition.x - _startTouchPosition.x;
	

	if (abs(ytouch1movedistance) > ypagewidth)
	{
		if (ytouch1movedistance > 0)
		{
			return KLineTouchEventLeft;
		}
		else if (ytouch1movedistance < 0)
		{
			return KLineTouchEventRight;
		}
	}
	
    return KLineTouchEventUnknown;
}

- (void)zoomInKLine
{
	if (_kItemSize >= 13) return;
	
	_kItemSize += 2;
 
	_kItemWidth = _kItemSize + 2;
	
	[self setNeedsDisplay];
}

- (void)zoomOutKLine
{
	if (_kItemSize <= 1) return;
	
	_kItemSize -= 2;
 
	if (_kItemSize < 1)
	{
		_kItemSize = 1;
	}
	
	_kItemWidth = _kItemSize + 2;
	
    
    /****
	int newCount = 1.5 * [self getNumDraw] + _kIndexOffset;
	int oldcount = [[DataEngine Instance]->stk_kline count];
	
	if ([NetDataComm Instance]->isbusy == NO &&
        newCount >= oldcount &&
        oldcount >= [self getNumDraw])
	{
		[self isShowCursor:NO animate:NO];
		
		int reqCount = newCount - oldcount;
		
		if (reqCount != 0 && [DataEngine Instance]->securitystaticlist.code)
		{
            char *pcode = (char *)[[DataEngine Instance]->securitystaticlist.code UTF8String];
            
			[[DataEngine Instance] requestMargKline:kBeginPosUpdate Num:reqCount];
			
			if (self->m_seltech == DZH_STT_DDX)
			{
                [[DataEngine Instance] requestLevel2DDX:pcode date:[DataEngine Instance]->ddxBeginDate len:reqCount];
			}
			else if (self->m_seltech == DZH_STT_DDY)
			{
                [[DataEngine Instance] requestLevel2DDY:pcode date:[DataEngine Instance]->ddyBeginDate len:reqCount];
			}
			else if (self->m_seltech == DZH_STT_DDZ)
			{
                [[DataEngine Instance] requestLevel2DDZ:pcode date:[DataEngine Instance]->ddzBeginDate len:reqCount];
			}
			else if (self->m_seltech == DZH_STT_BS)
			{
				if ([DataEngine Instance]->stk_kline != nil)
				{
					int count = [[DataEngine Instance]->stk_kline count];
					const char *code = [[DataEngine Instance]->securitystaticlist.code UTF8String];
					if (code) [[DataEngine Instance] requestBSPoint:(char *)code date:0 len:count isMarge:NO type:kBeginPosUpdate];
				}
			}
		}
	}
	
	if (_kIndexOffset > 0 && newCount > oldcount)
	{
		m_floatpanel.hidden = NO;
		
		_kIndexOffset -= newCount-oldcount;
		if (_kIndexOffset < 0) _kIndexOffset = 0;
		
		[self isShowCursor:NO animate:NO];
	}
	****/
     
	[self setNeedsDisplay];
}

- (void)zoomKLine
{
	KLineTouchEvent zoomEvent = [self judgeTouchMoveBigSmallOperation];
	
	if (zoomEvent == KLineTouchEventZoomOut)
	{
		[self zoomOutKLine];
	}
	else if (zoomEvent == KLineTouchEventZoomIn)
	{
		[self zoomInKLine];
	}
}

- (void)moveLeftKLine
{
    if (_kIndexOffset <= 0) {
        _kIndexOffset = 0;
        return;
    }
    
    _kIndexOffset -= 1;
    
    _kIndexOffset = MAX(0, _kIndexOffset);
    
    
}

- (void)moveRightKLine
{
    if ((_kIndexOffset + [self calcVisiableItemCount]) >= self.allKLineItems.count) {
        return;
    }
    
    _kIndexOffset += 1;
    
    _kIndexOffset = MIN(_kIndexOffset, [self calcVisiableMaxOffset]);
    
}

- (void)moveKLine
{
    CGFloat offset = _moveendTwoFingerX - _startTwoFingerX;
    int moveScale = abs(offset);
    if (moveScale >= _kItemSize && _kItemWidth!=0) {
        //CBPrintf("\nmove scale is %d", moveScale);
        
        int steps = floor(moveScale/_kItemWidth);
        for (int i=0; i<steps; i++) {
            if (offset > 0) {
                [self moveLeftKLine];
            }else{
                [self moveRightKLine];
            }
        }
        
        _startTwoFingerX = _moveendTwoFingerX;
        _curSelectIndex = -1;
        
        [self setNeedsDisplay];
        
    }

}

#pragma mark 数据处理
- (void)displayWithKDataDict:(NSDictionary *)dict{
    NSLog(@"dict is %@", dict);
    self.allKLineItems = [dict objectForKey:@"items"];
    self->_maxpricevalue = [[dict objectForKey:@"max"] integerValue];
    self->_minpricevalue = [[dict objectForKey:@"min"] integerValue];
 
    _kIndexOffset = MAX(0, [self calcVisiableMaxOffset]);
    
    [self setNeedsDisplay];
}

- (int)calcVisiableItemCount{
    int showCnt = _kItemWidth==0 ? 0 : ceil(CGRectGetWidth(self.rtKLine)/_kItemWidth);
    showCnt = MAX(MIN(showCnt, self.allKLineItems.count), 0);
    return _visiableItemCount = showCnt;
}

- (int)calcVisiableMaxOffset{
    int maxOffset = (self.allKLineItems.count - [self calcVisiableItemCount] - 1);
    CBPrintf("\nMax aviable index is %d", maxOffset);
    return maxOffset;
}

- (void)calcVisiablePriceSectionWithPos:(int)pos{
    //get current show min&max
    _visiableItemCount = MIN(_visiableItemCount, self.allKLineItems.count-_kIndexOffset);
    for (int i=0; i<_visiableItemCount; i++) {
        CBKLineItem *kItem = [self.allKLineItems objectAtIndex:i+_kIndexOffset];
        if (i==0)
        {
            _visiableMinPrice = kItem->low;
            _visiableMaxPrice = kItem->high;
            
            _visiableMinVolume = kItem->vol;
            _visiableMaxVolume = kItem->vol;
        }
        else
        {
            _visiableMinPrice = MIN(kItem->low, _visiableMinPrice);
            _visiableMaxPrice = MAX(kItem->high, _visiableMaxPrice);
            
            _visiableMinVolume = MIN(kItem->vol, _visiableMinVolume);
            _visiableMaxVolume = MAX(kItem->vol, _visiableMaxVolume);
        }
    }
}

- (void)clacDrawItemBaseData{
    [self calcVisiableItemCount];
    [self calcVisiablePriceSectionWithPos:_kIndexOffset];
}

- (int)calcCurrentSelectIndex:(CGPoint)touchPos{
    CGFloat offsetXInKLine = touchPos.x - CGRectGetMinX(self.rtKLine);
    int selectIndex = _kItemWidth==0 ? 0 : floor(fabsf(offsetXInKLine) / _kItemWidth);
    selectIndex += abs(_kIndexOffset);
    int allItemsCount = self.allKLineItems.count;
    
    if (offsetXInKLine<0 ||
        allItemsCount <= 0  ||
        selectIndex >= allItemsCount) {
        selectIndex = -1;
    }
    
    //CBPrintf("\nSelect index is %d", selectIndex);
    return selectIndex;
}

#pragma mark 绘制
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    //绘制区域标线
    [self drawSomeMarkWithCTX:ctx];

    //计算基本尺度数据
    [self clacDrawItemBaseData];
    
    //绘制k线刻度
    [self drawScalePriceLineAndTextWithCTX:ctx];
    
    //绘制k线项
    [self drawKLineItemWithCTX:ctx];

    //绘制指标刻度
    [self drawScaleTechLineAndTextWithCTX:ctx];
    
    //绘制指标
    [self drawNormWithCTX:ctx];
    
    //绘制指针区域
    [self drawVernierWithCTX:ctx];
    
    //绘制选中k线项信息
    [self drawItemInfoStingWithCTX:ctx];

    //绘制选中指标信息
    [self drawTechInfoStingWithCTX:ctx];
    
    CGContextRestoreGState(ctx);
}

- (void)drawSomeMarkWithCTX:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    CGContextSetRGBFillColor(ctx, 0.95f, 1.0f, 0.95f, 0.8f);
    CGContextFillRect(ctx, self.bounds);
    CGContextSetRGBStrokeColor(ctx, 0.7f, 0.7f, 0.7f, 0.4f);
    CGContextStrokeRect(ctx, self.rtTopText);
    CGContextStrokeRect(ctx, self.rtLeftText);
    CGContextStrokeRect(ctx, self.rtTech);
    CGContextStrokeRect(ctx, self.rtBottomText);
    CGContextRestoreGState(ctx);
    
#ifdef CBDebugKLineDraw
    CGContextSaveGState(ctx);

    const CGFloat *f_color;
    f_color = CGColorGetComponents([UIColor brownColor].CGColor);
    CGContextSetFillColor(ctx, f_color);
    CGContextFillRect(ctx, self.rtTopText);
    
    CGContextSetRGBFillColor(ctx, 1.0f, 0.8f, 1.0f, 1.0f);
    CGContextFillRect(ctx, self.rtKLine);
    
    CGContextSetRGBFillColor(ctx,0.8f, 1.0f, 1.0f, 1.0f);
    CGContextFillRect(ctx, self.rtLeftText);
    
    CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 0.8f, 1.0f);
    CGContextFillRect(ctx, self.rtTech);
    
    CGContextSetRGBFillColor(ctx, 0.8f, 0.8f, 1.0f, 1.0f);
    CGContextFillRect(ctx, self.rtBottomText);
    
    CGContextRestoreGState(ctx);
#endif

}

- (void)drawScalePriceLineAndTextWithCTX:(CGContextRef)ctx{
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, CGRectGetMinX(self.rtKLine), CGRectGetMinY(self.rtKLine));
    CGContextSetRGBStrokeColor(ctx, 0.7f, 0.7f, 0.7f, 0.3f);
    
    int section_cnt = 5;
    CGFloat perH = CGRectGetHeight(self.rtKLine) / (float)section_cnt;

    CGContextBeginPath(ctx);
    const CGFloat dash_lengths[4] = {3.0f, 2.0f, 3.0f, 2.0f};
    CGContextSetLineDash(ctx, 1.0f, dash_lengths, 4);
    for (int i=1; i<section_cnt; i++) {
        CGContextMoveToPoint(ctx, 0.0f, perH*i);
        CGContextAddLineToPoint(ctx, CGRectGetWidth(self.rtKLine), perH*i);
    }

    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);

    //画文字
    CGContextSaveGState(ctx);
    float perSectionPrice = fabsf(_visiableMaxPrice - _visiableMinPrice) / (float)section_cnt;
    CGContextTranslateCTM(ctx, CGRectGetMinX(self.rtLeftText), CGRectGetMinY(self.rtKLine));
    UIFont *txtFont = [UIFont systemFontOfSize:_leftScaleFontSize];
    CGFloat str_draw_width = CGRectGetWidth(self.rtLeftText);
    for (int i=0; i<=section_cnt; i++) {
        NSString *priceString = [NSString stringWithFormat:@"%.2f", _visiableMaxPrice - i*perSectionPrice];

        CGPoint txtPosition = CGPointMake(0, perH*i);
        CGSize fitSize = [priceString sizeWithFont:txtFont
                                          forWidth:str_draw_width
                                     lineBreakMode:NSLineBreakByCharWrapping];
        txtPosition.x = fabsf(str_draw_width - fitSize.width);
        if (i==section_cnt) {
            txtPosition.y -= fitSize.height;
        }else if (i!=0){
            txtPosition.y -= fitSize.height/2;
        }
        
        [priceString drawAtPoint:txtPosition
                        forWidth:str_draw_width
                        withFont:txtFont
                   lineBreakMode:NSLineBreakByCharWrapping];
    }
    CGContextRestoreGState(ctx);
}

- (void)drawScaleTechLineAndTextWithCTX:(CGContextRef)ctx{
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, CGRectGetMinX(self.rtTech), CGRectGetMinY(self.rtTech));
    CGContextSetRGBStrokeColor(ctx, 0.7f, 0.7f, 0.7f, 0.3f);
    
    int section_cnt = 3;
    CGFloat perH = CGRectGetHeight(self.rtTech) / (float)section_cnt;
    
    CGContextBeginPath(ctx);
    const CGFloat dash_lengths[4] = {3.0f, 2.0f, 3.0f, 2.0f};
    CGContextSetLineDash(ctx, 1.0f, dash_lengths, 4);
    for (int i=1; i<section_cnt; i++) {
        CGContextMoveToPoint(ctx, 0.0f, perH*i);
        CGContextAddLineToPoint(ctx, CGRectGetWidth(self.rtKLine), perH*i);
    }
    
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    //画文字
    CGContextSaveGState(ctx);
    int perSectionVolume = abs(_visiableMaxVolume - _visiableMinVolume)/section_cnt;
    CGContextTranslateCTM(ctx, CGRectGetMinX(self.rtLeftText), CGRectGetMinY(self.rtTech));
    UIFont *txtFont = [UIFont systemFontOfSize:_leftScaleFontSize];
    CGFloat str_draw_width = CGRectGetWidth(self.rtLeftText);
    for (int i=0; i<=section_cnt; i++) {
        int iPrice = _visiableMaxVolume - i*perSectionVolume;
        NSString *priceString = nil;
        /**
        if (iPrice > 9999999) {
            priceString = [NSString stringWithFormat:@"%.2f千万", iPrice*0.0000001f];
        }else if (iPrice > 9999){
            priceString = [NSString stringWithFormat:@"%.2f万", iPrice*0.0001f];
        }else{
            priceString = [NSString stringWithFormat:@"%d", iPrice];
        }
         **/
        priceString = [NSString stringWithFormat:@"%d", iPrice];
        
        CGPoint txtPosition = CGPointMake(0, perH*i);
        CGSize fitSize = [priceString sizeWithFont:txtFont
                                          forWidth:str_draw_width
                                     lineBreakMode:NSLineBreakByCharWrapping];
        txtPosition.x = fabsf(str_draw_width - fitSize.width);
        if (i==section_cnt) {
            txtPosition.y -= fitSize.height;
        }else if (i!=0){
            txtPosition.y -= fitSize.height/2;
        }
        
        [priceString drawAtPoint:txtPosition
                        forWidth:str_draw_width
                        withFont:txtFont
                   lineBreakMode:NSLineBreakByCharWrapping];
    }
    CGContextRestoreGState(ctx);
}


- (void)drawVernierWithCTX:(CGContextRef)ctx{
    
    BOOL isNeed = CGRectContainsPoint(self.rtTech, self.moveendTouchPosition);
    isNeed = isNeed || CGRectContainsPoint(self.rtKLine, self.moveendTouchPosition);
    
    if (!isNeed) {
        return;
    }
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, CGRectGetMinX(self.rtKLine), CGRectGetMinY(self.rtKLine));
    CGContextClipToRect(ctx, CGRectMake(0, 0, CGRectGetWidth(self.rtKLine), CGRectGetMaxY(self.rtTech)-CGRectGetMinY(self.rtKLine)));
    const CGFloat poscolor[4] = {0.0f, 0.0f, 0.0f, 1.0f};
    CGContextSetStrokeColor(ctx, poscolor);
    
    CGFloat offsetXInKLine = self.moveendTouchPosition.x - CGRectGetMinX(self.rtKLine);
    int selectIndex = _kItemWidth==0 ? 0 : floor(fabsf(offsetXInKLine) / _kItemWidth);
    CGFloat itemXCenter = _kItemWidth*selectIndex + _kItemWidth/2 +0.5f;
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, itemXCenter, 0);
    CGContextAddLineToPoint(ctx, itemXCenter, CGRectGetMaxY(self.rtTech)-CGRectGetMinY(self.rtKLine));
    
    CGContextMoveToPoint(ctx, 0, self.moveendTouchPosition.y-CGRectGetMinY(self.rtKLine));
    CGContextAddLineToPoint(ctx, CGRectGetWidth(self.rtTech), self.moveendTouchPosition.y-CGRectGetMinY(self.rtKLine));
    
    CGContextStrokePath(ctx);
    
    CGContextRestoreGState(ctx);
}

- (void)drawKLineItemWithCTX:(CGContextRef)ctx{
    
    int showCnt = MIN(_visiableItemCount, self.allKLineItems.count-_kIndexOffset);
    if (!showCnt || !self.allKLineItems) {
        return;
    }
    
    CGFloat perW = self->_kItemWidth;
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, CGRectGetMinX(self.rtKLine), CGRectGetMinY(self.rtKLine));
    CGContextClipToRect(ctx, CGRectMake(0, 0, CGRectGetWidth(self.rtKLine), CGRectGetHeight(self.rtKLine)));
    
    CGFloat scale = CGRectGetHeight(self.rtKLine) / (_visiableMaxPrice - _visiableMinPrice);
    CGFloat lastKStartX = 0.0f;
    
    for (int i=0; i<showCnt; i++) {
        CBKLineItem *kItem = [self.allKLineItems objectAtIndex:i+_kIndexOffset];
        //CBPrintf("\n%d/%d:%s {%.2f/%.2f}", i, showCnt, [[kItem description] UTF8String], _visiableMinPrice, _visiableMaxPrice);
        CGFloat iHighX = lastKStartX + perW/2;
        CGFloat iHighY = scale * (kItem->high - _visiableMinPrice);
        CGFloat iLowY = scale * (kItem->low - _visiableMinPrice);
        CGFloat iOpenY = scale * (kItem->open - _visiableMinPrice);
        CGFloat iCloseY = scale * (kItem->close - _visiableMinPrice);
        
        //draw debug rect;
#ifdef CBDebugKLineDraw
        CGFloat debug_off_y = (i) * 5 % ((int)CGRectGetHeight(self.rtKLine));
        CGContextSetRGBStrokeColor(ctx, 0.7f, 0.7f, 0.7f, 0.3f);
        CGContextStrokeRect(ctx, CGRectMake(lastKStartX, debug_off_y, perW, CGRectGetHeight(self.rtKLine)-debug_off_y*2));
#endif
        
        //set stroke color
        if (kItem->open < kItem->close) {
            CGContextSetStrokeColor(ctx, CGColorGetComponents(self->_sunColor.CGColor));
            CGContextSetFillColor(ctx, CGColorGetComponents(self->_sunColor.CGColor));
        }else{
            CGContextSetStrokeColor(ctx, CGColorGetComponents(self->_moonColor.CGColor));
            CGContextSetFillColor(ctx, CGColorGetComponents(self->_moonColor.CGColor));
        }
        
        //draw k line
        CGFloat k_max_p;
        CGFloat k_min_p;
        if (iOpenY > iCloseY) {
            k_max_p = iOpenY;
            k_min_p = iCloseY;
        }else{
            k_max_p = iCloseY;
            k_min_p = iOpenY;
        }
        CGFloat klineHeight = CGRectGetHeight(self.rtKLine);
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, iHighX, klineHeight-iHighY);
        CGContextAddLineToPoint(ctx, iHighX, klineHeight-k_max_p);
        
        CGContextMoveToPoint(ctx, iHighX, klineHeight-k_min_p);
        CGContextAddLineToPoint(ctx, iHighX, klineHeight-iLowY);
        CGContextStrokePath(ctx);
        
        CGFloat k_height = MAX(0.5f, fabsf(iCloseY-iOpenY));
        CGRect kRect = CGRectMake(lastKStartX+0.5f, klineHeight-MIN(iOpenY, iCloseY)-k_height, perW-1.0f, k_height);
        if (kItem->open < kItem->close) {
            CGContextStrokeRect(ctx, kRect);
            //CGContextFillRect(ctx, kRect);
        }else{
            /*for debug*/ //CGContextStrokeRect(ctx, kRect);
            CGContextFillRect(ctx, kRect);
        }
        
        lastKStartX += perW;
    }
    
    CGContextRestoreGState(ctx);
}

- (void)drawNormWithCTX:(CGContextRef)ctx{
    //成交量
    [self drawNormOfVolumeWithCTX:ctx];
    
    
    
}

- (void)drawNormOfVolumeWithCTX:(CGContextRef)ctx{
    int showCnt = MIN(_visiableItemCount, self.allKLineItems.count-_kIndexOffset);
    if (!showCnt || !self.allKLineItems) {
        return;
    }
    
    CGFloat perW = self->_kItemWidth;
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, CGRectGetMinX(self.rtTech), CGRectGetMinY(self.rtTech));
    CGContextClipToRect(ctx, CGRectMake(0, 0, CGRectGetWidth(self.rtTech), CGRectGetHeight(self.rtTech)));
    
    CGFloat scale = CGRectGetHeight(self.rtTech) / (float)(_visiableMaxVolume - _visiableMinVolume);
    CGFloat lastKStartX = 0.0f;
    
    for (int i=0; i<showCnt; i++) {
        CBKLineItem *kItem = [self.allKLineItems objectAtIndex:i+_kIndexOffset];
        //CGFloat iCenterX = lastKStartX + perW/2;
        CGFloat iVolY = scale * (kItem->vol - _visiableMinVolume);

        //draw debug rect;
#ifdef CBDebugKLineDraw
        CGFloat debug_off_y = (i) * 5 % ((int)CGRectGetHeight(self.rtTech));
        CGContextSetRGBStrokeColor(ctx, 0.7f, 0.7f, 0.7f, 0.3f);
        CGContextStrokeRect(ctx, CGRectMake(lastKStartX, debug_off_y, perW, CGRectGetHeight(self.rtTech)-debug_off_y*2));
#endif
        
        //set stroke color
        if (kItem->open < kItem->close) {
            CGContextSetStrokeColor(ctx, CGColorGetComponents(self->_sunColor.CGColor));
            CGContextSetFillColor(ctx, CGColorGetComponents(self->_sunColor.CGColor));
        }else{
            CGContextSetStrokeColor(ctx, CGColorGetComponents(self->_moonColor.CGColor));
            CGContextSetFillColor(ctx, CGColorGetComponents(self->_moonColor.CGColor));
        }
        
        //draw Vol rect
        CGFloat vol_y = MAX(0.0f, fabsf(CGRectGetHeight(self.rtTech)-iVolY));
        CGRect kRect = CGRectMake(lastKStartX+0.5f, vol_y, perW-1.0f, iVolY);
        if (kItem->open < kItem->close) {
            CGContextStrokeRect(ctx, kRect);
            //CGContextFillRect(ctx, kRect);
        }else{
            /*for debug*/ //CGContextStrokeRect(ctx, kRect);
            CGContextFillRect(ctx, kRect);
        }
        
        lastKStartX += perW;
    }
    
    CGContextRestoreGState(ctx);
}


- (void)drawItemInfoStingWithCTX:(CGContextRef)ctx
{
    if (_curSelectIndex < 0 || _curSelectIndex >= self.allKLineItems.count){
        return;
    }
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, CGRectGetMinX(self.rtTopText), CGRectGetMinY(self.rtTopText));
    CGRect clipRect = CGRectMake(0, 0, CGRectGetWidth(self.rtTopText), CGRectGetHeight(self.rtTopText));
    CGContextClipToRect(ctx, clipRect);
#ifdef CBDebugKLineDraw
    CGContextSetRGBFillColor(ctx, 0.3f, 1.0f, 0.3f, 1.0f);
#else
    CGContextSetRGBFillColor(ctx, 0.1f, 0.5f, 0.1f, 1.0f);
#endif
    UIFont *txtFont = [UIFont systemFontOfSize:_topTextFontSize];
    CBKLineItem *kItem = [self.allKLineItems objectAtIndex:_curSelectIndex];
    
    NSString *kItemInfo = [NSString stringWithFormat:@"%@:{开:%.1f|高:%.1f|低:%.1f|收:%.1f|量:%d}",
                           kItem.strdate,
                           kItem->open,
                           kItem->high,
                           kItem->low,
                           kItem->close,
                           kItem->vol];
    [kItemInfo drawInRect:clipRect withFont:txtFont];
    
    CGContextRestoreGState(ctx);
}

- (void)drawTechInfoStingWithCTX:(CGContextRef)ctx
{
    NSString *techInfo = @"单指查看选中项|双指捏伸缩放|双指左右拖动";
    if (_curSelectIndex < 0 || _curSelectIndex >= self.allKLineItems.count){
        //return;
    }else{
        CBKLineItem *kItem = [self.allKLineItems objectAtIndex:_curSelectIndex];
        techInfo = [NSString stringWithFormat:@"%@:量:%d|额:%d}",
                    techInfo,
                    kItem->vol, kItem->amount];
    }
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, CGRectGetMinX(self.rtBottomText), CGRectGetMinY(self.rtBottomText));
    
    CGRect clipRect = CGRectMake(0, 0, CGRectGetWidth(self.rtBottomText), CGRectGetHeight(self.rtBottomText));
    CGContextClipToRect(ctx, clipRect);
    
    CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 1.0f, 1.0f);
    UIFont *txtFont = [UIFont systemFontOfSize:_topTextFontSize];

    [techInfo drawInRect:clipRect withFont:txtFont];
    
    CGContextRestoreGState(ctx);
}

@end
