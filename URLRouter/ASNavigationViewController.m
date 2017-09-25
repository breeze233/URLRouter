//
//  JRONavigationViewController.m
//  MF_JianRong
//
//  Created by chen on 2017/4/28.
//  Copyright © 2017年 gezihuzi. All rights reserved.
//

#import "ASNavigationViewController.h"
#import "UIColor+JROColorToImage.h"
#import <sys/utsname.h>

@interface ASNavigationViewController ()<UIGestureRecognizerDelegate>

@end

@implementation ASNavigationViewController

+ (void)load {


}

- (instancetype)init {
    self = [super init];
    if (self) {
      
        
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    // 设置pop手势的代理
    self.interactivePopGestureRecognizer.delegate = self;
    self.navigationBar.translucent = false;
    [super viewDidLoad];
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([platform isEqualToString:@"iPhone10,3"]){

        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [self.navigationBar setBarTintColor:[UIColor blackColor]];
        //去除nav透明的属性 不改变translucent
        UIImageView * topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 34, [UIScreen mainScreen].bounds.size.width, 88 - 34)];
        topImageView.image = [[UIColor whiteColor] imageWithColor];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:topImageView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(20, 20)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = topImageView.bounds;
        maskLayer.path = maskPath.CGPath;
        topImageView.layer.mask = maskLayer;
        topImageView.clipsToBounds = true;
        [[[self.navigationBar subviews] objectAtIndex:0] addSubview:topImageView];

    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
  
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count != 0 ) {
        [viewController setHidesBottomBarWhenPushed:true];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)clickPop {
    [self popViewControllerAnimated:true];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return self.viewControllers.count > 1;
}

- (UIViewController *)childViewControllerForStatusBarStyle{
    return self.topViewController;
}

@end
