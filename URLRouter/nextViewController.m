//
//  nextViewController.m
//  URLRouter
//
//  Created by 李晟 on 2017/9/18.
//  Copyright © 2017年 fanmei_test. All rights reserved.
//

#import "nextViewController.h"
#import "UrlRouter.h"

@interface nextViewController ()

@end

@implementation nextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.title = @"next";
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
- (IBAction)nextPage:(id)sender {
    
    [[UrlRouter sharedInstance] openPresentPage:@"jump" withParams:nil callback:nil animated:true];
}


- (void)dealloc {
    
}

@end
