//
//  AppDelegate.h
//  Passerby
//
//  Created by Mike on 14-4-9.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "ServiceManage.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong) ServiceManage * manage;
@end

#define TheApplication [UIApplication sharedApplication]
#define TheAppDelegate ((AppDelegate*)[TheApplication delegate])
#define TheRootController ((RootViewController*)[[TheAppDelegate window] rootViewController])
#define TheServiceManage [TheAppDelegate manage]
#define TheUserManage  [TheServiceManage userMgr]
#define TheMsgManage  [TheServiceManage msgMgr]