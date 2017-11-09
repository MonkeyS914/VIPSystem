//
//  RecordTableViewCell.h
//  VIPSystem
//
//  Created by Channe Sun on 2017/10/25.
//  Copyright © 2017年 Omnivision. All rights reserved.
//

#import <QMUIKit/QMUIKit.h>

@interface RecordTableViewCell : QMUITableViewCell

@property (nonatomic, strong)QMUILabel *nameLabel;//费用
@property (nonatomic, strong)QMUILabel *leftLabel;//费用
@property (nonatomic, strong)QMUILabel *dateLabel;//日期
@property (nonatomic, strong)UIImageView *typeImageView;//类型
@property (nonatomic, assign)NSInteger cellIndex;

- (void)setData:(recordObj *)obj;

@end
