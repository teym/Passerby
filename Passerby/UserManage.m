//
//  UserManage.m
//  Passerby
//
//  Created by Mike on 14-4-13.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import "UserManage.h"

@implementation UserManage
-(id) init{
    self = [super init];
    if(self){
        self.myself = [User new];
    }
    return self;
}
@end
