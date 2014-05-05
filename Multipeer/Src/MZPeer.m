//
//  MZPeer.m
//  Multipeer
//
//  Created by Mike on 3/26/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "MZPeer.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@implementation MZPeer
-(id) initWithName:(NSString*) name info:(NSDictionary*) info{
    self = [super init];
    if(self){
        _name = name;
        _discoveryInfo = info;
        _status = PeerUnConnected;
    }
    return self;
}
-(id) initWithPeer:(MCPeerID *)peer info:(NSDictionary *)info{
    self = [super init];
    if(self){
        _peer = peer;
        _name = peer.displayName;
        _discoveryInfo = info;
        _status = PeerUnConnected;
    }
    return self;
}
@end
