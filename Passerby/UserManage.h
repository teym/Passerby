//
//  UserManage.h
//  Passerby
//
//  Created by Mike on 14-4-13.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserManage : NSObject
@property (strong) User * myself;
-(void) updateName:(NSString*) name;
-(void) updateLogo:(NSString *) image;
-(void) updateDes:(NSString*) des;
@end

@interface UserManage (coder)
-(id) encodeUser:(User*) user;
-(User*) decodeUser:(id)data;
@end