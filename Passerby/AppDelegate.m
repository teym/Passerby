//
//  AppDelegate.m
//  Passerby
//
//  Created by Mike on 14-4-9.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.manage = [[ServiceManage alloc] init];
    [self.manage initService];
    [self showPrepareWithFinish:^{
        [self onReady];
    }];
    return YES;
}
-(RACSignal*) firstRunActions{
    RACSignal * keySignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [TheServiceManage makeKeyPair:^(id obj) {
            [subscriber sendNext:obj];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    RACSignal *nameSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [TheRootController performSegueWithIdentifier:@"showWelcome" sender:@{@"FinalBlock":^(id obj){
            [subscriber sendNext:obj];
            [subscriber sendCompleted];
        }}];
        return nil;
    }];
    return [keySignal combineLatestWith:nameSignal];
}
-(void) showPrepareWithFinish:(void(^)())block{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.manage.isFirstRun){
            [[self firstRunActions] subscribeNext:^(id x) {
                RACTupleUnpack(id keys,NSString* name)= x;
                [self.manage ready:keys name:name];
            } completed:^{
                [TheRootController dismissViewControllerAnimated:YES completion:nil];
                block();
            }];
        }else{
            block();
        }
    });
}
-(void) onReady{
    [self.manage startService];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
