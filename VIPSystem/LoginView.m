//
//  LoginView.m
//  VIPSystem
//
//  Created by Channe Sun on 2017/10/26.
//  Copyright © 2017年 Omnivision. All rights reserved.
//

#import "LoginView.h"

@interface LoginView(){
    QMUITextField *pwdTF;
    QMUITextField *confirmTF;
    QMUIButton *okBtn;
}

@end

@implementation LoginView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    return self;
}

- (instancetype)init{
    if (self = [super init]) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    __weak typeof(self)weakSelf = self;
    self.backgroundColor = UIColorGray9;
    pwdTF = [QMUITextField new];
    [self addSubview:pwdTF];
    [pwdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(15);
        make.right.equalTo(weakSelf).offset(-15);
        make.top.equalTo(weakSelf).offset(20 + 64);
        make.height.equalTo(@(GLOBALE_CELL_HEIGHT));
    }];
    pwdTF.placeholder = @"请输入密码";
    pwdTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    pwdTF.secureTextEntry = YES;
    
    okBtn = [QMUIButton new];
    [self addSubview:okBtn];
    [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(pwdTF);
        make.top.equalTo(pwdTF.mas_bottom).offset(20);
        make.height.equalTo(@(GLOBALE_CELL_HEIGHT));
    }];
    [okBtn setTitle:@"确认" forState:UIControlStateNormal];
    [okBtn setTitleColor:UIColorWhite forState:UIControlStateNormal];
    [okBtn setBackgroundColor:[QDThemeManager sharedInstance].currentTheme.themeTintColor];
    [okBtn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    
    [pwdTF becomeFirstResponder];
}

- (void)click{
    NSString *password = [PassWordTool readPassword];
    if ([pwdTF.text isEqualToString:password]) {
        [GlobalObj sharedInstance].type = Authority_Admin;
        [GlobalObj sharedInstance].lastInDate = [NSDate date];
        [QMUITips showSucceed:@"管理员" inView:self hideAfterDelay:1.5];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
        return;
    }
    else{
        password = [PDKeyChain keyChainLoad];
        if ([pwdTF.text isEqualToString:password]) {
            [GlobalObj sharedInstance].type = Authority_CommonUser;
            [GlobalObj sharedInstance].lastInDate = [NSDate date];
            [QMUITips showSucceed:@"普通用户" inView:self hideAfterDelay:1.5];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeFromSuperview];
            });
            return;
        }
        [QMUITips showError:@"密码错误" inView:self hideAfterDelay:1.5];
    }
}

@end
