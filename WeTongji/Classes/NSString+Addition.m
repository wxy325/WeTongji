//
//  NSString+Addition.m
//  WeTongji
//
//  Created by 紫川 王 on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+Addition.h"

@implementation NSString (Addition)

- (NSDate *)convertToDate {
    NSString *src = self;
    if([src characterAtIndex:src.length - 3] == ':') {
        src = [src stringByReplacingCharactersInRange:NSMakeRange(src.length - 3, 1) withString:@""];
    }
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
    
    NSDate *date = [form dateFromString:src];
    return date;
}

+ (NSString *)monthDayWeekTimeConvertFromDate:(NSDate *)date {
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"MM月dd日"];
    NSString *result = [form stringFromDate:date];
    NSString *month = [result substringWithRange:NSMakeRange(0, 2)];
    result = [result stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:[NSString stringWithFormat:@"%d", month.intValue]];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSWeekdayCalendarUnit;
    comps = [calendar components:unitFlags fromDate:date];
    int weekday = [comps weekday];
    
    NSString *weekdayStr = nil;
    switch (weekday) {
        case 1:
            weekdayStr = @"星期日";
            break;
        case 2:
            weekdayStr = @"星期一";
            break;
        case 3:
            weekdayStr = @"星期二";
            break;
        case 4:
            weekdayStr = @"星期三";
            break;
        case 5:
            weekdayStr = @"星期四";
            break;
        case 6:
            weekdayStr = @"星期五";
            break;
        case 7:
            weekdayStr = @"星期六";
            break;
            
        default:
            break;
    }
        
    result = [NSString stringWithFormat:@"%@(%@) %@", result, weekdayStr, [NSString timeConvertFromDate:date]];
    
    return result;
}

+ (NSString *)timeConvertFromDate:(NSDate *)date {
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"HH:mm"];
    NSString *result = [form stringFromDate:date];
    return result;
}

+ (NSString *)timeConvertFromBeginDate:(NSDate *)begin endDate:(NSDate *)end {
    NSString *timeStr = [NSString monthDayWeekTimeConvertFromDate:begin];
    timeStr = [NSString stringWithFormat:@"%@ - %@", timeStr, [NSString timeConvertFromDate:end]];
    return timeStr;
}

@end