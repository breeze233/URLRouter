//
//  homeViewController.m
//  URLRouter
//
//  Created by 李晟 on 2017/9/18.
//  Copyright © 2017年 fanmei_test. All rights reserved.
//

#import "homeViewController.h"
#import "UrlRouter.h"

@interface homeViewController ()

@end

@implementation homeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)jump:(id)sender {
    
    NSDictionary *params = @{@"url" : @"http://ww.baidu.com",
                             @"name" : @"百度一下"};
    [[UrlRouter sharedInstance] openPage:@"jump" withParams:params callback:^(NSDictionary * _Nullable result) {
        
        NSLog(@"%@",result);
        
    } animated:true];
    
}

@end
