//
//  FMPagesConfiguration.m
//  Fanmei
//
//  Created by 李晟 on 2017/9/18.
//  Copyright © 2017年 fanmei. All rights reserved.
//

#import "ASPagesConfiguration.h"
#import "UrlRouter.h"

@implementation ASPagesConfiguration

+ (void)setUp {
    [self loadConfigAndRegWithFileName:@"router_home"];
}

+ (void)loadConfigAndRegWithFileName:(NSString *)fileName {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSDictionary *root = [[NSDictionary alloc] initWithContentsOfFile:path];
        if (root && [root isKindOfClass:[NSDictionary class]]) {
            [root enumerateKeysAndObjectsUsingBlock:^(NSString  *pageName, NSDictionary *pageConfig, BOOL * _Nonnull stop) {
                [self registerPage:pageName withPageConfig:pageConfig];
            }];
        }
    }
}


+ (void)registerPage:(NSString *)pageName withPageConfig:(NSDictionary *)pageConfig {
    if (pageName &&
        [pageName isKindOfClass:[NSString class]] &&
        pageConfig &&
        [pageConfig isKindOfClass:[NSDictionary class]]) {
        
        NSString *className = pageConfig[@"class_name"];
        if (className && [className isKindOfClass:[NSString class]]) {
            if ([className hasPrefix:@"#"]) {
                className = [className substringFromIndex:1];
            }
            [[UrlRouter sharedInstance] registerPage:pageName forViewControllerClass:NSClassFromString(className)];
        }
    }
}

@end
