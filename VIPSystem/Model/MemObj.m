//
//  MemObj.m
//  MemberSystem
//
//  Created by Channe Sun on 2017/10/17.
//  Copyright © 2017年 KeBook. All rights reserved.
//

#import "MemObj.h"
#import <NSObject+WHC_Model.h>

@implementation MemObj

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [self whc_Encode:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        [self whc_Decode:aDecoder];
    }
    return self;
}

//+ (NSString *)whc_SqliteVersion{
//    return @"1.1";
//}

+ (NSString *)whc_SqlitePath{
    return [NSString stringWithFormat:@"%@/Library/Caches/%@/",NSHomeDirectory(),[GlobalObj sharedInstance].sqlitePath];
}

@end
