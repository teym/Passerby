//
//  ServiceManage.m
//  Passerby
//
//  Created by Mike on 14-4-13.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import "AppDelegate.h"
#import <MZNetService.h>
#import <FXKeychain.h>

@interface ServiceManage ()<MZNetServiceDelegate>
@property (strong) MZNetService * netService;
@property (strong) id keys;
@end
@implementation ServiceManage
-(id) init{
    self = [super init];
    if(self){
        self.userMgr = [UserManage new];
        self.msgMgr = [MessageManage new];
        self.netService = [MZNetService new];
        self.netService.delegate = self;
    }
    return self;
}
#pragma mark -- action
-(void) ready:(id)keys name:(NSString *)name{
    self.keys = keys;
    self.userMgr.myself = [[User alloc] init];
    self.userMgr.myself.name = name;
}
-(void) initService{
    id keys = [[FXKeychain defaultKeychain] objectForKey:@"keyPair"];
    _isFirstRun = !keys;
    self.keys = keys;
}
-(void) saveKeys{
    if(self.keys)
        [[FXKeychain defaultKeychain] setObject:self.keys forKey:@"keyPair"];
}
-(void) startService{
    [self.netService startService:@{@"name":TheUserManage.myself.name}];
}
-(void) stopService{
    [self.netService stopService];
}
#pragma mark -- delegate
-(BOOL) shouldConnect:(MZPeer *)peer type:(NSString *)type{
    return YES;
}
-(void) onNewPeer:(MZPeer *)peer type:(NSString *)type{
    if([type isEqualToString:@"inviter"]){
        
    }else if([type isEqualToString:@"advertiser"]){
        
    }
}
-(void) onRequest:(MZRequest *)request fromPeer:(MZPeer *)peer{
    
}
@end
@implementation ServiceManage (Keys)
-(void) makeKeyPair:(void(^)(id)) block{
    [self.keyMgr generateKeyPair:^(NSString * pub, NSString *pri) {
        if(pub&&pri){
            
        }
        block(@{@"public":pub,@"private":pri});
    }];
}
@end