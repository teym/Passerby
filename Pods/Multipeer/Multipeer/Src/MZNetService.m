//
//  MZNetService.m
//  Multipeer
//
//  Created by Mike on 14-3-29.
//  Copyright (c) 2014年 Mike. All rights reserved.
//

#import "MZNetService.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "MZRequest.h"
#import "MZResponse.h"
#import "MZNetDataTask.h"
#import "MZPeer.h"
#import "MZNetDataTask_Private.h"
#import <NSArray+Funcussion.h>

#define ServiceType @"MZ-pub"

@interface MZPackage (Ptotocal)
+(instancetype) packageWithData:(NSData*) data;
+(instancetype) packageWithHeadString:(NSString *)str;
+(NSData*) makeSendData:(MZPackage*) pack;
+(NSString*) makeStandHeadString:(MZPackage*) pack;
@end

@interface MZNetService ()<MCSessionDelegate,MCNearbyServiceAdvertiserDelegate,MCNearbyServiceBrowserDelegate>
@property (strong) dispatch_queue_t sendQueue;
@property (strong) dispatch_queue_t processQueue;
@property (strong) NSMutableDictionary * connectedPeers;
@property (strong) MZPeer * peer;
@property (strong) MCSession * session;
@property (strong) MCNearbyServiceAdvertiser * advertiser;
@property (strong) MCNearbyServiceBrowser * browser;

@property (strong) NSMutableArray * sendingQueue;
@property (strong) NSMutableDictionary * sendedQueue;
@property (strong) MZNetDataTask * currentSending;
@property (strong) NSMutableDictionary * fileRecving;
@end

@implementation MZNetService
-(id) init{
    self = [super init];
    if(self){
        _allPeers = [NSMutableArray array];
        self.sendQueue = dispatch_queue_create("mz-send", DISPATCH_QUEUE_SERIAL);
        self.processQueue = dispatch_queue_create("mz-process", DISPATCH_QUEUE_SERIAL);
        self.sendingQueue = [NSMutableArray array];
        self.sendedQueue = [NSMutableDictionary dictionary];
        self.fileRecving = [NSMutableDictionary dictionary];
        self.connectedPeers = [NSMutableDictionary dictionary];
    }
    return self;
}
-(NSString*) getSelfIden{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}
-(void) startService:(NSDictionary *)info{
    self.peer = [[MZPeer alloc] initWithPeer:[[MCPeerID alloc] initWithDisplayName:[self getSelfIden]] info:info];
    self.session = [[MCSession alloc] initWithPeer:self.peer.peer];
    self.session.delegate = self;
    
    self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peer.peer discoveryInfo:info serviceType:ServiceType];
    self.advertiser.delegate = self;
    
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peer.peer serviceType:ServiceType];
    self.browser.delegate = self;
    
    [self.browser startBrowsingForPeers];
    [self.advertiser startAdvertisingPeer];
}
-(void) stopService{
    self.advertiser.delegate = nil;
    [self.advertiser stopAdvertisingPeer];
    self.browser.delegate = nil;
    [self.browser startBrowsingForPeers];
    self.session.delegate = nil;
    [self.session disconnect];
    //clean request recving peers
}
-(void) taskWaitResponse:(MZNetDataTask*) task{
    [self.sendedQueue setObject:task forKey:task.request.resource];
    self.currentSending = nil;
    [self startNext];
}
-(void) taskFinish:(MZNetDataTask*) task{
    if(task == self.currentSending){
        self.currentSending = nil;
    }else{
        [self.sendedQueue removeObjectForKey:task.request.resource];
    }
    task.finalBlock(task.request,task.response,task.error);
    [self startNext];
}
-(MZNetDataTask*) request:(MZRequest*) request withFinalBlock:(void(^)(MZRequest*request,MZResponse* response,NSError*error)) block{
    MZNetDataTask * task = [[MZNetDataTask alloc] initWithRequest:request];
    task.finalBlock = block;
    __weak id wtask = task;
    task.sendFinalBlock = ^(){
        [self taskWaitResponse:wtask];
    };
    task.progress = [NSProgress progressWithTotalUnitCount:200];
    dispatch_async(self.processQueue, ^{
    [self startTask:task];
    });
    return task;
}

-(MZNetDataTask*) response:(MZResponse*) respons forRequest:(MZRequest*)request withFinalBlock:(void(^)(MZRequest*request,MZResponse* response,NSError*error))block{
    MZNetDataTask * task = [[MZNetDataTask alloc] initWithResponse:respons];
    task.request = request;
    task.finalBlock = block;
    __weak id wtask = task;
    task.sendFinalBlock = ^(){
        [self taskFinish:wtask];
    };
    task.progress = [NSProgress progressWithTotalUnitCount:100];
    dispatch_async(self.processQueue, ^{
        [self startTask:task];
    });
    return task;
}
-(void) startNext{
    if(self.currentSending==nil){
        MZNetDataTask * task = self.sendingQueue.firstObject;
        if(task)
            [self startTaskSending:task];
    }
}
-(void) startTask:(MZNetDataTask*) task{
    [self.sendingQueue addObject:task];
    [self startNext];
}
-(void) onPeer:(MCPeerID*)peerID changeState:(MCSessionState) state{
    MZPeer * peer = [self.connectedPeers objectForKey:peerID.displayName];
    switch (state) {
        case MCSessionStateConnecting:
            peer.status = PeerConnecting;
            break;
        case MCSessionStateConnected:
            peer.status = PeerConnected;
            break;
        case MCSessionStateNotConnected:
            peer.status = PeerUnConnected;
            [self.connectedPeers removeObjectForKey:peerID.displayName];
        default:
            break;
    }
}
-(void) onPeerLost:(MCPeerID*)peerID{
    MZPeer * peer = [self.connectedPeers objectForKey:peerID.displayName];
    peer.status = PeerUnConnected;
    [self.connectedPeers removeObjectForKey:peer.name];
}
-(void) onNewPeer:(MCPeerID*)peerID info:(id) info type:(NSString*)type{
    MZPeer * peer = [self.connectedPeers objectForKey:peerID.displayName];
    if(!peer){
        peer = [[MZPeer alloc] initWithPeer:peerID info:info];
    }else{
        peer.discoveryInfo = info;
    }
    peer.status = PeerConnecting;
    [self.connectedPeers setObject:peer forKey:peer.name];
    [self.delegate onNewPeer:peer type:type];
}
-(void) onRequest:(MZRequest *) request from:(MCPeerID *) peerID{
    MZPeer * peer = [self.connectedPeers objectForKey:peerID.displayName];
    [self.delegate onRequest:request fromPeer:peer];
}
-(void) onTaskBeginSend:(MZNetDataTask*) task withPeers:(NSArray*) peers{
    
}
-(void) onTaskEndSend:(MZNetDataTask*) task withPeers:(NSArray*) peers error:(NSError*) error{
    NSAssert(task== self.currentSending, @"error not current task end");
    task.error = error;
    task.sendFinalBlock();
}
-(void) onPackBeginRecv:(MZPackage*) pack withPeer:(MCPeerID*) peerID process:(NSProgress*) process{
    if([pack isKindOfClass:[MZResponse class]]){
        MZNetDataTask * task = [self.sendedQueue objectForKey:pack.resource];
        task.response = (MZResponse*)pack;
    }
}
-(void) onPackEndRecv:(MZPackage*) pack withPeer:(MCPeerID*) peerID error:(NSError*) error{
    if([pack isKindOfClass:[MZResponse class]]){
        MZNetDataTask * task = [self.sendedQueue objectForKey:pack.resource];
        NSAssert(task.response == pack, @"response error");
        task.response = (MZResponse*)pack;
        task.error = error;
    }else{
        [self onRequest:(MZRequest*)pack from:peerID];
    }
}
-(NSArray *) getPeersWillSend:(MZPackage*) pack{
    NSArray * ret = nil;
    if(pack.peerName){
        MZPeer * peer = [self.connectedPeers objectForKey:pack.peerName];
        if(peer){
            ret = @[peer.peer];
        }
    }else if ([pack.method isEqualToString:@"Broadcast"]){
        ret = [[self.connectedPeers allValues] map:^id(MZPeer* obj) {
            return obj.peer;
        }];
    }
    return ret;
}
-(void) startTaskSending:(MZNetDataTask*) task{
    NSAssert(task == self.sendingQueue.firstObject, @"sending order error");
    [self.sendingQueue removeObjectAtIndex:0];
    self.currentSending = task;
    task.progress.completedUnitCount+=50;
    BOOL isFile = ([task packageWillSend].localFile != nil);
    if(isFile){
        [self sendFileTask:task];
    }else{
        [self sendDataTask:task];
    }
}
-(void) sendDataTask:(MZNetDataTask*) task{
    MZPackage * pack = [task packageWillSend];
    NSData * data = [MZPackage makeSendData:pack];
    NSArray * peers = [self getPeersWillSend:pack];
    [task.progress becomeCurrentWithPendingUnitCount:50];
    NSProgress * progress = [NSProgress progressWithTotalUnitCount:100];
    [task.progress resignCurrent];
    [self onTaskBeginSend:task withPeers:peers];
    dispatch_async(self.sendQueue, ^{
        NSError * error = nil;
        BOOL ret = [self.session sendData:data toPeers:peers withMode:MCSessionSendDataReliable error:&error];
        dispatch_async(self.processQueue, ^{
            progress.completedUnitCount = 100;
            NSLog(@"send pack:%@ result:%d error:%@",pack.resource,ret,error);
            [self onTaskEndSend:task withPeers:peers error:error];
        });
    });
}
-(void) sendFileTask:(MZNetDataTask*) task{
    MZPackage * pack = [task packageWillSend];
    NSString * fileName = [MZPackage makeStandHeadString:pack];
    NSURL * file = [[task packageWillSend] localFile];
    NSArray * peers = [self getPeersWillSend:pack];
    [self onTaskBeginSend:task withPeers:peers];
    dispatch_async(self.sendQueue, ^{
        [task.progress becomeCurrentWithPendingUnitCount:50];
        NSProgress * process = [self.session sendResourceAtURL:file withName:fileName toPeer:peers.firstObject withCompletionHandler:^(NSError *error) {
            NSLog(@"progress parent:%@",process);
            dispatch_async(self.processQueue, ^{
                NSLog(@"send resource:%@ error:%@",file,error);
                [self onTaskEndSend:task withPeers:peers error:error];
            });
        }];
        [task.progress resignCurrent];
        dispatch_async(self.processQueue, ^{
            [self onTaskBeginSend:task withPeers:peers];
        });
    });
}
#pragma mark - MCSessionDelegate protocol conformance

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    dispatch_async(self.processQueue, ^{
        [self onPeer:peerID changeState:state];
    });
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    dispatch_async(self.processQueue, ^{
        MZPackage * pack = [MZPackage packageWithData:data];
        pack.peerName = peerID.displayName;
        [self onPackBeginRecv:pack withPeer:peerID process:nil];
        [self onPackEndRecv:pack withPeer:peerID error:nil];
    });
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    dispatch_async(self.processQueue, ^{
        MZPackage * pack = [MZPackage packageWithHeadString:resourceName];
        pack.peerName = peerID.displayName;
        [self onPackBeginRecv:pack withPeer:peerID process:progress];
    });
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    dispatch_async(self.processQueue, ^{
        MZPackage * pack = [MZPackage packageWithHeadString:resourceName];
        pack = [self.fileRecving objectForKey:pack.resource];
        NSAssert([pack.peerName isEqualToString:peerID.displayName], @"peer error");
        pack.peerName = peerID.displayName;
        pack.localFile = localURL;
        [self onPackEndRecv:pack withPeer:peerID error:error];
    });
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    //    NSLog(@"didReceiveStream %@ from %@", streamName, peerID.displayName);
}

#pragma mark - MCNearbyServiceBrowserDelegate protocol conformance

- (void) checkPeer:(MCPeerID*) peer info:(id)info type:(NSString*)type withBlock:(void(^)(BOOL))block{
    MZPeer * newPeer = [[MZPeer alloc] initWithPeer:peer info:info];
    BOOL ret = [self.delegate shouldConnect:newPeer type:type];
    block(ret);
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    dispatch_async(self.processQueue, ^{
        [self checkPeer:peerID info:info type:@"inviter" withBlock:^(BOOL invite) {
            if(invite){
                NSData * data = nil;
                if(self.peer.discoveryInfo){
                    data = [NSJSONSerialization dataWithJSONObject:self.peer.discoveryInfo options:NSJSONWritingPrettyPrinted error:nil];
                }
                [browser invitePeer:peerID toSession:self.session withContext:data timeout:30.0];
                [self onNewPeer:peerID info:info type:@"inviter"];
            }
        }];
    });
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    dispatch_async(self.processQueue, ^{
        [self onPeerLost:peerID];
    });
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"didNotStartBrowsingForPeers: %@", error);
}

#pragma mark - MCNearbyServiceAdvertiserDelegate protocol conformance

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    dispatch_async(self.processQueue, ^{
        id info = nil;
        if(context){
            info = [NSJSONSerialization JSONObjectWithData:context options:NSJSONReadingMutableLeaves error:nil];
        }
        [self checkPeer:peerID info:info type:@"advertiser" withBlock:^(BOOL recv) {
            invitationHandler(recv, self.session);
            [self onNewPeer:peerID info:info type:@"advertiser"];
        }];
    });
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"didNotStartAdvertisingForPeers: %@", error);
}
@end


@implementation MZPackage (Ptotocal)
+(instancetype) packageWithData:(NSData*) data{
    NSArray * arr = [self splitHeadAndContent:data];
    NSAssert(arr.count==2, @"parse error");
    NSDictionary * dict = [self getStandHead:[[NSString alloc] initWithData:arr.firstObject encoding:NSUTF8StringEncoding]];
    MZPackage* result = [self objWithHeadInfo:dict];
    result.data = arr.lastObject;
    return result;
}
+(instancetype) packageWithHeadString:(NSString *)str{
    NSDictionary * dict = [self getStandHead:str];
    return [self objWithHeadInfo:dict];
}
+(instancetype) objWithHeadInfo:(NSDictionary*) dict{
    if(!dict) return nil;
    MZPackage * result = nil;
    if([[dict objectForKey:@"Type"] isEqualToString:@"Request"]){
        result = [[MZRequest alloc] init];
    }else{
        result = [[MZResponse alloc] init];
    }
    result.method = [dict objectForKey:@"Method"];
    result.resource = [dict objectForKey:@"Resource"];
    result.MIMEType = [dict objectForKey:@"MIMEType"];
    result.info = [dict objectForKey:@"Info"];
    return result;
}
+(NSString*) makeStandHeadString:(MZPackage*) pack{
    return [NSString stringWithFormat:@"{%@}",[self makeHeadString:pack]];
}
+(NSData*) makeSendData:(MZPackage*) pack{
    NSAssert(pack.data, @"only send data can use this method");
    NSString * head = [self makeStandHeadString:pack];
    NSMutableData * data = [NSMutableData dataWithData:[head dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:pack.data];
    return data;
}
+(NSDictionary *) getStandHead:(NSString*) headStr{
    NSAssert([headStr hasPrefix:@"{{"]&&[headStr hasSuffix:@"}}"], @"protocal error");
    NSData * data = [[headStr substringWithRange:NSMakeRange(1, headStr.length-2)] dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    return obj;
}


#pragma mark --help
+(NSString*) makeHeadString:(MZPackage*) pack{
    NSString * type = [pack isKindOfClass:[MZRequest class]]?@"Request":@"Response";
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    if(pack.info){
        [dict setValue:pack.info forKey:@"Info"];
    }
    [dict addEntriesFromDictionary: @{@"Type":type,@"Method":pack.method,@"Resource":pack.resource,@"MIMEType":pack.MIMEType}];
    NSError * error = nil;
    NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
+(NSArray *) splitHeadAndContent:(NSData *) data{
    NSData * head = nil;
    NSData * content = nil;
    NSData * spliter = [@"}}" dataUsingEncoding:NSUTF8StringEncoding];
    NSRange range = [data rangeOfData:spliter options:NSDataSearchAnchored range:NSMakeRange(0, data.length)];
    if(range.location != NSNotFound){
        head = [data subdataWithRange:NSMakeRange(0, range.location+range.length)];
        content = [data subdataWithRange:NSMakeRange(range.location+range.length, data.length-(range.location+range.length))];
        return @[head,content];
    }
    return nil;
}
@end
