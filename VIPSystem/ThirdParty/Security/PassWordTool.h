//
//  PassWordTool.h
//
//  Created by CY on 16/1/9.
//

#import <Foundation/Foundation.h>

@interface PassWordTool : NSObject

+ (void)saveUsernamePassWord:(NSString *)username pwd: (NSString *)password;

+ (BOOL) hasKeychainSaved;

+ (NSString *)readPassword;

+ (NSString *)readUsername;

+ (void)deleteUsernamePassword;

@end
