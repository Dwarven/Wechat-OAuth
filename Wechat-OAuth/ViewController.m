//
//  ViewController.m
//  Wechat-OAuth
//
//  Created by Dwarven on 15/7/28.
//  Copyright (c) 2015年 Dwarven. All rights reserved.
//

#import "ViewController.h"
#import "WechatAccess.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    if ([WechatAccess isWechatAppInstalled]) {
        [[WechatAccess defaultAccess] login:^(BOOL succeeded, id object) {
            [_textField setText:[NSString stringWithFormat:@"%@",object]];
        }];
    } else {
        [_textField setText:@"Wechat not installed!"];
    }
}

@end
