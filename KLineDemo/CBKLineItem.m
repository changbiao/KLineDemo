//
//  CBKLineItem.m
//  KLineDemo
//
//  Created by 常 彪 on 13-11-2.
//  Copyright (c) 2013年 常 彪. All rights reserved.
//

#import "CBKLineItem.h"

@implementation CBKLineItem
@synthesize strdate;
@synthesize stropen;
@synthesize strhigh;
@synthesize strlow;
@synthesize strclose;
@synthesize strvol;
@synthesize stramount;
@synthesize strposition;
@synthesize strincstock;
@synthesize strzf;
@synthesize strhs;
@synthesize strddxvalue;
@synthesize strddyvalue;
@synthesize strddzvalue;
@synthesize strsuplvalue;
@synthesize streropen;
@synthesize strerhigh;
@synthesize strerlow;
@synthesize strerclose;
@synthesize strerzf;
@synthesize strervol;

- (NSString *)strdate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    NSDate *aDate = [formatter dateFromString:[NSString stringWithFormat:@"%d", self->date]];
    formatter.dateFormat = @"yyyy年MM月dd";
    NSString *dateStr = [formatter stringFromDate:aDate];
    [formatter release];
    return dateStr;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@:{open:%.2f|high:%.2f|low:%.2f|close:%.2f|vol:%d|amount:%d}",
            NSStringFromClass(self.class),
            self->open, self->high, self->low, self->close,
            self->vol, self->amount];
}

@end
