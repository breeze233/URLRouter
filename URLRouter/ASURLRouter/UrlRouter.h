//
//  UrlRouter.h
//  URLRouter
//
//  Created by 李晟 on 2017/9/18.
//  Copyright © 2017年 fanmei_test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIViewController+UrlRouterPrivate.h"
#import "UrlRouterConfig.h"
#import "ASTabBarController.h"

@interface UrlRouter : NSObject


+ (instancetype __nonnull)sharedInstance;

/**
 Register native page meta.
 
 @param pageName page name
 @param clazz view controller class meta
 */
- (void)registerPage:(NSString * __nonnull)pageName forViewControllerClass:(Class __nonnull) clazz;

/**
 Start up
 
 @param config configurations
 @param pageNames intial pages will created auto by the names, and names must registered.
 @return instance of root container
 */
- (UIViewController * __nonnull)startupWithConfig:(UrlRouterConfig * __nonnull)config andInitialPages:(NSArray * __nonnull)pageNames;

#pragma mark - Container instance

@property (nullable, nonatomic, strong, readonly) UINavigationController *navigationController;

@property (nullable, nonatomic, strong, readonly) UITabBarController *tabBarController;


- (void)openPage:(NSString * __nonnull)pageName;

- (BOOL)openPage:(NSString * __nonnull)pageName withParams:(NSDictionary * __nullable)params callback:(ASUrlPopedCallback __nullable)callback animated:(BOOL)animated;

- (BOOL)openPresentPage:(NSString * __nonnull)pageName withParams:(NSDictionary * __nullable)params callback:(ASUrlPopedCallback __nullable)callback animated:(BOOL)animated;

- (BOOL)openH5Url:(NSURL * __nonnull)url;

- (BOOL)openH5Url:(NSURL * __nonnull)url withParams:(NSDictionary * __nullable)params animated:(BOOL)animated withCallback:(ASUrlPopedCallback __nullable)callback;
@end
