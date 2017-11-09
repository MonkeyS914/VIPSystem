//
//  BaseViewController.h
//  VIPSystem
//
//  Created by Channe Sun on 2017/10/24.
//  Copyright © 2017年 Omnivision. All rights reserved.
//

#import <QMUIKit/QMUIKit.h>

@interface BaseViewController : QMUICommonViewController

@property (nonatomic, assign) CGFloat base_TabBar_Height;
@property (nonatomic, strong) QMUIKeyboardManager *keyboardManager;


- (void)addClearView:(CGFloat)distanceFromBottom;

- (void)hideClearView;

- (void)downloadData;

- (void)updateData;

- (void)updateDataWithTips:(BOOL)showTips;

- (NSString *)getCurrentDate;

@end
