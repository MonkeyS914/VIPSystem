//
//  MemberTableViewCell.h
//  MemberSystem
//
//  Created by Channe Sun on 2017/10/24.
//  Copyright © 2017年 KeBook. All rights reserved.
//

#import <QMUIKit/QMUIKit.h>

@interface MemberTableViewCell : QMUITableViewCell

@property (nonatomic, strong)QMUILabel *nameLabel;
@property (nonatomic, strong)QMUILabel *IDLabel;
@property (nonatomic, strong)QMUILabel *IDLabelFront;
@property (nonatomic, strong)QMUIButton *phoneBtn;
@property (nonatomic, strong)QMUIButton *userImageBtn;
@property (nonatomic, strong)QMUILabel *moneyLeftLabel;
@property (nonatomic, assign)NSInteger cellIndex;

/**
 

 @param dic @{"useInfo":MemObj,"recordInfo":array}
 */
- (void)setData:(MemObj *)obj;

@end
