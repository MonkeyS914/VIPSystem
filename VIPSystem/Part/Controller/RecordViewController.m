//
//  RecordViewController.m
//  VIPSystem
//
//  Created by Channe Sun on 2017/10/25.
//  Copyright © 2017年 Omnivision. All rights reserved.
//

#import "RecordViewController.h"
#import "RecordTableViewCell.h"
#import "AddRecordViewController.h"

@interface RecordViewController ()<QMUITableViewDelegate, QMUITableViewDataSource>{
    QMUITableView *recordTableView;
    NSMutableArray *recordArr;
    MemObj *globalObj;
}

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleView.title = @"消费记录";
    recordArr = [NSMutableArray new];
    [self getRecord];
    [self setupView];
}

- (void)getRecord{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *personArray = [WHCSqlite query:[recordObj class]
                                          where:[NSString stringWithFormat:@"userID = %ld",self.userID]];
        if (personArray.count > 0) {
//            globalObj = (MemObj *)personArray[0];
            @synchronized(self){
//                NSArray *aArray = [NSKeyedUnarchiver unarchiveObjectWithData:globalObj.recordData];
                [recordArr removeAllObjects];
                [recordArr addObjectsFromArray:personArray];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [recordTableView.mj_header endRefreshing];
                [recordTableView reloadData];
            });
        }
        
        NSArray *usrArr = [WHCSqlite query:[MemObj class]
                                     where:[NSString stringWithFormat:@"memID = %ld",self.userID]];
        if (usrArr.count > 0) {
            globalObj = (MemObj *)usrArr[0];
        }
    });
}

- (void)setupView{
    recordTableView = [[QMUITableView alloc] init];
    [self.view addSubview:recordTableView];
    __weak typeof(self)weakSelf = self;
    [recordTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view).offset(0);
        make.bottom.equalTo(weakSelf.view);
    }];
    recordTableView.delegate = self;
    recordTableView.dataSource = self;
    [recordTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(handleAboutItemEvent)];
    
    recordTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getRecord)];
}

- (void)handleAboutItemEvent{
    AddRecordViewController *addRecordVC = [AddRecordViewController new];
    addRecordVC.userID = globalObj.memID;
    __weak typeof(self)weakSelf = self;
    addRecordVC.refresh = ^{
        [weakSelf getRecord];
    };
    [self.navigationController pushViewController:addRecordVC animated:YES];
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
        if ([GlobalObj sharedInstance].type != Authority_Admin) {
            [QMUITips showError:@"你没有权限!" inView:self.view hideAfterDelay:1.5];
            return;
        }
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
    return recordArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recalldetail_cell"];
    if (!cell) {
        cell = [[RecordTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"recalldetail_cell"];
    }
    recordObj *obj = (recordObj *)recordArr[indexPath.row];
    cell.cellIndex = indexPath.row;
    [cell setData:obj];
    return cell;
}

- (void)dealloc{
    NSLog(@"recordVC delloc");
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
