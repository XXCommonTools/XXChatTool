//
//  XXChatTool.m
//  Pods
//
//  Created by xby on 2017/10/19.
//
//
#import "XXChatTool.h"
#import <UserNotifications/UserNotifications.h>
@interface XXChatTool ()<EMClientDelegate,EMChatManagerDelegate,EMGroupManagerDelegate,UNUserNotificationCenterDelegate>

@property (strong, nonatomic) NSDate *lastPlaySoundDate;

@end

@implementation XXChatTool

ML_EXPORT_SERVICE(ChatTool)

#pragma mark - life cycle
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
}
+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    static XXChatTool *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[XXChatTool alloc] init];
    });
    return sharedInstance;
}

#pragma mark - private
#pragma mark - public
///初始化环信
- (void)setUpHuanXinWithAppkey:(NSString *)appkey notificationCertName:(NSString *)notificationCertName {
    
    EMOptions *options = [EMOptions optionsWithAppkey:appkey];
    options.apnsCertName = notificationCertName;
    options.isAutoLogin = YES;
    options.isAutoAcceptGroupInvitation = NO;
    options.usingHttpsOnly = YES;
    options.enableConsoleLog = NO;
    
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
}

#pragma mark - delegate
#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self registerRemoteNotification];
    
    return YES;
}
- (void)applicationDidEnterBackground:(UIApplication *)application {

    [[EMClient sharedClient] applicationDidEnterBackground:application];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {

    [[EMClient sharedClient] applicationWillEnterForeground:application];
}
#pragma mark - EMClientDelegate
- (void)didLoginFromOtherDevice {

}
#pragma mark - EMGroupManagerDelegate
#pragma mark - EMChatManagerDelegate
- (void)messagesDidReceive:(NSArray *)aMessages {
    
    
}
#pragma mark - RemoteNotification
- (void)registerRemoteNotification {

    UIApplication *application = [UIApplication sharedApplication];

    application.applicationIconBadgeNumber = 0;

    if (NSClassFromString(@"UNUserNotificationCenter")) {

        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError *error) {
            if (granted) {

#if !TARGET_IPHONE_SIMULATOR

                [application registerForRemoteNotifications];
#endif
            }
        }];
        return;
    }
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {

        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }

#if !TARGET_IPHONE_SIMULATOR
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {

        [application registerForRemoteNotifications];

    } else {

        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#endif

}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {

    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}
// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
    NSString *error_str = [NSString stringWithFormat: @"%@", error];
#ifdef DEBUG
    NSLog(@"Failed to get token, error:%@", error_str);
#endif
}
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {

    [application registerForRemoteNotifications];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [[EMClient sharedClient] bindDeviceToken:deviceToken];
    });
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    [[EMClient sharedClient] application:application didReceiveRemoteNotification:userInfo];
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {

    NSDictionary *userInfo = notification.request.content.userInfo;
    [[EMClient sharedClient] application:[UIApplication sharedApplication] didReceiveRemoteNotification:userInfo];

    //当应用处于前台时提示设置，需要哪个可以设置哪一个
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}
#pragma mark - event response

#pragma mark - getters and setters



@end
