//
//  MemObj.h
//  MemberSystem
//
//  Created by Channe Sun on 2017/10/17.
//  Copyright © 2017年 KeBook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "recordObj.h"

@interface MemObj : NSObject<WHC_SqliteInfo>

@property (nonatomic, strong)NSString *name;
@property (nonatomic, assign)long memID;
@property (nonatomic, strong)NSString *phoneNum;
@property (nonatomic, strong)NSString *totalMoneyLeft;
@property (nonatomic, strong)NSString *actionDateStr;
//@property (nonatomic, strong)NSDate *actionDate;
//@property (nonatomic, assign)long operationID;
//@property (nonatomic, strong)NSMutableArray<MemObj *> *expanseRecord;
//@property (nonatomic, strong)NSData *recordData;

@end
