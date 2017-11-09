//
//  XXChatTool.h
//  Pods
//
//  Created by xby on 2017/10/19.
//
//

#import <Foundation/Foundation.h>
#import <MLSOAppDelegate/MLSOAppDelegate.h>
#import <HyphenateLite/HyphenateLite.h>

@interface XXChatTool: NSObject<MLAppService>

+ (instancetype)sharedInstance;
///初始化环信
- (void)setUpHuanXinWithAppkey:(NSString *)appkey notificationCertName:(NSString *)notificationCertName;

@end
