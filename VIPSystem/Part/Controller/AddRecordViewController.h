//
//  AddRecordViewController.h
//  VIPSystem
//
//  Created by Channe Sun on 2017/10/25.
//  Copyright © 2017年 Omnivision. All rights reserved.
//

#import "BaseViewController.h"

@interface AddRecordViewController : BaseViewController

@property (nonatomic, assign)long userID;
@property (nonatomic, strong)QMUIPopupMenuView *popupMenuView;
@property (nonatomic, copy)void (^refresh)(void);

@end
