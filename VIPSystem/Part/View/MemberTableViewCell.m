//
//  MemberTableViewCell.m
//  MemberSystem
//
//  Created by Channe Sun on 2017/10/24.
//  Copyright © 2017年 KeBook. All rights reserved.
//

#import "MemberTableViewCell.h"
#import <Masonry.h>

@interface MemberTableViewCell(){
    NSString *fullPhoneNum;
    UIColor *textColor;
}

@end

@implementation MemberTableViewCell

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

- (void)setupView{
    __weak typeof(self)weakSelf = self;
    _userImageBtn = [QMUIButton new];
    [self.contentView addSubview:_userImageBtn];
    [_userImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView).offset(5);
        make.bottom.equalTo(weakSelf.contentView).offset(-5);
        make.left.equalTo(weakSelf.contentView).offset(15);
        make.width.equalTo(weakSelf.userImageBtn.mas_height);
    }];
    CGFloat height = GLOBALE_CELL_HEIGHT;
    _userImageBtn.layer.cornerRadius = (height - 10)/2.0;
    
    _IDLabel = [QMUILabel new];
    [self.contentView addSubview:_IDLabel];
    [_IDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.contentView).offset(-15);
        make.top.equalTo(weakSelf.userImageBtn);
        make.width.equalTo(@80);
        make.height.equalTo(weakSelf.userImageBtn).multipliedBy(3.0/5.0);
    }];
    _IDLabel.textAlignment = NSTextAlignmentRight;
    
    _IDLabelFront = [QMUILabel new];
    [self.contentView addSubview:_IDLabelFront];
    [_IDLabelFront mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.IDLabel.mas_left);
        make.top.equalTo(weakSelf.userImageBtn);
        make.width.equalTo(@70);
        make.height.equalTo(weakSelf.userImageBtn).multipliedBy(3.0/5.0);
    }];
    _IDLabelFront.textAlignment = NSTextAlignmentLeft;
    _IDLabelFront.textColor = [QDThemeManager sharedInstance].currentTheme.themeTintColor;
    _IDLabelFront.text = @"会员ID：";
    
    _nameLabel = [QMUILabel new];
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.userImageBtn.mas_right).offset(5);
        make.top.equalTo(weakSelf.userImageBtn);
        make.height.equalTo(weakSelf.userImageBtn).multipliedBy(3.0/5.0);
        make.right.equalTo(weakSelf.IDLabelFront.mas_left).offset(-10);
    }];
    
    _phoneBtn = [QMUIButton new];
    [self.contentView addSubview:_phoneBtn];
    [_phoneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.nameLabel);
        make.top.equalTo(weakSelf.nameLabel.mas_bottom);
        make.height.equalTo(weakSelf.userImageBtn).multipliedBy(2.0/5.0);
    }];
    
    _moneyLeftLabel = [QMUILabel new];
    [self.contentView addSubview:_moneyLeftLabel];
    [_moneyLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.phoneBtn.mas_right).offset(5);
        make.top.height.equalTo(weakSelf.phoneBtn);
        make.width.equalTo(weakSelf.phoneBtn);
        make.right.equalTo(weakSelf.contentView).offset(-15);
    }];
    
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    _IDLabel.textAlignment = NSTextAlignmentRight;
    _phoneBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _moneyLeftLabel.textAlignment = NSTextAlignmentRight;
    
    _IDLabel.textColor = [QDThemeManager sharedInstance].currentTheme.themeTintColor;
    
    [_phoneBtn addTarget:self action:@selector(phoneBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
//    _nameLabel.textColor = CcTextColor;
//    [_phoneBtn setTitleColor:CcTextColor forState:UIControlStateNormal];
//    _IDLabel.textColor = CcTextColor;
//    _moneyLeftLabel.textColor = CcTextColor;
//    _IDLabelFront.textColor = CcTextColor;
    
    if (IF_UI_DEBUG) {
        _userImageBtn.backgroundColor = UIColorTheme1;
        _nameLabel.backgroundColor = UIColorTheme8;
        _phoneBtn.backgroundColor = UIColorTheme3;
        _IDLabel.backgroundColor = UIColorTheme5;
        _moneyLeftLabel.backgroundColor = UIColorTheme4;
        _IDLabelFront.backgroundColor = UIColorTheme6;
    }
    
    if (IS_IPHONE) {
        _phoneBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _nameLabel.font = [UIFont systemFontOfSize:12];
        _IDLabelFront.font = [UIFont systemFontOfSize:12];
        _moneyLeftLabel.font = [UIFont systemFontOfSize:12];
        _IDLabel.font = [UIFont systemFontOfSize:12];
    }
//    else{
//        _phoneBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//        _nameLabel.font = [UIFont systemFontOfSize:14];
//        _IDLabelFront.font = [UIFont systemFontOfSize:14];
//        _moneyLeftLabel.font = [UIFont systemFontOfSize:14];
//        _IDLabel.font = [UIFont systemFontOfSize:14];
//    }
}

- (void)setData:(MemObj *)vipObj{
    [self setColor:YES];
    
    _nameLabel.text = [NSString stringWithFormat:@"姓名：%@", vipObj.name];
    NSString *privatePhoneNum = vipObj.phoneNum;
    fullPhoneNum = vipObj.phoneNum;
    if (vipObj.phoneNum.length > 3) {
        privatePhoneNum = [vipObj.phoneNum stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
    [_phoneBtn setTitle:[NSString stringWithFormat:@"电话：%@", privatePhoneNum] forState:UIControlStateNormal];
    [_phoneBtn setTitle:[NSString stringWithFormat:@"电话：%@", fullPhoneNum] forState:UIControlStateSelected];
    [_phoneBtn setTitleColor:UIColorBlack forState:UIControlStateNormal];
    [_phoneBtn setTitleColor:UIColorBlack forState:UIControlStateSelected];

    _IDLabel.text = [NSString stringWithFormat:@"%ld",vipObj.memID];
    _moneyLeftLabel.text = [NSString stringWithFormat:@"余额：%.2f",[vipObj.totalMoneyLeft floatValue]];
    
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:[vipObj.name substringToIndex:1] attributes:@{NSForegroundColorAttributeName:UIColorWhite, NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    [_userImageBtn setImage:[[UIImage qmui_imageWithAttributedString:text] qmui_imageWithScaleToSize:CGSizeMake(25, 25)] forState:UIControlStateNormal];
    _userImageBtn.contentMode = UIViewContentModeCenter;
    _userImageBtn.backgroundColor = textColor;
}

- (void)phoneBtnAction{
    _phoneBtn.selected = !_phoneBtn.selected;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
