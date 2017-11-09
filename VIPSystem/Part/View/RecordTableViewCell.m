//
//  RecordTableViewCell.m
//  VIPSystem
//
//  Created by Channe Sun on 2017/10/25.
//  Copyright © 2017年 Omnivision. All rights reserved.
//

#import "RecordTableViewCell.h"

@interface RecordTableViewCell(){
    UIColor *textColor;
}

@end

@implementation RecordTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self checkReuseIdentifier:reuseIdentifier];
    }
    return self;
}

- (instancetype)initForTableView:(UITableView *)tableView withStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initForTableView:tableView withStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self checkReuseIdentifier:reuseIdentifier];
    }
    return self;
}

- (void)checkReuseIdentifier:(NSString *)indentifier{
    if ([indentifier isEqualToString:@"recalldetail_cell"]) {
        [self setupView];
    }
    else if ([indentifier isEqualToString:@"bill_cell"]){
        [self setupView];
    }
}

- (void)setupView{
    __weak typeof(self)weakSelf = self;
    _typeImageView = [UIImageView new];
    [self.contentView addSubview:_typeImageView];
    [_typeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView).offset(15);
        make.top.equalTo(weakSelf.contentView).offset(5);
        make.bottom.equalTo(weakSelf.contentView).offset(-5);
        make.width.equalTo(weakSelf.typeImageView.mas_height);
    }];
    
    _dateLabel = [QMUILabel new];
    [self.contentView addSubview:_dateLabel];
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.contentView).offset(-15);
        make.top.height.equalTo(weakSelf.typeImageView);
        make.width.equalTo(@100);
    }];
    
    _nameLabel = [QMUILabel new];
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.typeImageView.mas_right).offset(10);
        make.top.height.equalTo(weakSelf.typeImageView);
    }];
    
    _leftLabel = [QMUILabel new];
    [self.contentView addSubview:_leftLabel];
    [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.nameLabel.mas_right).offset(10);
        make.top.height.equalTo(weakSelf.typeImageView);
        make.right.equalTo(weakSelf.dateLabel.mas_left).offset(-10);
        make.width.equalTo(weakSelf.nameLabel);
    }];
    
    _dateLabel.textAlignment = NSTextAlignmentRight;
    
    if (IS_IPHONE) {
        _nameLabel.font = [UIFont systemFontOfSize:12];
        _leftLabel.font = [UIFont systemFontOfSize:12];
        _dateLabel.font = [UIFont systemFontOfSize:12];
    }
    
    if (IF_UI_DEBUG) {
        _nameLabel.backgroundColor = UIColorTheme1;
        _leftLabel.backgroundColor = UIColorTheme2;
        _dateLabel.backgroundColor = UIColorTheme3;
        _typeImageView.backgroundColor = UIColorTheme4;
    }
}

- (void)setColor:(BOOL)shouldSet{
    if (shouldSet) {
        //cell 背景颜色
        if (_cellIndex%2 == 0) {
            self.backgroundColor = UIColorMake(250, 250, 250);
        }
        else if (_cellIndex%2 == 1){
            self.backgroundColor = UIColorMake(240, 240, 240);
        }
        //imageview颜色
        NSInteger index = _cellIndex;
        index = index%7;
        switch (index) {
            case 0:
                textColor = UIColorTheme1;
                break;
            case 1:
                textColor = UIColorTheme2;
                break;
            case 2:
                textColor = UIColorTheme3;
                break;
            case 3:
                textColor = UIColorTheme4;
                break;
            case 4:
                textColor = UIColorTheme5;
                break;
            case 5:
                textColor = UIColorTheme6;
                break;
            case 6:
                textColor = UIColorTheme7;
                break;
            case 7:
                textColor = UIColorTheme8;
                break;
            case 8:
                textColor = UIColorTheme9;
                break;
            default:
                break;
        }
    }
    else{
        textColor = UIColorBlack;
    }
}

//1 充值 0 支出
- (void)setData:(recordObj *)obj{
    if (!obj) {
        return;
    }
    
    [self setColor:YES];
    
    NSString *typeStr = nil;
    if (obj.recordType == Record_In) {
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:@"+" attributes:@{NSForegroundColorAttributeName:UIColorGreen, NSFontAttributeName:[UIFont systemFontOfSize:12]}];
        _typeImageView.image = [[UIImage qmui_imageWithAttributedString:text] qmui_imageWithScaleToSize:CGSizeMake(50, 50)];
        typeStr = @"充值";
    }
    else{
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:@"-" attributes:@{NSForegroundColorAttributeName:UIColorRed, NSFontAttributeName:[UIFont systemFontOfSize:12]}];
        _typeImageView.image = [[UIImage qmui_imageWithAttributedString:text] qmui_imageWithScaleToSize:CGSizeMake(50, 50)];
        typeStr = @"消费";
    }
    _typeImageView.contentMode = UIViewContentModeCenter;
    _nameLabel.text = [NSString stringWithFormat:@"%@：%@",typeStr,AdjustString(obj.recordNum)];
    
    if ([self.reuseIdentifier isEqualToString:@"bill_cell"]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray *personArray = [WHCSqlite query:[MemObj class]
                                              where:[NSString stringWithFormat:@"memID = %ld",obj.userID]];
            if (personArray.count > 0) {
                MemObj *mem = (MemObj *)personArray[0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _leftLabel.text = [NSString stringWithFormat:@"%@：%@",@"姓名",mem.name];
                });
            }
        });
    }
    else{
        _leftLabel.text = [NSString stringWithFormat:@"%@：%@",@"剩余",AdjustString(obj.moneyLeft)];
    }
    
    if (obj.recordDate.length >= 8) {
        NSString *dateStr = obj.recordDate;
        NSString *year = [dateStr substringWithRange:NSMakeRange(0, 4)];
        NSString *month = [dateStr substringWithRange:NSMakeRange(4, 2)];
        NSString *day = [dateStr substringWithRange:NSMakeRange(6, 2)];
        dateStr = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
        _dateLabel.text = dateStr;
    }
    else{
        _dateLabel.text = obj.recordDate;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
