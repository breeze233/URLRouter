//
//  UIColor+JROColorToImage.h
//  MF_JianRong
//
//  Created by chen on 2017/4/28.
//  Copyright © 2017年 gezihuzi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (JROColorToImage)
/**
 使用颜色创建一个对应大小的图片
 @return 创建的图片
 */
- (UIImage * _Nullable)imageWithColor ;
@end
