//
//  FMTabBarController.m
//  Fanmei
//
//  Created by 李传格 on 2017/6/20.
//  Copyright © 2017年 Fanmei. All rights reserved.
//

#import "ASTabBarController.h"


@interface ASTabBarController ()

@end

@implementation ASTabBarController

- (instancetype)init {
    if (self = [super init]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
//        self.tabBar.translucent = NO;
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:123/255.0 green:123/255.0 blue:123/255.0 alpha:1.0]} forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]} forState:UIControlStateSelected];
        self.tabBar.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1.0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldUseNavigationBar {
    return NO;
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    [viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self setupNavigationBarOfViewController:obj];
    }];
    [super setViewControllers:viewControllers];
}

- (void)setupNavigationBarOfViewController:(UIViewController *)viewController {
    
    viewController = (UINavigationController *)viewController;
    //    viewController.
    if ([NSStringFromClass([viewController.childViewControllers.firstObject class]) isEqualToString:@"homeViewController"]) {
        viewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页+" image:nil selectedImage:nil];
        
    }else if ([NSStringFromClass([viewController.childViewControllers.firstObject class]) isEqualToString:@"nextViewController"]) {
        viewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"next+" image:nil selectedImage:nil];
    }
}

@end
