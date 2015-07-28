//
//  WechatAccess.m
//  Wechat-OAuth
//
//  Created by Dwarven on 15/7/28.
//  Copyright (c) 2015年 Dwarven. All rights reserved.
//

#import "WechatAccess.h"
#import "WXApi.h"

#define WECHAT_APP_ID         @"yourappid"
#define WECHAT_APP_SECRET     @"yourappsecret"

@interface WechatAccess ()<WXApiDelegate>{
    void(^_result)(BOOL,id);
}

@end

@implementation WechatAccess

+ (WechatAccess *)defaultAccess{
    static WechatAccess * __access = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __access = [[WechatAccess alloc] init];
    });
    return __access;
}

+ (BOOL)registerApp{
    return [WXApi registerApp:WECHAT_APP_ID];
}

+ (BOOL)handleOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:[WechatAccess defaultAccess]];
}

- (void)onReq:(BaseReq *)req{
    
}

- (void)onResp:(BaseResp *)resp{
    if (0 == [resp errCode]) {
        _result(YES, [(SendAuthResp*)resp code]);
    } else {
        id desc = [NSNull null];
        if (-2 == [resp errCode]) {
            desc = @"ERR_USER_CANCEL";
        } else if (-4 == [resp errCode]) {
            desc = @"ERR_AUTH_DENIED";
        }
        _result(NO, [NSError errorWithDomain:@"kWechatResponseErrorDomain" code:resp.errCode userInfo:@{NSLocalizedDescriptionKey:desc}]);
    }
}

- (void)login:(void(^)(BOOL succeeded, id object))result{
    _result = result;
    SendAuthReq * req = [[SendAuthReq alloc] init];
    [req setScope:@"snsapi_userinfo"];
    [WXApi sendReq:req];
}

@end
