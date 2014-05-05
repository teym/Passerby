//
//  MZPeer.h
//  Multipeer
//
//  Created by Mike on 3/26/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{PeerUnConnected,PeerConnecting,PeerConnected} PeerStatus;
@class MCPeerID;
@interface MZPeer : NSObject
-(id) initWithName:(NSString*) name info:(NSDictionary*) info;
-(id) initWithPeer:(MCPeerID*)peer info:(NSDictionary *)info;
@property (readonly) MCPeerID * peer;
@property (readonly) NSString * name;
@property (strong) NSDictionary * discoveryInfo;
@property (assign) PeerStatus status;
@end
