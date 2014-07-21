//
//  MessageCell.h
//  Passerby
//
//  Created by Mike on 14-5-5.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Message;
@interface MessageCell : UICollectionViewCell
@property (weak) IBOutlet UIImageView * usrImg;
@property (weak) IBOutlet UILabel * usrName;
@property (weak) IBOutlet UILabel * time;
@property (weak) IBOutlet UILabel * content;
-(void) configWithMessage:(Message*) msg;
@end
