//
//  AddRecordViewController.m
//  VIPSystem
//
//  Created by Channe Sun on 2017/10/25.
//  Copyright © 2017年 Omnivision. All rights reserved.
//

#import "AddRecordViewController.h"

@interface AddRecordViewController ()
{
    QMUIButton *typeBtn;
    QMUITextField *moneyTF;
    QMUIButton *discountBtn;
    QMUITextField *discountTF;
    QMUIButton *confirmBtn;
    QMUIPopupMenuView *menuView;
    CGFloat finalMoney;
    MemObj *globalObj;
}

@end

@implementation AddRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleView.title = @"添加消费记录";
    self.view.backgroundColor = UIColorGray9;
    [self getUserInfo];
    [self setupView];
}

- (void)getUserInfo{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *personArray = [WHCSqlite query:[MemObj class]
                                          where:[NSString stringWithFormat:@"memID = %ld",self.userID]];
        if (personArray.count > 0) {
            globalObj = (MemObj *)personArray[0];
        }
    });
}

- (void)setupView{
    __weak typeof(self)weakSelf = self;
    typeBtn = [QMUIButton new];
    [self.view addSubview:typeBtn];
    [typeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(15);
        make.right.equalTo(weakSelf.view).offset(-15);
        make.top.equalTo(weakSelf.view).offset(20 + 64);
        make.height.equalTo(@(GLOBALE_CELL_HEIGHT));
    }];
    [typeBtn setTitle:@"-" forState:UIControlStateNormal];
    [typeBtn setTitle:@"+" forState:UIControlStateSelected];
    [typeBtn setTitleColor:UIColorWhite forState:UIControlStateNormal];
    [typeBtn setTitleColor:UIColorWhite forState:UIControlStateSelected];
    typeBtn.titleLabel.font = [UIFont systemFontOfSize:60];
    
    moneyTF = [QMUITextField new];
    [self.view addSubview:moneyTF];
    [moneyTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(typeBtn);
        make.top.equalTo(typeBtn.mas_bottom).offset(20);
        make.height.equalTo(@(GLOBALE_CELL_HEIGHT));
    }];
    moneyTF.placeholder = @"输入金额";
    moneyTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    moneyTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    discountBtn = [QMUIButton new];
    [self.view addSubview:discountBtn];
    [discountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(typeBtn);
        make.top.equalTo(moneyTF.mas_bottom).offset(20);
        make.height.equalTo(@(GLOBALE_CELL_HEIGHT));
    }];
    [discountBtn setTitleColor:UIColorWhite forState:UIControlStateNormal];
    [discountBtn setTitle:@"不打折" forState:UIControlStateNormal];
    [discountBtn addTarget:self action:@selector(showDiscountMenu) forControlEvents:UIControlEventTouchUpInside];
    
    discountTF = [QMUITextField new];
    [self.view addSubview:discountTF];
    [discountTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(typeBtn);
        make.top.equalTo(discountBtn.mas_bottom).offset(20);
        make.height.equalTo(@(GLOBALE_CELL_HEIGHT));
    }];
    discountTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    discountTF.placeholder = @"输入折扣，例如：9.5（代表九五折）";
    discountTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (typeBtn.selected) {
        discountTF.placeholder = @"请输入优惠金额";
    }
    
    confirmBtn = [QMUIButton new];
    [self.view addSubview:confirmBtn];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(typeBtn);
        make.top.equalTo(discountTF.mas_bottom).offset(20);
        make.height.equalTo(@(GLOBALE_CELL_HEIGHT));
    }];
    [confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setTitleColor:UIColorWhite forState:UIControlStateNormal];

    
    typeBtn.backgroundColor = [QDThemeManager sharedInstance].currentTheme.themeTintColor;
    moneyTF.backgroundColor = UIColorWhite;
    discountTF.backgroundColor = UIColorWhite;
    discountBtn.backgroundColor = [QDThemeManager sharedInstance].currentTheme.themeTintColor;
    confirmBtn.backgroundColor = [QDThemeManager sharedInstance].currentTheme.themeTintColor;
    
    [typeBtn addTarget:self action:@selector(typeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [discountBtn addTarget:self action:@selector(showDiscountMenu) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)typeBtnAction{
    typeBtn.selected = !typeBtn.selected;
    if (typeBtn.selected) {
        discountTF.placeholder = @"请输入优惠金额";
    }
    else{
        discountTF.placeholder = @"输入折扣，例如：9.5（代表九五折）";
    }
}

- (void)showDiscountMenu{
    __weak typeof(self)weakSelf = self;
    menuView = [[QMUIPopupMenuView alloc] init];
    menuView.automaticallyHidesWhenUserTap = YES;// 点击空白地方自动消失
    menuView.preferLayoutDirection = QMUIPopupContainerViewLayoutDirectionBelow;
    menuView.maximumWidth = 200;
    menuView.items = @[
                       [QMUIPopupMenuItem itemWithImage:nil title:@"不打折" handler:^{
                           [weakSelf clickPopitemAtIndex:0];
                       }],
                       [QMUIPopupMenuItem itemWithImage:nil title:@"九五折" handler:^{
                           [weakSelf clickPopitemAtIndex:1];
                       }],
                       [QMUIPopupMenuItem itemWithImage:nil title:@"九折" handler:^{
                           [weakSelf clickPopitemAtIndex:2];
                       }],
                       [QMUIPopupMenuItem itemWithImage:nil title:@"八五折" handler:^{
                           [weakSelf clickPopitemAtIndex:3];
                       }],
                       [QMUIPopupMenuItem itemWithImage:nil title:@"八折" handler:^{
                           [weakSelf clickPopitemAtIndex:4];
                       }],
                       [QMUIPopupMenuItem itemWithImage:nil title:@"七五折" handler:^{
                           [weakSelf clickPopitemAtIndex:5];
                       }],
                       [QMUIPopupMenuItem itemWithImage:nil title:@"七折" handler:^{
                           [weakSelf clickPopitemAtIndex:6];
                       }]
                       ];
    [menuView layoutWithTargetView:discountBtn];
    [menuView showWithAnimated:YES];
}

- (void)clickPopitemAtIndex:(NSInteger)index{
    [discountBtn setTitle:menuView.items[index].title forState:UIControlStateNormal];
    [menuView hideWithAnimated:YES];
}

- (void)caculate{
    if (typeBtn.selected) {
        //充值
        CGFloat originalMoney = [moneyTF.text floatValue];
        CGFloat discountMoney = [discountTF.text floatValue];
        finalMoney = originalMoney + discountMoney;
    }
    else{
        //消费
        CGFloat originalMoney = [moneyTF.text floatValue];
        CGFloat discount = 1.0;
        if (discountTF.text.length > 0) {
            discount = [discountTF.text floatValue];
            discount = discount/10;
        }
        else{
            NSString *discountString = discountBtn.titleLabel.text;
            if ([discountString isEqualToString:@"不打折"]) {
                discount = 1.0;
            }
            else if ([discountString isEqualToString:@"九五折"]){
                discount = 0.95;
            }
            else if ([discountString isEqualToString:@"九折"]){
                discount = 0.90;
            }
            else if ([discountString isEqualToString:@"八五折"]){
                discount = 0.85;
            }
            else if ([discountString isEqualToString:@"八折"]){
                discount = 0.80;
            }
            else if ([discountString isEqualToString:@"七五折"]){
                discount = 0.75;
            }
            else if ([discountString isEqualToString:@"七折"]){
                discount = 0.70;
            }
        }
        finalMoney = originalMoney * discount;
    }
}

- (void)confirmAction{
    if (moneyTF.text.length <=0 || [moneyTF.text floatValue] == 0) {
        [QMUITips showInfo:@"金额不能为空" inView:self.view hideAfterDelay:1.5];
        return;
    }
    [self caculate];
    NSString *typeString = nil;
    if (typeBtn.selected) {
        typeString = @"充值";
    }
    else{
        typeString = @"消费";
    }
    
    __weak typeof(self)weakSelf = self;
    NSString *message = [NSString stringWithFormat:@"%@: %.2f 元",typeString, finalMoney];
    CGFloat ret = finalMoney - [globalObj.totalMoneyLeft floatValue];
    if (ret > 0 && ![typeString isEqualToString:@"充值"]) {
        message = [NSString stringWithFormat:@"%@: %.2f 元，余额不足，还需支付：%.2f",typeString,finalMoney,ret];
    }
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:QMUIAlertControllerStyleAlert];
    [alertController addAction:[QMUIAlertAction actionWithTitle:@"添加" style:QMUIAlertActionStyleDefault handler:^(QMUIAlertAction *action) {
        [weakSelf update];
    }]];
    [alertController addAction:[QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:^(QMUIAlertAction *action) {
    }]];
    [alertController showWithAnimated:YES];
}

- (void)update{
    recordObj *record = [recordObj new];

    if (typeBtn.selected) {
        //充值
        globalObj.totalMoneyLeft = [NSString stringWithFormat:@"%f",[globalObj.totalMoneyLeft floatValue] + finalMoney];
        record.recordType = Record_In;
    }
    else{
        //消费
        if (([globalObj.totalMoneyLeft floatValue] - finalMoney) < 0) {
            globalObj.totalMoneyLeft = @"0";
        }
        else{
            globalObj.totalMoneyLeft = [NSString stringWithFormat:@"%f",[globalObj.totalMoneyLeft floatValue] - finalMoney];
        }
        record.recordType = Record_Out;
    }
    
    record.recordNum = [NSString stringWithFormat:@"%f",finalMoney];
    record.moneyLeft = globalObj.totalMoneyLeft;
    //获取系统当前时间
    NSDate *currentDate = [NSDate date];
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    //NSDate转NSString
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    record.recordDate = currentDateString;
    record.userID = globalObj.memID;
    
//    NSArray *aArray = [NSKeyedUnarchiver unarchiveObjectWithData:globalObj.recordData];
//    NSMutableArray *temArr = [[NSMutableArray alloc] initWithArray:aArray];
//    [temArr addObject:record];
    globalObj.totalMoneyLeft = record.moneyLeft;
//    globalObj.actionDate = @"20171106162010";
    
    BOOL result = [WHCSqlite update:globalObj
                              where:[NSString stringWithFormat:@"memID = %ld",globalObj.memID]];
    
    BOOL ret = [WHCSqlite insert:record];
    
    if (result && ret) {
        [QMUITips showSucceed:@"记录成功" inView:self.view hideAfterDelay:1.5];
        [self updateData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.refresh();
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
    else{
        [QMUITips showSucceed:@"记录失败" inView:self.view hideAfterDelay:1.5];
    }
}

- (void)dealloc{
    NSLog(@"addRecordVC delloc");
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
