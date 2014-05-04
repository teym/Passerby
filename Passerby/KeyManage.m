//
//  KeyManage.m
//  Passerby
//
//  Created by Mike on 14-5-3.
//  Copyright (c) 2014年 xiami. All rights reserved.
//

#import "KeyManage.h"
#import <PKCS.h>
NSString * const PrivateKeyTag = @"MZ.Mike.key.private";
NSString * const PublicKeyTag = @"MZ.Mike.key.public";

@implementation KeyManage
-(void) generateKeyPair:(void(^)(NSString*,NSString*)) block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL ret = PKCSGenerateKeyPair(PublicKeyTag, PrivateKeyTag, [NSNumber numberWithUnsignedInteger:1024], YES);
        if(ret){
            NSData* publicData = PKCSLoadRSAKeyData(kSecClassKey, PublicKeyTag);
            NSData* privateData = PKCSLoadRSAKeyData(kSecClassKey, PrivateKeyTag);
            NSAssert(publicData&&privateData, @"load key data error");
            NSString * pubKeyStr = [publicData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            NSString * priKeyStr = [privateData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            dispatch_async(dispatch_get_main_queue(), ^{
                block(pubKeyStr,priKeyStr);
            });
        }
    });
}
-(SecKeyRef) publicKey{
    return PKCSLoadRSAKey(kSecClassKey, PublicKeyTag);
}
-(SecKeyRef) privateKey{
    return PKCSLoadRSAKey(kSecClassKey, PrivateKeyTag);
}
-(SecKeyRef) keyRefFromBase64String:(NSString*) str{
    SecKeyRef keyRef = NULL;
    NSData * data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSAssert(data, @"empty key data");
    BOOL ret = PKCSSaveRSAKey(kSecClassKey, data, str, YES);
    if(ret){
        keyRef = PKCSLoadRSAKey(kSecClassKey, str);
    }
    ret = PKCSDeleteRSAKey(kSecClassKey, str);
    return keyRef;
}
@end
