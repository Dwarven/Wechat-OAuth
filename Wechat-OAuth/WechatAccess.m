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
    void(^_shareResult)(BOOL,id);
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

+ (BOOL)isWechatAppInstalled{
    return [WXApi isWXAppInstalled];
}

- (void)onReq:(BaseReq *)req{
    
}

- (void)onResp:(BaseResp *)resp{
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (0 == [resp errCode]) {
            _shareResult(YES,nil);
        } else {
            id desc = [NSNull null];
            if (-2 == [resp errCode]) {
                desc = @"ERR_USER_CANCEL";
            } else if (-4 == [resp errCode]) {
                desc = @"ERR_AUTH_DENIED";
            }
            _shareResult(NO, [NSError errorWithDomain:@"kWechatShareErrorDomain" code:resp.errCode userInfo:@{NSLocalizedDescriptionKey:desc}]);
        }
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (0 == [resp errCode]) {
            [self getUserInfoWith:[(SendAuthResp*)resp code]];
        } else {
            id desc = [NSNull null];
            if (-2 == [resp errCode]) {
                desc = @"ERR_USER_CANCEL";
            } else if (-4 == [resp errCode]) {
                desc = @"ERR_AUTH_DENIED";
            }
            _result(NO, [NSError errorWithDomain:@"kWechatOAuthErrorDomain" code:resp.errCode userInfo:@{NSLocalizedDescriptionKey:desc}]);
        }
    }
}

- (void)login:(void(^)(BOOL succeeded, id object))result{
    _result = result;
    SendAuthReq * req = [[SendAuthReq alloc] init];
    [req setScope:@"snsapi_userinfo"];
    [WXApi sendReq:req];
}

- (void)getUserInfoWith:(NSString *)code{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [manager POST:@"https://api.weixin.qq.com/sns/oauth2/access_token"
       parameters:@{@"appid" : WECHAT_APP_ID,
                    @"secret" : WECHAT_APP_SECRET,
                    @"grant_type" : @"authorization_code",
                    @"code" : code}
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              if ([responseObject isKindOfClass:[NSData class]]) {
                  responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
              }
              [manager GET:@"https://api.weixin.qq.com/sns/userinfo"
                parameters:responseObject
                   success:^(AFHTTPRequestOperation *operation,id responseObject) {
                       if ([responseObject isKindOfClass:[NSData class]]) {
                           responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                       }
                       _result(YES, responseObject);
                   } failure:^(AFHTTPRequestOperation *operation,NSError *error) {
                       
                   }];
          } failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              
          }];
}

- (void)shareWithWebviewInTimeLineOrNot:(BOOL)inOrNot
                                pageUrl:(NSString *)pageUrl
                                  title:(NSString *)title
                            description:(NSString *)description
                                  image:(UIImage *)image
                             completion:(void (^)(BOOL, id))shareResult{
    _shareResult = shareResult;
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    
    CGFloat compressionQuality = 1.f;
    NSData * imageData = UIImageJPEGRepresentation(image, compressionQuality);
    while (imageData.length > 32768) {
        if (compressionQuality > 0.2) {
            compressionQuality -= 0.2;
            imageData = UIImageJPEGRepresentation(image, compressionQuality);
        }
    }
    
    [message setThumbImage:[UIImage imageWithData:imageData]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = pageUrl;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = inOrNot ? WXSceneTimeline : WXSceneSession;
    
    [WXApi sendReq:req];
}

@end
