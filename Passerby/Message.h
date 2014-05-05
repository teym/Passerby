//
//  Message.h
//  Passerby
//
//  Created by Mike on 14-4-16.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject
@property (readonly) NSString * fromUsr;
@property (readonly) NSString * fromUsrName;
@property (readonly) NSString * fromUsrImg;
@property (readonly) NSString * toUsr;
@property (readonly) NSString * toUsrName;
@property (readonly) NSString * toUsrImg;
@property (readonly) NSString * content;
@property (readonly) NSString * time;
@end
