//
//  SecurityViewController.m
//  VIPSystem
//
//  Created by Channe Sun on 2017/10/26.
//  Copyright © 2017年 Omnivision. All rights reserved.
//

#import "SecurityViewController.h"

@interface SecurityViewController (){
    QMUITextField *old;
    QMUITextField *new;
    QMUITextField *new1;
    QMUITextField *sub;
    QMUIButton *okBtn;
    QMUIButton *changeBtn;
}

@end

@implementation SecurityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleView.title = @"隐私权限";
    [self setupView];
}

- (void)setupView{
    __weak typeof(self)weakSelf = self;
    self.view.backgroundColor = UIColorGray9;
    old = [QMUITextField new];
    [self.view addSubview:old];
    [old mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(15);
        make.right.equalTo(weakSelf.view).offset(-15);
        make.top.equalTo(weakSelf.view).offset(10 + 64);
        make.height.equalTo(@44);
    }];
    old.placeholder = @"请输入旧密码";
    
    new = [QMUITextField new];
    [self.view addSubview:new];
    [new mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(old);
        make.top.equalTo(old.mas_bottom).offset(10);
        make.height.equalTo(@44);
    }];
    new.placeholder = @"请输入新密码";
    
    new1 = [QMUITextField new];
    [self.view addSubview:new1];
    [new1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(new);
        make.top.equalTo(new.mas_bottom).offset(10);
        make.height.equalTo(@44);
    }];
    new1.placeholder = @"请确认新密码";
    
    sub = [QMUITextField new];
    [self.view addSubview:sub];
    [sub mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(new1);
        make.top.equalTo(new1.mas_bottom).offset(10);
        make.height.equalTo(@44);
    }];
    sub.placeholder = @"请输入子密码";
    
    okBtn = [QMUIButton new];
    [self.view addSubview:okBtn];
    [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(sub);
        make.top.equalTo(sub.mas_bottom).offset(10);
        make.height.equalTo(@44);
    }];
    [okBtn setTitleColor:UIColorWhite forState:UIControlStateNormal];
    [okBtn setTitle:@"确认" forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
    
    changeBtn = [QMUIButton new];
    [self.view addSubview:changeBtn];
    [changeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(okBtn);
        make.top.equalTo(okBtn.mas_bottom).offset(10);
        make.height.equalTo(@44);
    }];
    [changeBtn setTitleColor:UIColorWhite forState:UIControlStateNormal];
    [changeBtn setTitle:@"修改权限" forState:UIControlStateNormal];
    [changeBtn addTarget:self action:@selector(changeAction) forControlEvents:UIControlEventTouchUpInside];
    
    old.backgroundColor = UIColorWhite;
    new.backgroundColor = UIColorWhite;
    new1.backgroundColor = UIColorWhite;
    sub.backgroundColor = UIColorWhite;
    okBtn.backgroundColor = [QDThemeManager sharedInstance].currentTheme.themeTintColor;
    changeBtn.backgroundColor = [QDThemeManager sharedInstance].currentTheme.themeTintColor;
    
    [self setProperty:old];
    [self setProperty:new];
    [self setProperty:new1];
    [self setProperty:sub];
}

- (void)setProperty:(QMUITextField *)sender{
    sender.clearButtonMode = UITextFieldViewModeWhileEditing;
    sender.secureTextEntry = YES;
}

- (void)changeAction{
    NSString *oldPassword = [PassWordTool readPassword];
    if (![old.text isEqualToString:oldPassword]) {
        [QMUITips showError:@"旧密码错误" inView:self.view hideAfterDelay:1.5];
    }
    else{
        if ([GlobalObj sharedInstance].type == Authority_Admin) {
            [GlobalObj sharedInstance].type = Authority_CommonUser;
            [QMUITips showSucceed:@"已修改为普通用户" inView:self.view hideAfterDelay:1.5];
        }
        else{
            [GlobalObj sharedInstance].type = Authority_Admin;
            [QMUITips showSucceed:@"已修改为管理员" inView:self.view hideAfterDelay:1.5];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

- (void)okAction{
    if (new.text.length <= 0 && sub.text.length <=0) {
        [QMUITips showError:@"新密码不能为空" inView:self.view hideAfterDelay:1.5];
        return;
    }
    if (![new1.text isEqualToString:new.text]) {
        [QMUITips showError:@"两次密码不一致" inView:self.view hideAfterDelay:1.5];
        return;
    }
    NSString *oldPassword = [PassWordTool readPassword];
    
    if (![old.text isEqualToString:oldPassword] && !old.text && !oldPassword) {
        [QMUITips showError:@"旧密码错误" inView:self.view hideAfterDelay:1.5];
        return;
    }
    else{
        [PassWordTool saveUsernamePassWord:@"suncheng" pwd:new.text];
        if (sub.text.length > 0) {
            [PDKeyChain keyChainSave:sub.text];
        }
        [QMUITips showSucceed:@"修改成功" inView:self.view hideAfterDelay:1.5];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
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

@end
