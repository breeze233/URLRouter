//
//  UIColor+JROColorToImage.m
//  MF_JianRong
//
//  Created by chen on 2017/4/28.
//  Copyright © 2017年 gezihuzi. All rights reserved.
//

#import "UIColor+JROColorToImage.h"

@implementation UIColor (JROColorToImage)
- (UIImage * _Nullable)imageWithColor {
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, CGRectMake(0, 0, 1, 1));
    [self set];
    CGContextFillPath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
