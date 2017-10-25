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
///环信appKey
@property (copy,nonatomic) NSString *appKey;
///环信通知证书名字
@property (copy,nonatomic) NSString *notifcationCertName;


@end
