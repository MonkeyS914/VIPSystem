//
//  EditViewController.h
//  VIPSystem
//
//  Created by Channe Sun on 2017/10/27.
//  Copyright © 2017年 Omnivision. All rights reserved.
//

#import "BaseViewController.h"

@interface EditViewController : BaseViewController

@property (nonatomic, strong)MemObj *userObj;
@property (nonatomic, copy)void (^refresh)(void);

@end
