//
//  KeyManage.h
//  Passerby
//
//  Created by Mike on 14-5-3.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyManage : NSObject
-(void) generateKeyPair:(void(^)(NSString*,NSString*)) block;
-(SecKeyRef) publicKey;
-(SecKeyRef) privateKey;
-(SecKeyRef) keyRefFromBase64String:(NSString*) str;
@end
