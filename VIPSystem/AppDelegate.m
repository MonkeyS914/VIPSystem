//
//  AppDelegate.m
//  VIPSystem
//
//  Created by Channe Sun on 2017/10/24.
//  Copyright © 2017年 Omnivision. All rights reserved.
//

#import "AppDelegate.h"
#import "QDUIHelper.h"
#import "QDCommonUI.h"
#import "QDTabBarViewController.h"
#import "QDNavigationController.h"
#import "QDUIKitViewController.h"
#import "QDComponentsViewController.h"
#import "QDLabViewController.h"
#import "QMUIConfigurationTemplate.h"
#import "QMUIConfigurationTemplateGrapefruit.h"
#import "QMUIConfigurationTemplateGrass.h"
#import "QMUIConfigurationTemplatePinkRose.h"

#import "MemberViewController.h"
#import "BillViewController.h"
#import "OtherViewController.h"
#import "GlobalObj.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "LoginView.h"

#import <objc/runtime.h>

#define MaxTime 30 * 60

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self firstLaunch];
    // 应用 QMUI Demo 皮肤
    NSString *themeClassName = [[NSUserDefaults standardUserDefaults] stringForKey:QDSelectedThemeClassName] ?: NSStringFromClass([QMUIConfigurationTemplate class]);
    [QDThemeManager sharedInstance].currentTheme = [[NSClassFromString(themeClassName) alloc] init];
    
    // QD自定义的全局样式渲染
    [QDCommonUI renderGlobalAppearances];
    
    [self setTheme];
    
    //同步数据
    [GlobalObj sharedInstance].sqlitePath = @"WHCSqlite";
    [self downloadDataFromiCloud];
    
    // 界面
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self createTabBarController];
    [self askForAuthentication];
    // 启动动画
//    [self startLaunchingAnimation];
    
    NSLog(@"%@",[WHCSqlite localPathWithModel:[MemObj class]]);
    return YES;
}

- (void)firstLaunch{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"first_launch"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Auto_Change_Color"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"first_launch"];
    }
}

- (void)setTheme{
    BOOL shouldAuto = [[NSUserDefaults standardUserDefaults] boolForKey:@"Auto_Change_Color"];
    if (shouldAuto) {
        NSArray<NSObject<QDThemeProtocol> *> *themes = @[[[QMUIConfigurationTemplate alloc] init],
                        [[QMUIConfigurationTemplateGrapefruit alloc] init],
                        [[QMUIConfigurationTemplateGrass alloc] init],
                        [[QMUIConfigurationTemplatePinkRose alloc] init]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd"];
        NSString *dateTime = [formatter stringFromDate:[NSDate date]];
        NSInteger themeIndex = [dateTime integerValue]%4;
        [QDThemeManager sharedInstance].currentTheme = themes[themeIndex];
        [[NSUserDefaults standardUserDefaults] setObject:NSStringFromClass(themes[themeIndex].class) forKey:QDSelectedThemeClassName];
        [QDCommonUI renderGlobalAppearances];
    }
}

- (void)createTabBarController {
    QDTabBarViewController *tabBarViewController = [[QDTabBarViewController alloc] init];
    
    // QMUIKit
    MemberViewController *uikitViewController = [[MemberViewController alloc] init];
    uikitViewController.hidesBottomBarWhenPushed = NO;
    QDNavigationController *uikitNavController = [[QDNavigationController alloc] initWithRootViewController:uikitViewController];
    uikitNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"会员" image:[UIImageMake(@"icon_tabbar_uikit") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"icon_tabbar_uikit_selected") tag:0];
    
    // UIComponents
    BillViewController *componentViewController = [[BillViewController alloc] init];
    componentViewController.hidesBottomBarWhenPushed = NO;
    QDNavigationController *componentNavController = [[QDNavigationController alloc] initWithRootViewController:componentViewController];
    componentNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"账单" image:[UIImageMake(@"icon_tabbar_component") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"icon_tabbar_component_selected") tag:1];
    
    // Lab
    OtherViewController *labViewController = [[OtherViewController alloc] init];
    labViewController.hidesBottomBarWhenPushed = NO;
    QDNavigationController *labNavController = [[QDNavigationController alloc] initWithRootViewController:labViewController];
    labNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"其他" image:[UIImageMake(@"icon_tabbar_lab") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"icon_tabbar_lab_selected") tag:2];
    
    // window root controller
    tabBarViewController.viewControllers = @[uikitNavController, componentNavController, labNavController];
    self.window.rootViewController = tabBarViewController;
    [self.window makeKeyAndVisible];
}

- (void)startLaunchingAnimation {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIView *launchScreenView = [[NSBundle mainBundle] loadNibNamed:@"LaunchScreen" owner:self options:nil].firstObject;
    launchScreenView.frame = window.bounds;
    [window addSubview:launchScreenView];
    
    UIImageView *backgroundImageView = launchScreenView.subviews[0];
    backgroundImageView.clipsToBounds = YES;
    
    UIImageView *logoImageView = launchScreenView.subviews[1];
    UILabel *copyrightLabel = launchScreenView.subviews.lastObject;
    
    UIView *maskView = [[UIView alloc] initWithFrame:launchScreenView.bounds];
    maskView.backgroundColor = UIColorWhite;
    [launchScreenView insertSubview:maskView belowSubview:backgroundImageView];
    
    [launchScreenView layoutIfNeeded];
    
    
    [launchScreenView.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.identifier isEqualToString:@"bottomAlign"]) {
            obj.active = NO;
            [NSLayoutConstraint constraintWithItem:backgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:launchScreenView attribute:NSLayoutAttributeTop multiplier:1 constant:NavigationContentTop].active = YES;
            *stop = YES;
        }
    }];
    
    [UIView animateWithDuration:.15 delay:0.9 options:QMUIViewAnimationOptionsCurveOut animations:^{
        [launchScreenView layoutIfNeeded];
        logoImageView.alpha = 0.0;
        copyrightLabel.alpha = 0;
    } completion:nil];
    [UIView animateWithDuration:1.2 delay:0.9 options:UIViewAnimationOptionCurveEaseOut animations:^{
        maskView.alpha = 0;
        backgroundImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [launchScreenView removeFromSuperview];
    }];
}

- (void)askForAuthentication{
    BOOL hasShow = NO;
    for (UIView *view in self.window.subviews) {
        if ([view isKindOfClass:[LoginView class]]) {
            hasShow = YES;
            break;
        }
    }
    if (hasShow) {
        return;
    }
    NSDate *lastIn = [GlobalObj sharedInstance].lastInDate;
    NSDate *currentDate = [NSDate date];
    NSTimeInterval interval = [currentDate timeIntervalSinceDate:lastIn];
    NSString *password = [PassWordTool readPassword];
    if (!password) {
        [QMUITips showWithText:@"您还未设置密码" inView:self.window hideAfterDelay:1.5];
        return;
    }
    if (interval > MaxTime || !lastIn) {
        LoginView *login = [LoginView new];
        login.backgroundColor = UIColorWhite;
        [self.window addSubview:login];
        __weak typeof(self)weakSelf = self;
        [login mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf.window);
        }];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [self askForAuthentication];
}

- (void)updateDataFromiCloud{
    BaseViewController *base = [BaseViewController new];
    [base updateData];
}

- (void)downloadDataFromiCloud{
    BaseViewController *base = [BaseViewController new];
    [base downloadData];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self updateDataFromiCloud];
}


@end
