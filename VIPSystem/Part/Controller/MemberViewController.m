//
//  MemberViewController.m
//  MemberSystem
//
//  Created by Channe Sun on 2017/10/17.
//  Copyright © 2017年 KeBook. All rights reserved.
//

#import "MemberViewController.h"
#import "MemberTableViewCell.h"
#import "AddMemberViewController.h"
#import "RecordViewController.h"
#import "EditViewController.h"

#import "QMUIConfigurationTemplate.h"
#import "QMUIConfigurationTemplateGrapefruit.h"
#import "QMUIConfigurationTemplateGrass.h"
#import "QMUIConfigurationTemplatePinkRose.h"

#define MaxPerTime 50

@interface MemberViewController ()<QMUITableViewDelegate, QMUITableViewDataSource, UISearchBarDelegate>{
    QMUITableView *memberTableView;
    NSInteger memberNum;
    NSInteger totalMemberNum;
    UISearchBar *searchBar;
    NSMutableArray *vipArr;
    BOOL hasMoreData;
    NSInteger start;
    NSMutableArray *searchArr;
}

@end

@implementation MemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleView.title = @"Cc会员系统";
    vipArr = [NSMutableArray new];
    searchArr = [NSMutableArray new];
    start = vipArr.count;
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getVIP];
    [self transformData];
}

- (void)transformData{
    //获取系统当前时间
    NSDate *currentDate = [NSDate date];
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    //NSDate转NSString
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    
    [GlobalObj sharedInstance].sqlitePath = @"WHCSqlite";
    NSArray *personArray = [WHCSqlite query:[MemObj class]
                                      order:@"by memID asc" limit:@"2000"];
    NSString * version = [WHCSqlite versionWithModel:[MemObj class]];
    NSLog(@"version = %@",version);
    NSInteger count = 0;
    [WHCSqlite removeModel:[MemObj class]];
    for (MemObj *mem in personArray) {
        MemObj *new = [MemObj new];
        new.memID = mem.memID;
        new.name = mem.name;
        new.phoneNum = mem.phoneNum;
        new.totalMoneyLeft = mem.totalMoneyLeft;
        new.actionDateStr = currentDateString;
        [WHC_ModelSqlite insert:new];
        count ++;
        NSLog(@"update mem %ld",count);
    }
    
    personArray = [WHCSqlite query:[recordObj class]
                                      order:@"by userID asc" limit:@"2000"];
    count = 0;
    [WHCSqlite removeModel:[recordObj class]];
    for (recordObj *mem in personArray) {
        recordObj *new = [recordObj new];
        new.userID = mem.userID;
        new.recordType = mem.recordType;
        new.recordNum = mem.recordNum;
        new.moneyLeft = mem.moneyLeft;
        new.recordDate = mem.recordDate;
        [WHC_ModelSqlite insert:new];
        count ++;
        NSLog(@"update record %ld",count);
    }
    
    NSLog(@"all transform done");
}

- (void)getVIP{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [GlobalObj sharedInstance].sqlitePath = @"WHCSqlite";
        NSArray *personArray = [WHCSqlite query:[MemObj class]
                                          order:@"by memID asc" limit:@"2000"];

        @synchronized(self){
            [vipArr removeAllObjects];
            [vipArr addObjectsFromArray:personArray];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [memberTableView.mj_header endRefreshing];
            [memberTableView reloadData];
        });
    });
}

- (void)setupView{
    searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.placeholder = @"会员ID/会员名字/手机号";
    [self.keyboardManager addTargetResponder:searchBar];
    
    memberTableView = [[QMUITableView alloc] init];
    [self.view addSubview:memberTableView];
    __weak typeof(self)weakSelf = self;
    [memberTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view).offset(0);
        make.bottom.equalTo(weakSelf.view).offset(-self.tabBarController.tabBar.qmui_height);
    }];
    memberTableView.delegate = self;
    memberTableView.dataSource = self;
    [memberTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(handleAboutItemEvent)];
    
    memberTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getVIP)];
}

- (void)handleAboutItemEvent{
    AddMemberViewController *addVC = [AddMemberViewController new];
    __weak typeof(self)weakSelf = self;
    addVC.refresh = ^{
        if (searchBar.text.length > 0) {
            return ;
        }
        [weakSelf getVIP];
    };
    [self.navigationController pushViewController:addVC animated:YES];
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

- (NSString *)checkSearchType:(NSString *)condition{
    NSString *ret = nil;
    BOOL isFuzzy = NO;
    if ([condition rangeOfString:@"*"].location == 0) {
        isFuzzy = YES;
        condition = [condition substringFromIndex:1];
    }
    if ([self baseCheckForRegEx:@"^1[3|4|5|7|8][0-9]\\d{8}$" data:condition]){
        ret = @"phoneNum = ";
    }
    else if ([self baseCheckForRegEx:@"^[0-9]+([.]{0,1}[0-9]+){0,1}$" data:condition]) {
        ret = @"memID = ";
    }
    else if ([self baseCheckForRegEx:@"^[\\u4e00-\\u9fa5]{0,}$" data:condition]){
        ret = @"name = ";
    }
    if (isFuzzy) {
        ret = [@"*" stringByAppendingString:ret];
    }
    return ret;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *funnyStr = searchBar.text;
    if ([funnyStr hasPrefix:@"enableAutoTheme"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Auto_Change_Color"];
        [QMUITips showSucceed:@"开启自动换肤" inView:self.view hideAfterDelay:1.5];
        return;
    }
    if ([funnyStr hasPrefix:@"disableAutoTheme"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Auto_Change_Color"];
        [QMUITips showSucceed:@"关闭自动换肤" inView:self.view hideAfterDelay:1.5];
        [QDThemeManager sharedInstance].currentTheme = [[QMUIConfigurationTemplate alloc] init];
        [QDCommonUI renderGlobalAppearances];
        return;
    }
    
    NSString *ret = [self checkSearchType:searchBar.text];
    
    if (!ret) {
        [QMUITips showError:@"非法条件" inView:self.view hideAfterDelay:1.5];
        return;
    }
    if ([ret containsString:@"name"]) {
        //名称
        if ([ret rangeOfString:@"*"].location == 0) {
            //模糊查询
            searchArr = [[NSMutableArray alloc] initWithArray:[WHC_ModelSqlite query:[MemObj class] where:[NSString stringWithFormat:@"name LIKE '%%%@%%'", [searchBar.text substringFromIndex:1]]]];
            NSLog(@"%@",[NSString stringWithFormat:@"name LIKE '%%%@%%'", [searchBar.text substringFromIndex:1]]);
        }
        else{
            searchArr = [[NSMutableArray alloc] initWithArray:[WHC_ModelSqlite query:[MemObj class] where:[NSString stringWithFormat:@"%@'%@'",ret, searchBar.text]]];
            if (searchArr.count == 0) {
                searchArr = [[NSMutableArray alloc] initWithArray:[WHC_ModelSqlite query:[MemObj class] where:[NSString stringWithFormat:@"name LIKE '%%%@%%'", searchBar.text]]];
            }
        }
    }
    else{
        if ([ret rangeOfString:@"*"].location == 0) {
            NSString *condition = searchBar.text;
            condition = [condition substringFromIndex:1];
            ret = [ret stringByReplacingOccurrencesOfString:@"*" withString:@""];
            ret = [ret stringByReplacingOccurrencesOfString:@"= " withString:@"LIKE"];
            searchArr = [[NSMutableArray alloc] initWithArray:[WHC_ModelSqlite query:[MemObj class] where:[NSString stringWithFormat:@"%@ '%%%@%%'",ret, condition]]];
            NSLog(@"%@",[NSString stringWithFormat:@"%@ '%%%@%%'",ret, condition]);
        }
        else{
            searchArr = [[NSMutableArray alloc] initWithArray:[WHC_ModelSqlite query:[MemObj class] where:[NSString stringWithFormat:@"%@%@",ret, searchBar.text]]];
            if (searchArr.count == 0) {
                ret = [ret stringByReplacingOccurrencesOfString:@"=" withString:@"LIKE"];
                searchArr = [[NSMutableArray alloc] initWithArray:[WHC_ModelSqlite query:[MemObj class] where:[NSString stringWithFormat:@"%@ %%%@%%",ret, searchBar.text]]];
            }
        }
    }
    
    if (searchArr.count > 0) {
        vipArr = searchArr;
        [memberTableView reloadData];
    }
    else{
        [QMUITips showError:@"没有找到符合条件的会员" inView:self.view hideAfterDelay:1.5];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self getVIP];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText length] == 0) {
        start = 0;
        [self getVIP];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [searchBar resignFirstResponder];
}

- (void)deleteData:(NSString *)condition{
    BOOL ret = [WHC_ModelSqlite delete:[MemObj class] where:[NSString stringWithFormat:@"memID = %lld", [condition longLongValue]]];
    if (ret) {
        [QMUITips showSucceed:@"删除成功" inView:self.view hideAfterDelay:1.5];
        [self getVIP];
        [self updateData];
    }
}

- (void)editUserInfo:(QMUIButton *)sender{
    if ([GlobalObj sharedInstance].type != Authority_Admin) {
        [QMUITips showError:@"你没有权限!" inView:self.view hideAfterDelay:1.5];
        return;
    }
    MemObj *obj = (MemObj *)vipArr[sender.tag];
    EditViewController *edit = [EditViewController new];
    edit.userObj = obj;
    edit.refresh = ^{
        
    };
    [self.navigationController pushViewController:edit animated:YES];
}

#pragma mark - <QMUIKeyboardManagerDelegate>
- (void)keyboardWillChangeFrameWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    __weak typeof(self)weakSelf = self;
    [QMUIKeyboardManager handleKeyboardNotificationWithUserInfo:keyboardUserInfo showBlock:^(QMUIKeyboardUserInfo *keyboardUserInfo) {
        CGFloat distanceFromBottom = [QMUIKeyboardManager distanceFromMinYToBottomInView:weakSelf.view keyboardRect:keyboardUserInfo.endFrame];
        [weakSelf addClearView:distanceFromBottom];
        [QMUIKeyboardManager animateWithAnimated:YES keyboardUserInfo:keyboardUserInfo animations:^{
            
        } completion:NULL];
    } hideBlock:^(QMUIKeyboardUserInfo *keyboardUserInfo) {
        [weakSelf hideClearView];
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
    RecordViewController *recordVC = [RecordViewController new];
    if (indexPath.row - 1 > vipArr.count - 1) {
        return;
    }
    MemObj *obj = (MemObj *)vipArr[indexPath.row - 1];
    recordVC.userID = obj.memID;
    [self.navigationController pushViewController:recordVC animated:YES];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return   UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

//进入编辑模式，按下出现的编辑按钮后
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([GlobalObj sharedInstance].type != Authority_Admin) {
            [QMUITips showError:@"你没有权限!" inView:self.view hideAfterDelay:1.5];
            [tableView setEditing:NO animated:YES];
            return;
        }
        MemberTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"提示" message:@"是否删除该会员" preferredStyle:QMUIAlertControllerStyleAlert];
        [alertController addAction:[QMUIAlertAction actionWithTitle:@"删除" style:QMUIAlertActionStyleDestructive handler:^(QMUIAlertAction *action) {
            [self deleteData:[cell.IDLabel.text stringByReplacingOccurrencesOfString:@"会员ID：" withString:@""]];
            [tableView setEditing:NO animated:YES];
        }]];
        [alertController addAction:[QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:^(QMUIAlertAction *action) {
            [tableView setEditing:NO animated:YES];
        }]];
        [alertController showWithAnimated:YES];
    }
}

//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return vipArr.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recalldetail_cell"];
    if (!cell) {
        cell = [[MemberTableViewCell alloc] initForTableView:tableView withReuseIdentifier:@"recalldetail_cell"];
    }
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UISearchBar class]]) {
            [view removeFromSuperview];
        }
    }
    if (indexPath.row == 0) {
        [cell.contentView addSubview:searchBar];
        [searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(cell.contentView);
            make.top.equalTo(cell.contentView);
            make.bottom.equalTo(cell.contentView);
        }];
    }
    else{
        cell.cellIndex = indexPath.row;
        MemObj *obj = (MemObj *)vipArr[indexPath.row - 1];
        [cell setData:obj];
        cell.userImageBtn.tag = indexPath.row - 1;
        [cell.userImageBtn addTarget:self action:@selector(editUserInfo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
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
