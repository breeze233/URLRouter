//
//  UrlRouter.m
//  URLRouter
//
//  Created by 李晟 on 2017/9/18.
//  Copyright © 2017年 fanmei. All rights reserved.
//

#import "UrlRouter.h"
#import "UIViewController+CurrentVC.h"
#import "NSString+UrlRouter.h"

@interface UrlRouter ()
/**
 Configurations of router.
 */
@property (nonatomic, strong) UrlRouterConfig *config;

/**
 Instances of root container, kind of UINavigationController, must not nil after startup.
 */
@property (nonatomic, strong) UINavigationController *navigationController;

/**
 Instances of sub root container, kind of UITabBarController, may nil if config.mode is UrlRouterContainerModeOnlyNavigation.
 */
@property (nonatomic, strong) UITabBarController *tabBarController;

/**
 Supported schemes, including user defined native scheme.
 */
@property (nonatomic, strong) NSMutableArray *supportedSchemes;

/**
 Meta of native pages, key is page name, kind of NSString, value is view controller class, kind of NSString.
 */
@property (nonatomic, strong) NSMutableDictionary *nativePages;

@end


@implementation UrlRouter
#pragma mark - shared
//全局变量
static id _instance = nil;
//单例方法
+(instancetype)sharedInstance{
    return [[self alloc] init];
}
//初始化方法
- (instancetype)init{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
        self.supportedSchemes = [[NSMutableArray alloc] init];
        self.nativePages = [[NSMutableDictionary alloc] init];
    });
    return _instance;
}

////alloc会调用allocWithZone:
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
  
    });
    return _instance;
}

- (Class)classForPageName:(NSString *)pageName {
    if (pageName.length > 0) {
        NSString *pageClassName = self.nativePages[pageName];
        if (pageClassName.length > 0) {
            Class pageClass = NSClassFromString(pageClassName);
            return pageClass;
        }
    }
    return nil;
}
#pragma mark - Open native pages by name

- (void)openPage:(NSString *)pageName {
    [self openPage:pageName withParams:nil callback:nil animated:YES];
}

- (BOOL)openPage:(NSString *)pageName withParams:(NSDictionary * __nullable)params callback:(ASUrlPopedCallback __nullable)callback animated:(BOOL)animated {
    
    if (![UIViewController currentViewController].navigationController) return NO;
    self.navigationController = [UIViewController currentViewController].navigationController;
    
    Class cls = [self classForPageName:pageName];
    if (!cls) return NO;
    
    UIViewController *vc = [[cls alloc] init];
    vc.vcPageName = pageName;
    [self configVCBeforePush:vc params:params callback:callback];
    [self.navigationController pushViewController:vc animated:animated];
    
    return YES;
}

- (BOOL)openPresentPage:(NSString * __nonnull)pageName withParams:(NSDictionary * __nullable)params callback:(ASUrlPopedCallback __nullable)callback animated:(BOOL)animated {
   
    if (![UIViewController currentViewController]) return NO;
    
    Class cls = [self classForPageName:pageName];
    if (!cls) return NO;
    
    UIViewController *vc = [[cls alloc] init];
    vc.vcPageName = pageName;
    
    [self configVCBeforePush:vc params:params callback:callback];
    [[UIViewController currentViewController] presentViewController:vc animated:true completion:nil];
    return YES;
}

- (void)configVCBeforePush:(UIViewController *)vc params:(NSDictionary *)params callback:(ASUrlPopedCallback)callback {
    vc.urlCallback = callback;
    vc.urlParams = params;
    [vc parseInputParams];
    vc.fromPage = self.navigationController.topViewController.vcPageName;
}


#pragma mark - Setup
// 注册 需要路由打开的页面
- (void)registerPage:(NSString *)pageName forViewControllerClass:(Class)clazz{
    NSString *className = NSStringFromClass(clazz);
    if ([self checkValidOfPageName:pageName className:className]) {
        self.nativePages[pageName] = className;
    }
}

- (BOOL)checkValidOfPageName:(NSString *)pageName className:(NSString *)className {
    if (pageName.length == 0 || className.length == 0) {
        return NO;
    }
    
    return YES;
}

- (UIViewController *)startupWithConfig:(UrlRouterConfig *)config andInitialPages:(NSArray *)pageNames {
    [self.supportedSchemes removeAllObjects];
    
    if (config.webContainerClass) {
        [self.supportedSchemes addObject:@"http"];
        [self.supportedSchemes addObject:@"https"];
    }
    
    if (config.nativeUrlScheme.length > 0) {
        [self.supportedSchemes addObject:config.nativeUrlScheme];
    }
    
    self.config = config;
    return [self startupWithInitialPages:pageNames];
}

- (UIViewController *)startupWithInitialPages:(NSArray *)pageNames {
#if defined(DEBUG) && DEBUG
    NSLog(@"Registered %@ pages total.", @(self.nativePages.count));
    [self.nativePages enumerateKeysAndObjectsUsingBlock:^(NSString *pageName, NSString *className, BOOL * _Nonnull stop) {
        NSLog(@"Page(%@) registered with class [%@].", pageName, className);
    }];
#endif
    
    if (!pageNames) {
        return nil;
    }
    
    if (self.config.mode == UrlRouterContainerModeOnlyNavigation) {
        Class initialPageClass = nil;
        NSString *pageName = nil;
        if (pageNames.count > 0) {
            pageName = pageNames.firstObject;
            initialPageClass = [self classForPageName:pageName];
        }
        
        if (self.config.navigationControllerClass && initialPageClass) {
            UIViewController *contentVC = [[initialPageClass alloc] init];
            contentVC.vcPageName = pageName;
            self.navigationController = [[self.config.navigationControllerClass alloc] initWithRootViewController:contentVC];
            return self.navigationController;
        }
    } else if (self.config.mode == UrlRouterContainerModeNavigationAndTabBar) {
        
        if (self.config.navigationControllerClass && self.config.tabBarControllerClass) {
            self.tabBarController = [[self.config.tabBarControllerClass alloc] init];
            
            NSMutableArray *contentVCs = [[NSMutableArray alloc] init];
            if (pageNames.count > 0) {
                [pageNames enumerateObjectsUsingBlock:^(NSString *pageName, NSUInteger idx, BOOL * _Nonnull stop) {
                    Class pageClass = [self classForPageName:pageName];
                    if (pageClass) {
                        UIViewController * viewcController = [[pageClass alloc] init];
                        viewcController.vcPageName = pageName;
                        
                        UINavigationController * navigationController = [[self.config.navigationControllerClass alloc] initWithRootViewController:viewcController];
                        [contentVCs addObject:navigationController];
                        
                    }
                }];
            }
            self.tabBarController.viewControllers = contentVCs;
            return self.tabBarController;
        }
    }
    
    return nil;
}

#pragma mark - Open pages by url
- (BOOL)openH5Url:(NSURL *)url{
    return [self openH5Url:url withParams:nil animated:true withCallback:nil];
}

- (BOOL)openH5Url:(NSURL *)url withParams:(NSDictionary *)params animated:(BOOL)animated withCallback:(ASUrlPopedCallback)callback {
    
    self.navigationController = [UIViewController currentViewController].navigationController;
    
    if (self.config.webContainerClass && self.navigationController) {
        
        UIViewController *vc = [[self.config.webContainerClass alloc] init];
        vc.vcPageName = [[url absoluteString] urlRouterToBaseUrl];
        vc.h5Url = [url absoluteString];
        [self configVCBeforePush:vc params:params callback:callback];
        [self.navigationController pushViewController:vc animated:animated];
        
        return YES;
    }
    
    return NO;
}
@end
