//
//  ServiceManage.m
//  Passerby
//
//  Created by Mike on 14-4-13.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import "ServiceManage.h"
#import <MZNetService.h>

@interface ServiceManage ()<MZNetServiceDelegate>
@property (strong) MZNetService * netService;
@end
@implementation ServiceManage
-(id) init{
    self = [super init];
    if(self){
        
    }
    return self;
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
