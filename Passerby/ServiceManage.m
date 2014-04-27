//
//  ServiceManage.m
//  Passerby
//
//  Created by Mike on 14-4-13.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import "ServiceManage.h"
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
    }
    return self;
}
#pragma mark -- action
-(void) initService{
    id keys = [[FXKeychain defaultKeychain] objectForKey:@"keyPair"];
    _isFirstRun = !keys;
    self.keys = keys;
}
-(void) saveKeys{
    [[FXKeychain defaultKeychain] setObject:self.keys forKey:@"keyPair"];
}
-(void) startService{
    [self saveKeys];
    [self.netService startService:@{}];
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
