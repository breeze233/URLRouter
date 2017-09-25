//
//  NSString+UrlRouter.m
//  Fanmei
//
//  Created by 李晟 on 2017/9/18.
//  Copyright © 2017年 fanmei. All rights reserved.
//

#import "NSString+UrlRouter.h"

@implementation NSString (UrlRouter)

- (NSString *)urlRouterToBaseUrl {
    NSRange rangeOfString = [self rangeOfString:@"?"];
    if (rangeOfString.length > 0) {
        return [self substringToIndex:rangeOfString.location];
    }
    else {
        return self;
    }
}

@end
