//
//  recordObj.h
//  MemberSystem
//
//  Created by Channe Sun on 2017/10/17.
//  Copyright © 2017年 KeBook. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    Record_In,
    Record_Out,
} SCRecordType;

@interface recordObj : NSObject<WHC_SqliteInfo>

/**
 消费记录，1是充值，0是支出
 */
@property (nonatomic, assign)long userID;
@property (nonatomic, assign)SCRecordType recordType;
@property (nonatomic, strong)NSString *recordNum;
@property (nonatomic, strong)NSString *moneyLeft;
@property (nonatomic, strong)NSString *recordDate;
//@property (nonatomic, strong)NSDate *actionDate;
//@property (nonatomic, assign)long operationID;
//@property (nonatomic, strong)NSString *recordID;

@end
