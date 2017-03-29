//
//  ViewController.m
//  LXAlertView
//
//  Created by liuxu on 2017/3/29.
//  Copyright © 2017年 lx. All rights reserved.
//

#import "ViewController.h"
#import "LXAlertView.h"

@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"横向" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(100, 200, 150, 20);
    [btn addTarget:self action:@selector(clickBtn1:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn2= [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:@"纵向" forState:UIControlStateNormal];
    btn2.backgroundColor = [UIColor redColor];
    btn2.frame = CGRectMake(100, 250, 150, 20);
    [btn2 addTarget:self action:@selector(clickBtn2:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *btn3= [UIButton buttonWithType:UIButtonTypeCustom];
    [btn3 setTitle:@"自定义" forState:UIControlStateNormal];
    btn3.backgroundColor = [UIColor redColor];
    btn3.frame = CGRectMake(100, 300, 150, 20);
    [btn3 addTarget:self action:@selector(clickBtn3:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn3];
    [self.view addSubview:btn2];
    [self.view addSubview:btn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickBtn1:(UIButton *)btn {
    LXAlertView *alert = [[LXAlertView alloc] initWithTitle:@"温馨提示" message:@"这就是alert测试" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定1", @"确定2", nil];
    [alert showWithCompletionBlock:^{
        NSLog(@"展示完成");
    } dismissBlock:^(LXAlertViewStruct result) {
        NSLog(@"alertViewTag:%li, buttonIndex:%li", result.alertTag, result.buttonIndex);
    }];
}

- (void)clickBtn2:(UIButton *)btn {
    LXAlertView *alert = [[LXAlertView alloc] initWithTitle:@"温馨提示" message:@"这就是alert测试" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
    alert.cancelButtonColor = [UIColor redColor];
    alert.cancelButtonTitleColor = [UIColor yellowColor];
    alert.cancelButtonBorderColor = [UIColor orangeColor];
    
    alert.otherButtonColor= [UIColor blueColor];
    alert.otherButtonTitleColor = [UIColor whiteColor];
    alert.buttonLayout = LXAlertViewButtonLayoutVertical;
    [alert showWithCompletionBlock:^{
        NSLog(@"展示完成");
    } dismissBlock:^(LXAlertViewStruct result) {
        NSLog(@"alertViewTag:%li, buttonIndex:%li", result.alertTag, result.buttonIndex);
    }];
}

- (void)clickBtn3:(UIButton *)btn {
    LXAlertView *alert = [[LXAlertView alloc] initWithTitle:@"温馨提示" message:@"这就是alert测试" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
    alert.cancelButtonColor = [UIColor redColor];
    alert.cancelButtonTitleColor = [UIColor yellowColor];
    alert.cancelButtonBorderColor = [UIColor orangeColor];
    
    alert.otherButtonColor= [UIColor blueColor];
    alert.otherButtonTitleColor = [UIColor whiteColor];
    alert.buttonLayout = LXAlertViewButtonLayoutVertical;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, alert.contentViewWidth, 100)];
    contentView.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, alert.contentViewWidth, 20)];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15.0];
    label.text = @"contentview";
    [contentView addSubview:label];
    
    [alert setContentView:contentView];
    
    [alert showWithCompletionBlock:^{
        NSLog(@"展示完成");
    } dismissBlock:^(LXAlertViewStruct result) {
        NSLog(@"alertViewTag:%li, buttonIndex:%li", result.alertTag, result.buttonIndex);
    }];
}

@end
