//
//  BillViewController.m
//  MemberSystem
//
//  Created by Channe Sun on 2017/10/17.
//  Copyright © 2017年 KeBook. All rights reserved.
//

#import "BillViewController.h"
#import "RecordTableViewCell.h"
#import <FSCalendar.h>

@interface BillViewController ()<QMUITableViewDelegate, QMUITableViewDataSource, FSCalendarDataSource, FSCalendarDelegate>{
    QMUITableView *billTableView;
    NSMutableArray *recordArr;
    MemObj *globalObj;
    CGFloat chrageMoney;
    CGFloat saleMoney;
    NSString *globalDateStr;
}

@end

@implementation BillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleView.title = @"账单";
    recordArr = [NSMutableArray new];
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    globalDateStr = currentDateString;
    [self getRecord];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *personArray = [WHCSqlite query:[recordObj class]
                                          where:[NSString stringWithFormat:@"recordDate = %@",globalDateStr]];
        if (personArray.count <= 0 || personArray.count != recordArr.count) {
            //            globalObj = (MemObj *)personArray[0];
            @synchronized(self){
                //                NSArray *aArray = [NSKeyedUnarchiver unarchiveObjectWithData:globalObj.recordData];
                [recordArr removeAllObjects];
                [recordArr addObjectsFromArray:personArray];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [billTableView.mj_header endRefreshing];
                [billTableView reloadData];
            });
        }
    });
}

- (void)getRecord{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *personArray = [WHCSqlite query:[recordObj class]
                                          where:[NSString stringWithFormat:@"recordDate = %@",globalDateStr]];
        [recordArr removeAllObjects];
        if (personArray.count > 0) {
            //            globalObj = (MemObj *)personArray[0];
            @synchronized(self){
                //                NSArray *aArray = [NSKeyedUnarchiver unarchiveObjectWithData:globalObj.recordData];
                [recordArr addObjectsFromArray:personArray];
            }
        }
        [self caculate];
        dispatch_async(dispatch_get_main_queue(), ^{
            [billTableView.mj_header endRefreshing];
            [billTableView reloadData];
        });
    });
}

- (void)caculate{
    chrageMoney = 0;
    saleMoney = 0;
    for (int i = 0; i < recordArr.count; i ++) {
        recordObj *record = (recordObj *)recordArr[i];
        if (record.recordType == Record_In) {
            chrageMoney = chrageMoney + [record.recordNum floatValue];
        }
        else if (record.recordType == Record_Out){
            saleMoney = saleMoney + [record.recordNum floatValue];
        }
    }
    NSLog(@"%f---%f",chrageMoney,saleMoney);
}

- (void)setupView{
    __weak typeof(self)weakSelf = self;
    FSCalendar *calendar = [[FSCalendar alloc] init];
    calendar.dataSource = self;
    calendar.delegate = self;
    [self.view addSubview:calendar];
    [calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.height.equalTo(@200);
        make.top.equalTo(weakSelf.view).offset(64);
    }];
    calendar.backgroundColor = UIColorWhite;
    
    billTableView = [[QMUITableView alloc] init];
    [self.view addSubview:billTableView];
    [billTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.equalTo(calendar.mas_bottom);
        make.bottom.equalTo(weakSelf.view).offset(-self.tabBarController.tabBar.qmui_height);
    }];
    billTableView.delegate = self;
    billTableView.dataSource = self;
    [billTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    billTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getRecord)];
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return GLOBALE_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return   UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

//进入编辑模式，按下出现的编辑按钮后
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"提示" message:@"是否删除该记录" preferredStyle:QMUIAlertControllerStyleAlert];
        [alertController addAction:[QMUIAlertAction actionWithTitle:@"删除" style:QMUIAlertActionStyleDestructive handler:^(QMUIAlertAction *action) {
            
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
    return recordArr.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"充值总额：%.2f | 销售总额：%.2f",chrageMoney, saleMoney];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = UIColorTheme1;
        return cell;
    }
    RecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bill_cell"];
    if (!cell) {
        cell = [[RecordTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bill_cell"];
    }
    recordObj *obj = (recordObj *)recordArr[indexPath.row - 1];
    cell.cellIndex = indexPath.row;
    [cell setData:obj];
    return cell;
}

#pragma mark - FSCalendarDelegate
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
    NSDate *today = [calendar today];
    if ([GlobalObj sharedInstance].type != Authority_Admin && today != date) {
        [QMUITips showError:@"普通用户只能查看当天营业额" inView:self.view hideAfterDelay:2.0];
        [calendar deselectDate:date];
        return;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *currentDateString = [dateFormatter stringFromDate:date];
    globalDateStr = currentDateString;
    [self getRecord];
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
