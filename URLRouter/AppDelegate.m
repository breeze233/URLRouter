//
//  AppDelegate.m
//  URLRouter
//
//  Created by fanmei_test on 2017/9/18.
//  Copyright © 2017年 fanmei_test. All rights reserved.
//

#import "AppDelegate.h"
#import "UrlRouter.h"
#import "ASPagesConfiguration.h"
#import "UrlRouterConfig.h"
#import "ASTabBarController.h"
#import "WKWebViewController.h"
#import "ASNavigationViewController.h"

/**
 *  Native页面Url的Scheme
 */
#define URL_ROUTER_LOCAL_SCHEME (@"fanmei")
#define URL_ROUTER_LOCAL_HOST (@"fanmeihost")


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ASPagesConfiguration setUp];
    
    UrlRouterConfig *config = [UrlRouterConfig new];
    config.mode = UrlRouterContainerModeNavigationAndTabBar;
    config.navigationControllerClass = ASNavigationViewController.class;
    config.tabBarControllerClass = ASTabBarController.class;
    config.webContainerClass = WKWebViewController.class;
    config.nativeUrlScheme = URL_ROUTER_LOCAL_SCHEME;
    config.nativeUrlHostName = URL_ROUTER_LOCAL_HOST;
    
    // 1. setup windows
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.windowLevel = UIWindowLevelNormal;
    self.window.rootViewController = [[UrlRouter sharedInstance] startupWithConfig:config andInitialPages:@[@"home", @"next"]];
    
    
    [self.window makeKeyAndVisible];
    return YES;
}



@end
