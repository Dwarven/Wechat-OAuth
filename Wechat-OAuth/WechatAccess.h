//
//  WechatAccess.h
//  Wechat-OAuth
//
//  Created by Dwarven on 15/7/28.
//  Copyright (c) 2015年 Dwarven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WechatAccess : NSObject

+ (WechatAccess *)defaultAccess;;

+ (BOOL)registerApp;

+ (BOOL)handleOpenURL:(NSURL *)url;

- (void)login:(void(^)(BOOL succeeded, id object))result;

- (void)shareWithWebviewInTimeLineOrNot:(BOOL)inOrNot
                                pageUrl:(NSString *)pageUrl
                                  title:(NSString *)title
                            description:(NSString *)description
                                  image:(UIImage *)image
                             completion:(void(^)(BOOL succeeded, id object))shareResult;

@end
