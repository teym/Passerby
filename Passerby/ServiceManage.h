//
//  ServiceManage.h
//  Passerby
//
//  Created by Mike on 14-4-13.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserManage.h"
#import "MessageManage.h"

@interface ServiceManage : NSObject
@property (readonly) BOOL isFirstRun;
@property (readonly) BOOL serviceOn;
@property (strong) UserManage * userMgr;
@property (strong) MessageManage * msgMgr;
-(void) initService;
-(void) startService;
-(void) stopService;
@end
