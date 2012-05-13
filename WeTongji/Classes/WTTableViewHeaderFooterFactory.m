
//
//  WTTableViewHeaderFooterFactory.m
//  WeTongji
//
//  Created by 紫川 王 on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WTTableViewHeaderFooterFactory.h"

@implementation WTTableViewHeaderFooterFactory

+ (UIView *)getWideWTTableViewHeader {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paper_wide_header.png"]];
    headerImageView.center = CGPointMake(160, 10);
    UIImageView *lineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paper_wide_single_line.png"]];
    lineImageView.center = CGPointMake(160, 10);
    lineImageView.center = headerImageView.center;
    [headerView addSubview:headerImageView];
    [headerView addSubview:lineImageView];
    return headerView;
}

+ (UIView *)getWideWTTableViewEmptyFooter {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    UIImageView *footerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paper_wide_footer.png"]];
    footerImageView.center = CGPointMake(160, 20);
    [footerView addSubview:footerImageView];
    return footerView;
}

+ (UIView *)getWideWTTableViewEmptyFooterWithHint {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
    UIImageView *footerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paper_wide_footer.png"]];
    footerImageView.center = CGPointMake(160, 60);
    UIImageView *mainImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paper_wide_main.png"]];
    mainImageView.center = CGPointMake(160, 20);
    UIImageView *lineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paper_wide_single_line.png"]];
    lineImageView.center = CGPointMake(160, 20);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:14.0f];
    label.textColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.text = @"无内容。";
    label.textAlignment = UITextAlignmentCenter;
    [mainImageView addSubview:label];
    
    [footerView addSubview:footerImageView];
    [footerView addSubview:mainImageView];
    [footerView addSubview:lineImageView];
    return footerView;
}

@end