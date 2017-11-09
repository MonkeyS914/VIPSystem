//
//  GlobalObj.m
//  VIPSystem
//
//  Created by Channe Sun on 2017/10/26.
//  Copyright © 2017年 Omnivision. All rights reserved.
//

#import "GlobalObj.h"

@implementation GlobalObj

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GlobalObj *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

@end
