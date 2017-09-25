//
//  NSString+UrlRouter.h
//  Fanmei
//
//  Created by 李晟 on 2017/9/18.
//  Copyright © 2017年 fanmei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UrlRouter)

/**
 *  返回Url中"?"之前的字符串
 */
- (NSString *)urlRouterToBaseUrl;

@end
