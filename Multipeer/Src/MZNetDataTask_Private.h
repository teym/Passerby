//
//  MZNetDataTask_Private.h
//  Multipeer
//
//  Created by Mike on 14-4-8.
//  Copyright (c) 2014年 Mike. All rights reserved.
//

#import "MZNetDataTask.h"
#import "MZPackage.h"

@interface MZNetDataTask ()
@property (copy) void(^sendFinalBlock)();
@property (readonly,strong) NSString * sendPackName;
-(id) initWithRequest:(MZRequest*) request;
-(id) initWithResponse:(MZResponse*) response;
-(MZPackage *) packageWillSend;
@end
