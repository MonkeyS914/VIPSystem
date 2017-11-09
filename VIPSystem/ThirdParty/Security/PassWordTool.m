//
//  PassWordTool.m
//
//  Created by CY on 16/1/9.

#import "PassWordTool.h"
#import "KeychainTool.h"

@implementation PassWordTool

static NSString * const KEY_USERNAME = @"com.suncheng.app.username";
static NSString * const KEY_PASSWORD = @"com.suncheng.app.password";

+(void)saveUsernamePassWord:(NSString *)username pwd: (NSString *)password
{
    if (!username||!password) {
        return;
    }
    NSMutableDictionary *usernamepasswordKVPairs = [NSMutableDictionary dictionary];
    [usernamepasswordKVPairs setObject:username forKey:KEY_USERNAME];
    [usernamepasswordKVPairs setObject:password forKey:KEY_PASSWORD];
    [KeychainTool save:KEY_USERNAME data:usernamepasswordKVPairs];
}

+ (BOOL) hasKeychainSaved{
    NSMutableDictionary *usernamepasswordKVPair = (NSMutableDictionary *)[KeychainTool load:KEY_USERNAME];
    return (usernamepasswordKVPair != NULL);
}

+(NSString *)readPassword
{
    NSMutableDictionary *usernamepasswordKVPair = (NSMutableDictionary *)[KeychainTool load:KEY_USERNAME];
    return [usernamepasswordKVPair objectForKey:KEY_PASSWORD];
}

+(NSString *)readUsername
{
    NSMutableDictionary *usernamepasswordKVPair = (NSMutableDictionary *)[KeychainTool load:KEY_USERNAME];
    return [usernamepasswordKVPair objectForKey:KEY_USERNAME];
}

+(void)deleteUsernamePassword
{
    [KeychainTool delete:KEY_USERNAME];
}
@end
