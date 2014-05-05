//
//  MessageManage.h
//  Passerby
//
//  Created by Mike on 14-4-13.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

@class User;
@interface MessageManage : NSObject
@property (readonly) NSArray * messages;
-(Message*) createMessage:(NSString*) content;
-(Message*) message:(NSString*) content toUsr:(User*) user;
-(void) addMessage:(Message*) message;
@end

@interface MessageManage (coder)
-(id) encodeMessage:(Message*) msg;
-(Message*) decodeMessage:(id) data;
@end