//
//  UIViewController+StoryboardHack.m
//  Passerby
//
//  Created by Mike on 14-4-20.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import "UIViewController+StoryboardHack.h"

@implementation UIViewController (StoryboardHack)
+(void) load{
    [super load];
    ISSwizzleInstanceMethod([UIViewController class], @selector(prepareForSegue:sender:), @selector(prepareForSegue:withParam:));
    MZLOG(@"UIViewController [prepareForSegue:sender:] swizzle to [prepareForSegue:withParam:]");
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue withParam:(NSDictionary*)sender{
    [self prepareForSegue:segue withParam:sender];
    if([sender isKindOfClass:[NSDictionary class]]){
        [sender each:^(id key, id value) {
            @try {
                [segue.destinationViewController setValue:value forKeyPath:key];
            }
            @catch (NSException *exception) {
                MZLOG(@"%@",exception);
            }
        }];
    }
}
@end
