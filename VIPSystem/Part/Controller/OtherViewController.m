//
//  OtherViewController.m
//  MemberSystem
//
//  Created by Channe Sun on 2017/10/17.
//  Copyright © 2017年 KeBook. All rights reserved.
//

#import "OtherViewController.h"
#import "SecurityViewController.h"
#import "MyDocument.h"

@interface OtherViewController (){
    QMUIPopupMenuView *menuView;
    QMUIButton *rightBtn;
}

@end

@implementation OtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorWhite;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(showDiscountMenu)];
    
    rightBtn = [[QMUIButton alloc] initWithImage:[[[UIImage imageNamed:@"icon_moreOperation_report"] qmui_imageWithScaleToSize:CGSizeMake(25, 25)] qmui_imageWithTintColor:UIColorWhite] title:@""];
    [rightBtn addTarget:self action:@selector(showDiscountMenu) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.frame = CGRectMake(0, 0, 44, 44);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(handleAboutItemEvent1)];
    
//    CGFloat width = self.view.frame.size.width;
//    CGFloat height = self.view.frame.size.height;
//    CGFloat scale = width > height ? width/height : height/width;
    
    __weak typeof(self)weakSelf = self;
    UIImageView *imageView = [UIImageView new];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view).offset(64 + 20);
        make.width.equalTo(weakSelf.view).multipliedBy(0.25);
        make.height.equalTo(@0);
    }];
    imageView.image = [UIImage imageNamed:@"forfun.JPG"];
    
    QMUILabel *copyRightLabel = [QMUILabel new];
    [self.view addSubview:copyRightLabel];
    [copyRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.top.equalTo(imageView.mas_bottom).offset(20);
        make.width.equalTo(@(SCREEN_WIDTH)).multipliedBy(0.8);
        make.height.equalTo(weakSelf.view).multipliedBy(0.6);
    }];
    copyRightLabel.numberOfLines = 0;
    copyRightLabel.textColor = [QDThemeManager sharedInstance].currentTheme.themeTintColor;
    copyRightLabel.textAlignment = NSTextAlignmentCenter;
    copyRightLabel.backgroundColor = [UIColor whiteColor];
    NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    NSString *versionNum = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *buildNum = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    copyRightLabel.text = [NSString stringWithFormat:@"%@\n\nVersion: %@\n\nBuildNum: %@\n\nDeveloped by Channe, All rights reserved\n\nIf you have any questions, please contact QQ:4919668",name,versionNum,buildNum];
}

- (void)showDiscountMenu{
    __weak typeof(self)weakSelf = self;
    menuView = [[QMUIPopupMenuView alloc] init];
    menuView.automaticallyHidesWhenUserTap = YES;// 点击空白地方自动消失
    menuView.preferLayoutDirection = QMUIPopupContainerViewLayoutDirectionBelow;
    menuView.maximumWidth = 160;
    menuView.arrowSize = CGSizeMake(0, 0);
    menuView.items = @[
                       [QMUIPopupMenuItem itemWithImage:nil title:@"从云端同步数据" handler:^{
                           [weakSelf clickPopitemAtIndex:0];
                       }],
                       [QMUIPopupMenuItem itemWithImage:nil title:@"上传数据到云端" handler:^{
                           [weakSelf clickPopitemAtIndex:1];
                       }],
                       [QMUIPopupMenuItem itemWithImage:nil title:@"清除本地数据" handler:^{
                           [weakSelf clickPopitemAtIndex:2];
                       }]
                       ];
    [menuView layoutWithTargetView:rightBtn];
    [menuView showWithAnimated:YES];
}

- (void)clickPopitemAtIndex:(NSInteger)index{
    switch (index) {
        case 0:
            [self downloadData];
            break;
        case 1:
            [self updateData];
            break;
        case 2:
            [self clearAllData];
            break;
        default:
            break;
    }
}

- (void)clearAllData{
    [menuView hideWithAnimated:YES];
    if ([GlobalObj sharedInstance].type != Authority_Admin) {
        [QMUITips showError:@"你没有权限!" inView:self.view hideAfterDelay:1.5];
        return;
    }
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"提示" message:@"确定要删除所有数据？该操作将不可逆！！！" preferredStyle:QMUIAlertControllerStyleAlert];
    [alertController addAction:[QMUIAlertAction actionWithTitle:@"删除" style:QMUIAlertActionStyleDestructive handler:^(QMUIAlertAction *action) {
        [WHC_ModelSqlite removeAllModel];
        [QMUITips showSucceed:@"删除成功" inView:self.view hideAfterDelay:1.5];
    }]];
    [alertController addAction:[QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:^(QMUIAlertAction *action) {
    }]];
    [alertController showWithAnimated:YES];
}

- (void)downloadData{
    [menuView hideWithAnimated:YES];
    if ([GlobalObj sharedInstance].type != Authority_Admin) {
        [QMUITips showError:@"你没有权限!" inView:self.view hideAfterDelay:1.5];
        return;
    }
    [super downloadData];
}

- (void)updateData{
    [menuView hideWithAnimated:YES];
    if ([GlobalObj sharedInstance].type != Authority_Admin) {
        [QMUITips showError:@"你没有权限!" inView:self.view hideAfterDelay:1.5];
        return;
    }
    [super updateDataWithTips:YES];
}

- (void)handleAboutItemEvent1{
    SecurityViewController *security = [SecurityViewController new];
    [self.navigationController pushViewController:security animated:YES];
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
