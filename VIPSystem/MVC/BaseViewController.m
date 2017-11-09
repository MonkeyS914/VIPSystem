//
//  BaseViewController.m
//  VIPSystem
//
//  Created by Channe Sun on 2017/10/24.
//  Copyright © 2017年 Omnivision. All rights reserved.
//

#import "BaseViewController.h"
#import "MyDocument.h"
#define UbiquityContainerIdentifier @"iCloud.com.ccvipsystem.data"

@interface BaseViewController ()<QMUIKeyboardManagerDelegate>{
    NSInteger totalDataCount;
}

@property(strong,nonatomic) NSURL *myUrl;
@property(strong,nonatomic) NSMetadataQuery *myMetadataQuery;//icloud查询需要用这个类

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    totalDataCount = 0;
    [self setBackGroundColorRandom];
    self.base_TabBar_Height = self.tabBarController.tabBar.frame.size.height;
    self.keyboardManager = [[QMUIKeyboardManager alloc] initWithDelegate:self];
    
    //数据获取完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MetadataQueryDidFinishGathering:) name:NSMetadataQueryDidFinishGatheringNotification object:self.myMetadataQuery];
}

- (void)setBackGroundColorRandom{
    int ret = arc4random() % 4;
    switch (ret) {
            case 0:
            self.view.backgroundColor = UIColorTheme1;
            break;
            case 1:
            self.view.backgroundColor = UIColorTheme2;
            break;
            case 2:
            self.view.backgroundColor = UIColorTheme3;
            break;
            case 3:
            self.view.backgroundColor = UIColorTheme4;
            break;
        default:
            self.view.backgroundColor = UIColorTheme5;
            break;
    }
}

#pragma mark -SetNavigation
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)setNavigationBarProperty{
    //去掉导航栏下面的线
    UIImageView * navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    navBarHairlineImageView.backgroundColor = [UIColor whiteColor];
    navBarHairlineImageView.hidden = YES;
    //导航栏背景色
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    //导航栏item颜色
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    //设置导航栏标题的大小
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    
    //隐藏导航栏的一条直线
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)addClearView:(CGFloat)distanceFromBottom{
    QMUITestView *temView = [[QMUITestView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - distanceFromBottom)];
    temView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:temView];
}

- (void)hideClearView{
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[QMUITestView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (NSString *)getCurrentDate{
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
    return currentDateString;
}

- (BOOL)shouldAutorotate{
    if (IS_IPHONE) {
        return NO;
    }
    else{
        return YES;
    }
}

#pragma mark -同步数据
- (void)downloadData{
    //    [QMUITips showInfo:@"开发中..." inView:self.view hideAfterDelay:1.5];
    //    return;
    self.myMetadataQuery = [[NSMetadataQuery alloc] init];
    [self.myMetadataQuery setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
    [self.myMetadataQuery startQuery];
}

//获取成功
-(void)MetadataQueryDidFinishGathering:(NSNotification*)noti{
    NSLog(@"MetadataQueryDidFinishGathering");
    NSArray *items = self.myMetadataQuery.results;//查询结果集
    //便利结果
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMetadataItem*item =obj;
        //获取文件名
        NSString *fileName = [item valueForAttribute:NSMetadataItemFSNameKey];
        //获取文件创建日期
        NSDate *date = [item valueForAttribute:NSMetadataItemFSContentChangeDateKey];
        NSLog(@"%@,%@",fileName,date);
        //读取文件内容
        MyDocument *doc =[[MyDocument alloc] initWithFileURL:[self getUbiquityContainerUrl:fileName]];
        doc.fileName = fileName;
        totalDataCount ++ ;
        [doc openWithCompletionHandler:^(BOOL success) {
            totalDataCount --;
            if (success) {
                NSLog(@"读取数据成功.");
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *cachesDir = [paths objectAtIndex:0];
                NSString *folderPath = [cachesDir stringByAppendingPathComponent:[GlobalObj sharedInstance].sqlitePath];
                NSError *error = nil;
                if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error];
                    if (error) {
                        NSLog(@"%@",error);
                    }
                }
                NSURL *fileUrl = [NSURL URLWithString:[folderPath stringByAppendingPathComponent:doc.fileName]];
                error = nil;
                [doc.myData writeToFile:fileUrl.absoluteString options:NSDataWritingAtomic error:&error];
                //                [doc.myData writeToURL:fileUrl options:NSDataWritingAtomic error:&error];
                if (!error) {
                    NSLog(@"%@",error);
                    if (totalDataCount == 0) {
                        [QMUITips showSucceed:@"同步成功" inView:self.view hideAfterDelay:1.5];
                    }
                }
                else{
                    if (totalDataCount == 0) {
                        [QMUITips showSucceed:@"同步失败" inView:self.view hideAfterDelay:1.5];
                    }
                }
            }
        }];
    }];
}

- (void)updateData{
    [self updateDataWithTips:NO];
}

//获取url
- (NSURL*)getUbiquityContainerUrl:(NSString*)fileName{
    if (!self.myUrl) {
        self.myUrl = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:UbiquityContainerIdentifier];
        if (!self.myUrl) {
            [QMUITips showInfo:@"请前往设置开启iCloud功能" inView:self.view hideAfterDelay:1.5];
            return nil;
        }
    }
    NSURL *url = [self.myUrl URLByAppendingPathComponent:@"Documents"];
    url = [url URLByAppendingPathComponent:fileName];
    return url;
}

- (void)updateDataWithTips:(BOOL)showTips{
    //    [QMUITips showInfo:@"开发中..." inView:self.view hideAfterDelay:1.5];
    //    return;
    NSMutableArray *pathArr = [NSMutableArray new];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    NSString *folderPath = [cachesDir stringByAppendingPathComponent:[GlobalObj sharedInstance].sqlitePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:NULL];
        int count = 1;
        for (NSString *aPath in contentOfFolder) {
            NSString * fullPath = [folderPath stringByAppendingPathComponent:aPath];
            BOOL isDir = NO;
            [pathArr addObject:fullPath];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir])
            {
                if (isDir == YES) {
                    NSLog(@"dir-%d: %@", count, aPath);
                    count++;
                }
            }
        }
    }
    
    for (NSString *path in pathArr) {
        NSString *fileName = path.lastPathComponent;
        NSURL *url = [self getUbiquityContainerUrl:fileName];
        if (!url) {
            return;
        }
        MyDocument *doc = [[MyDocument alloc] initWithFileURL:url];
        //文档内容
        NSData *data = [NSData dataWithContentsOfFile:path];
        doc.myData = data;
        totalDataCount ++;
        [doc saveToURL:url forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            totalDataCount --;
            if (success) {
                if (totalDataCount == 0) {
                    if (showTips) {
                        [QMUITips showSucceed:@"上传成功" inView:self.view hideAfterDelay:1.5];
                    }
                }
                NSLog(@"上传成功");
            }
            else{
                if (totalDataCount == 0) {
                    if (showTips) {
                        [QMUITips showSucceed:@"上传失败" inView:self.view hideAfterDelay:1.5];
                    }
                }
                NSLog(@"上传失败");
            }
        }];
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
