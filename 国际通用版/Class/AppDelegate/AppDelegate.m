//
//  AppDelegate.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/8.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "AppDelegate.h"
#import "TabBarViewController.h"
#import "XMGNavigationController.h"
#import "LaunchScreenViewController.h"
#import "HTMLBaseViewController.h"
#import "LoginAnfRegisterVC.h"


#define STOREAPPID @"1113948983"
@interface AppDelegate ()
@property (nonatomic , strong) UIAlertController *alertVC;
@property (nonatomic , strong) UIAlertController *alertController;
@property (nonatomic , strong) UserModel *userModel;
@property (nonatomic , strong) ServicesModel *serviceModel;
@property (nonatomic , strong) UILabel *noNetwork;
@property (nonatomic , strong) UIView *markview;
#pragma mark - 0 没网 1 有网
@property (nonatomic , assign) BOOL noNetWorkStr;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UIViewController alloc]init];
    [self.window makeKeyAndVisible];
    self.noNetWorkStr = 1;
        
    NSLog(@"%f , %f" , kScreenW , kScreenH);
    
    _alertController = nil;
    
    [self setRootViewController];
    [self chaXunBanBenHao];
    [[CZNetworkManager shareCZNetworkManager]checkNetWork];
    return YES;
}

- (void)chaXunBanBenHao {
    [kNetWork requestGETUrlString:kChaXunBanBenHao parameters:@{@"type" : @(2)} isSuccess:^(NSDictionary * _Nullable responseObject) {
        NSDictionary *data = responseObject[@"data"];
        if ([responseObject[@"success"] integerValue] == 1) {
            if ([data[@"isForce"] isKindOfClass:[NSNull class]]) {return ; } else {
                if ([data[@"id"] integerValue] > 64) {
                    
                    if ([data[@"isForce"] integerValue] == 0) return ;
                    if ([data[@"isForce"] integerValue] == 1) {
                        [self wheatherUpdate:@"您当前的版本过低，无法使用请更新！"];
                    } else {
                        [self wheatherUpdate:@"检查到有新的版本，是否更新?"];
                    }
                }
            }
        }
    } failure:^(NSError * _Nonnull error) {
        [kNetWork noNetWork];
    }];
    
}
- (UILabel *)addNoNetLabel {
    UILabel *noNetWork = [UILabel creatLableWithTitle:@"❗️当前网络不可用，请检查手机网络" andSuperView:kWindowRoot.view andFont:k13 andTextAligment:NSTextAlignmentCenter];
    [noNetWork mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW, kScreenW / 15));
        make.centerX.mas_equalTo(kWindowRoot.view  .mas_centerX);
        make.top.mas_equalTo(kHeight);
    }];
    
    noNetWork.textColor = [UIColor colorWithHexString:@"ef6060"];
    noNetWork.backgroundColor = [UIColor colorWithHexString:@"ffdcdc"];
    noNetWork.layer.borderWidth = 0;
    noNetWork.layer.cornerRadius = 0;
    noNetWork.hidden = YES;
    
    UIView *markview = [[UIView alloc]initWithFrame:self.window.bounds];
    [kWindowRoot.view addSubview:markview];
    markview.backgroundColor = [UIColor clearColor];
    markview.hidden = YES;
    self.markview = markview;
    
    return noNetWork;
}

- (void)setRootViewController {
    
    if ([kStanderDefault objectForKey:@"Login"]) {
        self.window.rootViewController = [[TabBarViewController alloc]init];
    } else {
        LoginAnfRegisterVC *loginAngRegisterVC = [[LoginAnfRegisterVC alloc]init];
        XMGNavigationController *nav = [[XMGNavigationController alloc]initWithRootViewController:loginAngRegisterVC];
        
        self.window.rootViewController = nav;
    }
    
    
//    NSString *isLaunchLoad = [kStanderDefault objectForKey:@"isLaunch"];
//    if ([isLaunchLoad isEqualToString:@"NO"]) {
//        [kStanderDefault setObject:@"NO" forKey:@"firstRun"];
//        if ([kStanderDefault objectForKey:@"Login"]) {
//            self.window.rootViewController = [[TabBarViewController alloc]init];
//        } else {
//            LoginAnfRegisterVC *loginAngRegisterVC = [[LoginAnfRegisterVC alloc]init];
//            XMGNavigationController *nav = [[XMGNavigationController alloc]initWithRootViewController:loginAngRegisterVC];
//            self.window.rootViewController = nav;
//        }
//    } else {
//        self.window.rootViewController = [[LaunchScreenViewController alloc]init];
//    }
    self.noNetwork = [self addNoNetLabel];
}

- (void)wheatherUpdate:(NSString *)title {
    [UIAlertController creatCancleAndRightAlertControllerWithHandle:^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/app/id%@?ls=1&mt=8", STOREAPPID]];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } andSuperViewController:kWindowRoot Title:title];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"程序将要进入非活动状态");
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[Singleton sharedInstance] enableBackgroundingOnSocket];
  
    NSLog(@"程序进入后台后执行");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    NSLog(@"程序将要进入前台时执行");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"程序被激活（获得焦点）后执行");
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSInteger nowTime = [NSString getNowTimeInterval];
    NSString *endTime = [kStanderDefault objectForKey:@"endTime"];
    
    if (nowTime > endTime.integerValue + 3600 * 2 && endTime != nil) {
        [self setRootViewController];
        [kStanderDefault removeObjectForKey:@"endTime"];
    }
    
    [self setUpEnterForeground];
    
}

- (void)setUpEnterForeground {
    if (self.userModel && self.serviceModel) {
        
        [kSocketTCP cutOffSocket];
        kSocketTCP.userSn = [NSString stringWithFormat:@"%ld" , (long)_userModel.sn];
        [kSocketTCP socketConnectHost];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [kSocketTCP sendDataToHost:[NSString stringWithFormat:@"HM%ld%@%@N#" , (long)self.userModel.sn , _serviceModel.devTypeSn , _serviceModel.devSn] andType:kAddService andIsNewOrOld:nil];
        });
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"程序在终止时执行");
    
    [kSocketTCP cutOffSocket];
    
    NSString *endTime = [NSString stringWithFormat:@"%ld" , [NSString getNowTimeInterval]];
    [kStanderDefault setObject:endTime forKey:@"endTime"];
    
}

- (void)initUserModel:(UserModel *)userModel {
    
    self.userModel = [[UserModel alloc]init];
    self.userModel = userModel;
}

- (void)initServiceModel:(ServicesModel *)serviceModel {
    self.serviceModel = [[ServicesModel alloc]init];
    self.serviceModel = serviceModel;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
