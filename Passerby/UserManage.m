//
//  UserManage.m
//  Passerby
//
//  Created by Mike on 14-4-13.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import "UserManage.h"

@interface User ()
@property (strong) NSString * iden;
@property (strong) NSString * name;
@property (strong) NSString * sex;
@property (strong) NSString * logo;
@property (strong) NSString * des;
@end

@implementation UserManage
-(id) init{
    self = [super init];
    if(self){
        self.myself = [User new];
    }
    return self;
}
-(void) updateName:(NSString*) name{
    self.myself.name = name;
    [self saveMyself];
}
-(void) updateLogo:(NSString *) image{
    self.myself.logo = [self saveUsrLogo:image];
    [self saveMyself];
}
-(void) updateDes:(NSString*) des{
    
}
-(NSString*) saveUsrLogo:(NSString*)image{
    return @"";
}
-(void) saveMyself{
    
}
@end

@implementation User

@end