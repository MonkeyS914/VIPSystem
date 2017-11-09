//
//  EditViewController.m
//  VIPSystem
//
//  Created by Channe Sun on 2017/10/27.
//  Copyright © 2017年 Omnivision. All rights reserved.
//

#import "EditViewController.h"

#define MoneyRegex @"^[0-9]+([.]{0,1}[0-9]+){0,1}$"
#define NameRegex @"^[\\u4e00-\\u9fa5_a-zA-Z0-9]+$"
#define IDRegex @"^[0-9]+([.]{0,1}[0-9]+){0,1}$"

@interface EditViewController ()<QMUITableViewDelegate, QMUITableViewDataSource, QMUITextFieldDelegate>
{
    QMUITableView *addMemberTableView;
    QMUITextField *IDTF;
    QMUITextField *nameTF;
    QMUITextField *phoneTF;
    QMUITextField *rechargeTF;
    QMUITextField *discountTF;
    NSArray *tfArray;
    NSInteger recommedID;
}

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleView.title = @"编辑信息";
    [self setupView];
}

- (void)setupView{
    IDTF = [QMUITextField new];
    nameTF = [QMUITextField new];
    phoneTF = [QMUITextField new];
    rechargeTF = [QMUITextField new];
    discountTF = [QMUITextField new];
    //    phoneTF.backgroundColor = UIColorTheme3;
    //    IDTF.backgroundColor = UIColorTheme1;
    //    nameTF.backgroundColor = UIColorTheme2;
    //    rechargeTF.backgroundColor = UIColorTheme4;
    //    discountTF.backgroundColor = UIColorTheme5;
    tfArray = @[IDTF, nameTF, phoneTF, rechargeTF];
    
    for (QMUITextField *tf in tfArray) {
        tf.delegate = self;
    }
    
    addMemberTableView = [[QMUITableView alloc] init];
    [self.view addSubview:addMemberTableView];
    __weak typeof(self)weakSelf = self;
    [addMemberTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view).offset(0);
        make.bottom.equalTo(weakSelf.view);
    }];
    addMemberTableView.delegate = self;
    addMemberTableView.dataSource = self;
    [addMemberTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(handleAboutItemEvent)];
    
    [nameTF becomeFirstResponder];
}

- (void)handleAboutItemEvent{
    [self updateVip];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (QMUITextField *tf in tfArray) {
        [tf resignFirstResponder];
    }
}

- (void)configureTF:(QMUITextField *)textField cell:(UITableViewCell *)cell keyboardType:(UIKeyboardType)type returnkeyType:(UIReturnKeyType)returnType placeholder:(NSString *)text{
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.contentView).offset(15);
        make.right.equalTo(cell.contentView).offset(-15);
        make.top.equalTo(cell.contentView).offset(5);
        make.bottom.equalTo(cell.contentView).offset(-5);
    }];
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.returnKeyType = returnType;
    textField.keyboardType = type;
    textField.placeholder = text;
}

- (BOOL)checkVIPInfo{
    BOOL ret = YES;
    
    if (!([self baseCheckForRegEx:NameRegex data:nameTF.text]||nameTF.text.length == 0)) {
        [QMUITips showInfo:@"错误姓名" inView:self.view hideAfterDelay:1.5];
        ret = NO;
    }
    
    if (phoneTF.text.length > 0 || phoneTF.text.length == 0) {
        if (![self checkForMobilePhoneNo:phoneTF.text]) {
            [QMUITips showInfo:@"错误电话" inView:self.view hideAfterDelay:1.5];
            ret = NO;
        }
    }
    
    if (rechargeTF.text.length || rechargeTF.text.length == 0) {
        if (![self baseCheckForRegEx:MoneyRegex data:rechargeTF.text]) {
            [QMUITips showInfo:@"错误金额" inView:self.view hideAfterDelay:1.5];
            ret = NO;
        }
    }
    
    return ret;
}

- (void)updateVip{
    if (![self checkVIPInfo]) {
        return;
    }
    
    if (nameTF.text.length > 0) {
        self.userObj.name = nameTF.text;
    }
    
    if (phoneTF.text.length > 0) {
        self.userObj.phoneNum = phoneTF.text;
    }
    
    if (rechargeTF.text.length > 0) {
        self.userObj.totalMoneyLeft = rechargeTF.text;
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL ret = NO;
        ret = [WHCSqlite update:self.userObj where:[NSString stringWithFormat:@"memID = %ld",self.userObj.memID]];
        if (ret) {
            NSLog(@"insert success");
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMUITips showSucceed:@"更新成功" inView:self.view hideAfterDelay:1.5];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.refresh();
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
        else{
            NSLog(@"insert fail");
            [QMUITips showError:@"添加失败" inView:self.view hideAfterDelay:1.5];
        }
    });
}

#pragma mark - 验证手机号
- (BOOL)checkForMobilePhoneNo:(NSString *)mobilePhone{
    NSString *regEx = @"^1[3|4|5|7|8][0-9]\\d{8}$";
    return [self baseCheckForRegEx:regEx data:mobilePhone];
}

#pragma mark - 私有方法
/**
 *  基本的验证方法
 *
 *  @param regEx 校验格式
 *  @param data  要校验的数据
 *
 *  @return YES:成功 NO:失败
 */
- (BOOL)baseCheckForRegEx:(NSString *)regEx data:(NSString *)data{
    
    NSPredicate *card = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    
    if (([card evaluateWithObject:data])) {
        return YES;
    }
    return NO;
}

#pragma mark - <QMUITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSInteger index = [tfArray indexOfObject:textField];
    [textField resignFirstResponder];
    
    if (index != tfArray.count - 1) {
        index ++ ;
        QMUITextField *temTF = tfArray[index];
        [temTF becomeFirstResponder];
    }
    else{
        [self updateVip];
    }
    return YES;
}


#pragma mark - <QMUIKeyboardManagerDelegate>
- (void)keyboardWillChangeFrameWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
//    __weak typeof(self)weakSelf = self;
    [QMUIKeyboardManager handleKeyboardNotificationWithUserInfo:keyboardUserInfo showBlock:^(QMUIKeyboardUserInfo *keyboardUserInfo) {
        //        CGFloat distanceFromBottom = [QMUIKeyboardManager distanceFromMinYToBottomInView:weakSelf.view keyboardRect:keyboardUserInfo.endFrame];
        //        [weakSelf addClearView:distanceFromBottom];
        [QMUIKeyboardManager animateWithAnimated:YES keyboardUserInfo:keyboardUserInfo animations:^{
            
        } completion:NULL];
    } hideBlock:^(QMUIKeyboardUserInfo *keyboardUserInfo) {
        //        [weakSelf hideClearView];
        [QMUIKeyboardManager animateWithAnimated:YES keyboardUserInfo:keyboardUserInfo animations:^{
            
        } completion:NULL];
    }];
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return GLOBALE_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recalldetail_cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"recalldetail_cell"];
    }
    
    if (indexPath.row == 0) {
        //id
        cell.backgroundColor = UIColorMake(250, 250, 250);
        [cell.contentView addSubview:IDTF];
        [self configureTF:IDTF cell:cell keyboardType:UIKeyboardTypeNumberPad returnkeyType:UIReturnKeyNext placeholder:[NSString stringWithFormat:@"%l",self.userObj.memID]];
        IDTF.userInteractionEnabled = NO;
    }
    else if (indexPath.row == 1){
        //name
        cell.backgroundColor = UIColorMake(240, 240, 240);
        [cell.contentView addSubview:nameTF];
        [self configureTF:nameTF cell:cell keyboardType:UIKeyboardTypeDefault returnkeyType:UIReturnKeyNext placeholder:self.userObj.name];
    }
    else if (indexPath.row == 2){
        //phone
        cell.backgroundColor = UIColorMake(250, 250, 250);
        [cell.contentView addSubview:phoneTF];
        [self configureTF:phoneTF cell:cell keyboardType:UIKeyboardTypeNumberPad returnkeyType:UIReturnKeyNext placeholder:self.userObj.phoneNum];
    }
    else if (indexPath.row == 3){
        //recharge
        cell.backgroundColor = UIColorMake(240, 240, 240);
        [cell.contentView addSubview:rechargeTF];
        [self configureTF:rechargeTF cell:cell keyboardType:UIKeyboardTypeNumberPad returnkeyType:UIReturnKeyNext placeholder:self.userObj.totalMoneyLeft];
    }
    else if (indexPath.row == 4){
        //discount
        cell.backgroundColor = UIColorMake(250, 250, 250);
        [cell.contentView addSubview:discountTF];
        [self configureTF:discountTF cell:cell keyboardType:UIKeyboardTypeNumberPad returnkeyType:UIReturnKeyDone placeholder:@"请输入优惠金额"];
    }
    return cell;
}

- (void)dealloc{
    NSLog(@"add delloc");
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
