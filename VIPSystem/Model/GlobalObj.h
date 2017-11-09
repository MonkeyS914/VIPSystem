//
//  GlobalObj.h
//  VIPSystem
//
//  Created by Channe Sun on 2017/10/26.
//  Copyright © 2017年 Omnivision. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    Authority_Admin,
    Authority_CommonUser,
} AuthorityType;

@interface GlobalObj : NSObject

@property (nonatomic, strong)NSDate *lastInDate;
@property (nonatomic, assign)AuthorityType type;
@property (nonatomic, strong)NSString *sqlitePath;//SCSqlite or WHCSqlite

+ (instancetype)sharedInstance;

@end
