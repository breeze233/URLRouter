//
//  jumpViewController.m
//  URLRouter
//
//  Created by 李晟 on 2017/9/18.
//  Copyright © 2017年 fanmei_test. All rights reserved.
//

#import "jumpViewController.h"
#import "UIViewController+UrlRouterPrivate.h"
#import "UrlRouter.h"

@interface jumpViewController ()

@property (weak, nonatomic) IBOutlet UIButton *url;

@property (weak, nonatomic) IBOutlet UIButton *name;

@end

@implementation jumpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"下一页";
    
    [self.url setTitle:self.urlParams[@"url"] forState:UIControlStateNormal];
    [self.name setTitle:self.urlParams[@"name"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc{
    
    if (self.urlCallback) {
        NSDictionary *params = @{@"status" : @"关闭了页面。。。"};
        self.urlCallback(params);
    }
}
- (IBAction)dissMissClick:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)clickButton:(id)sender {
    
    
    [[UrlRouter sharedInstance] openH5Url:[NSURL URLWithString:@"https://www.baidu.com/"] withParams:nil animated:YES withCallback:^(NSDictionary * _Nullable result) {
        
    }];
    
    
    
    
}

@end
