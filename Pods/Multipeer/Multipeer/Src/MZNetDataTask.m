//
//  MZNetDataTask.m
//  Multipeer
//
//  Created by Mike on 14-3-30.
//  Copyright (c) 2014年 Mike. All rights reserved.
//

#import "MZNetDataTask.h"
#import "MZNetDataTask_Private.h"
#import "MZRequest.h"
#import "MZResponse.h"

@implementation MZNetDataTask
-(id) initWithRequest:(MZRequest*) request{
    self = [super init];
    if(self){
        _request = request;
        _sendPackName = @"request";
    }
    return self;
}
-(id) initWithResponse:(MZResponse*) response{
    self = [super init];
    if(self){
        _response = response;
        _sendPackName = @"response";
    }
    return self;
}
-(MZPackage *) packageWillSend{
    if([self.sendPackName isEqualToString:@"request"])
        return self.request;
    return self.response;
}
@end
