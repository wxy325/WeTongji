//
//  WTTableViewHeaderFooterFactory.h
//  WeTongji
//
//  Created by 紫川 王 on 12-5-12.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#define TABLE_VIEW_CELL_HEIGHT 44

#import <Foundation/Foundation.h>

@interface WTTableViewHeaderFooterFactory : NSObject

+ (UIView *)getWideWTTableViewHeader;
+ (UIView *)getWideWTTableViewEmptyFooter;
+ (UIView *)getWideWTTableViewFooterWithBlank;
+ (UIView *)getWideWTTableViewFooterWithNoDataHint;
+ (UIView *)getWideWTTableViewFooterWithHint:(NSString *)hint;

@end
