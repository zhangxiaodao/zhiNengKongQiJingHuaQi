//
//  searchServicesViewController.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/26.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "SearchServicesViewController.h"
#import "FailContextViewController.h"
#import "AsyncUdpSocket.h"
#import "MineSerivesViewController.h"

#import "LXGradientProcessView.h"

#import "ESPTouchTask.h"
#import "ESPTouchResult.h"
#import "ESP_NetUtil.h"
#import "ESPTouchDelegate.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface SearchServicesViewController ()<AsyncUdpSocketDelegate>
@property (atomic, strong) ESPTouchTask *_esptouchTask;
@property (nonatomic, strong) NSCondition *_condition;

@property (nonatomic , strong) AsyncUdpSocket *updSocket;

@property (nonatomic , copy) NSString *devTypeSn;
@property (nonatomic, strong) LXGradientProcessView *processView;
@property (nonatomic , strong) NSTimer *progressTimer;
@property (nonatomic , strong) NSTimer *repeatSendTimer;

@property (nonatomic , assign) CGFloat index;

@property (nonatomic , assign) NSInteger count;
@property (nonatomic , assign) NSInteger num;

@property (nonatomic , strong) UILabel *searchLable;
@property (nonatomic , strong) UILabel *registerLable;
@property (nonatomic , strong) UILabel *addLable;

@property (nonatomic , strong) UIAlertController *alertVC;

@end


@implementation SearchServicesViewController

- (void)setServiceModel:(ServicesModel *)serviceModel {
    _serviceModel = serviceModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.count = 0;
    self._condition = [[NSCondition alloc]init];
    
    [self setUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self tapConfirmForResults];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_progressTimer invalidate];
    _progressTimer = nil;
    [self.repeatSendTimer invalidate];
    self.repeatSendTimer = nil;
    
    [self.updSocket close];
    self.updSocket = nil;
    [self cancel];
}


- (void)progressValue {
    _index++;
    
    _processView.percent = _index / 100;
    
    if (_index == 99) {
        [_progressTimer invalidate];
        _progressTimer = nil;
    }
}

#pragma mark - 设置UI
- (void)setUI {
    
    _index = 0.0;
   
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(progressValue) userInfo:nil repeats:YES];
    
    _processView = [[LXGradientProcessView alloc] initWithFrame:CGRectMake(kScreenW / 3.58, kScreenW / 2.6, kScreenW / 2.35, kScreenW / 2.35)];
    self.processView.percent = 0;
    [self.view addSubview:self.processView];
//    self.processView.backgroundColor = [UIColor whiteColor];
    
    UILabel *searchLable = [UILabel creatLableWithTitle:@"正在搜索设备..." andSuperView:self.view andFont:k15 andTextAligment:NSTextAlignmentCenter];
    searchLable.layer.borderWidth = 0;
    searchLable.textColor = [UIColor grayColor];
    [searchLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(kScreenW * 2 / 3, kScreenW / 14));
        make.top.mas_equalTo(_processView.mas_bottom)
        .offset(kScreenH / 12.4);
    }];
    
    
    UILabel *registerLable = [UILabel creatLableWithTitle:@"正在连接设备..." andSuperView:self.view andFont:k15 andTextAligment:NSTextAlignmentCenter];
    registerLable.layer.borderWidth = 0;
    registerLable.textColor = [UIColor grayColor];
    [registerLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(kScreenW * 2 / 3, kScreenW / 14));
        make.top.mas_equalTo(searchLable.mas_bottom);
    }];
    
    
    UILabel *addLable = [UILabel creatLableWithTitle:@"将设备添加到云端..." andSuperView:self.view andFont:k15 andTextAligment:NSTextAlignmentCenter];
    addLable.layer.borderWidth = 0;
    addLable.textColor = [UIColor grayColor];
    [addLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(kScreenW * 2 / 3, kScreenW / 14));
        make.top.mas_equalTo(registerLable.mas_bottom);
    }];
    self.searchLable = searchLable;
    self.registerLable = registerLable;
    self.addLable = addLable;
    
}



-(void)openUDPServer{
    
    //初始化udp
    AsyncUdpSocket *tempSocket=[[AsyncUdpSocket alloc] initWithDelegate:self];
    self.updSocket=tempSocket;
    
    //绑定端口
    NSError *error = nil;
    [self.updSocket bindToPort:6004 error:&error];
    
    [self.updSocket enableBroadcast:YES error:nil];
    
    [self.updSocket joinMulticastGroup:@"255.255.255.255" error:&error];
    
    //启动接收线程
    [self.updSocket receiveWithTimeout:-1 tag:0];
    
}

//连接建好后处理相应send Events
-(void)sendMessage:(NSString*)message
{
    NSLog(@"UDP发送数据--\n%@" , message);
    
    
    NSMutableString *sendString = [NSMutableString stringWithCapacity:100];
    [sendString appendString:message];
    //开始发送
    [self.updSocket sendData:[sendString dataUsingEncoding:NSUTF8StringEncoding] toHost:@"255.255.255.255"
                        port:3001
                 withTimeout:-1
                         tag:0];
    
    self.num++;
    if (self.num >= 30) {
        [self addFailAlert];
    }
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"onUdp--SendData");
}

- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock {
    NSLog(@"onUdp--DidClose");
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    [self.updSocket close];
    [_progressTimer setFireDate:[NSDate distantPast]];
   
    self.addLable.textColor = kMainColor;
    [self.repeatSendTimer invalidate];
    self.repeatSendTimer = nil;
    
    NSLog(@"%@" , data);
    NSString *str = [self convertDataToHexStr:data];
    NSString *devtypeSn = nil;
    NSString *devsn = nil;
    
    devtypeSn = [str substringWithRange:NSMakeRange(4, 4)];
    
    if ([devtypeSn isEqualToString:@"412a"]) {
        devsn = [str substringWithRange:NSMakeRange(8, 12)];
    } else {
        devsn = [str substringWithRange:NSMakeRange(10, 12)];
    }
    
    if ([devsn isEqualToString:self.deviceSn]) {
        self.devTypeSn = devtypeSn;
    } else {
        self.devTypeSn = nil;
    }
    
    if (self.devTypeSn) {
        
        if ([self.devTypeSn isEqualToString:@"412a"]) {
//            self.devTypeSn = @"4131";
            self.devTypeSn = self.serviceModel.typeSn;
        }
        
        if ([self.devTypeSn isEqualToString:self.serviceModel.typeSn]) {
            
            NSDictionary *parames = [NSMutableDictionary dictionary];
            [parames setValuesForKeysWithDictionary:@{@"ud.userSn" : [kStanderDefault objectForKey:@"userSn"] ,  @"ud.devSn" : self.deviceSn , @"ud.devTypeSn" : self.devTypeSn, @"phoneType":@(2) , @"ud.devTypeNumber":self.serviceModel.typeNumber}];
            
            
            if ([kStanderDefault objectForKey:@"cityName"] && [kStanderDefault objectForKey:@"provience"]) {
                NSString *city = [kStanderDefault objectForKey:@"cityName"];
                
                NSString *subStr = [city substringWithRange:NSMakeRange(city.length - 1, 1)];
                if (![subStr isEqualToString:@"市"]) {
                    city = [NSString stringWithFormat:@"%@市" , city];
                }
                
                [parames setValuesForKeysWithDictionary:@{@"province" : [kStanderDefault objectForKey:@"provience"] , @"city" : city}];
            }
            
            NSLog(@"%@" , parames);
            [kNetWork requestPOSTUrlString:self.serviceModel.bindUrl parameters:parames isSuccess:^(NSDictionary * _Nullable responseObject) {
                
                _processView.percent = 1.00;
                [_progressTimer invalidate];
                _progressTimer = nil;
                NSLog(@"%@" , responseObject);
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([responseObject[@"state"] integerValue] == 0) {
                        [self determineAndBindTheDevice];
                    } else if ([responseObject[@"state"] integerValue] == 2 ) {
                        [UIAlertController creatRightAlertControllerWithHandle:^{
                            [self determineAndBindTheDevice];
                        } andSuperViewController:self Title:@"此设备已绑定"];
                        
                    } else if ([responseObject[@"state"] integerValue] == 1){
                        [self addFailAlert];
                    }
                });
                
            } failure:^(NSError * _Nonnull error) {
                [kNetWork noNetWork];
            }];
            
            
        } else {
            [self addFailAlert];
        }
        
    } else {
        
        if (self.count >= 10) {
            [self addFailAlert];
        } else {
            self.count++;
            [self.updSocket close];
//            self.updSocket = nil;
            [self openUDPServer];
            
            [self sendMessage:self.serviceModel.protocol];
            
        }
        
    }
    
    return YES;
}

#pragma mark - 绑定设备失败
- (void)addServiceFail {
    
    FailContextViewController *failVC = [[FailContextViewController alloc]init];
    failVC.navigationItem.title = @"失败";
    failVC.serviceModel = self.serviceModel;
    [self.navigationController pushViewController:failVC animated:YES];
}

- (void)addFailAlert {
    
    [_progressTimer invalidate];
    _progressTimer = nil;
    [self.repeatSendTimer invalidate];
    self.repeatSendTimer = nil;
    [self.updSocket close];
    self.updSocket = nil;
    [self cancel];
    
    
    
    if (!self.alertVC) {
        self.alertVC = [UIAlertController creatRightAlertControllerWithHandle:^{
            [self addServiceFail];
        } andSuperViewController:[[HelpFunction shareHelpFunction]getPresentedViewController] Title:@"此设备绑定失败"];
        
    }
}

#pragma mark - 判断并绑定设备
- (void)determineAndBindTheDevice {
    
    [kStanderDefault setObject:@"YES" forKey:@"isHaveServices"];
    [kStanderDefault setObject:@"YES" forKey:@"Login"];
    
    [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:BindService object:nil]];
    
    MineSerivesViewController *tabVC = [[MineSerivesViewController alloc]init];
    tabVC.fromAddVC = @"YES";
    
    for (UIViewController *vc in self.navigationController.childViewControllers) {
        if ([vc isKindOfClass:[tabVC class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }

    
    [self.updSocket close];
}

#pragma mark - 重复发送
- (void)repeatSendMessage {
    [self sendMessage:self.serviceModel.protocol];
}

- (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

- (void) tapConfirmForResults
{
    
    self.searchLable.textColor = kMainColor;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *esptouchResultArray = [self executeForResults];
        NSLog(@"%@" , esptouchResultArray);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            ESPTouchResult *firstResult = [esptouchResultArray objectAtIndex:0];
            
            if (firstResult.bssid == nil || [firstResult isKindOfClass:[NSNull class]]) {
                [self addFailAlert];
                
            } else {
                self.deviceSn = firstResult.bssid;
                
                [_progressTimer setFireDate:[NSDate distantPast]];
                [self openUDPServer];
                self.registerLable.textColor = kMainColor;
                [self sendMessage:self.serviceModel.protocol];
                
                self.repeatSendTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(repeatSendMessage) userInfo:nil repeats:YES];
            }
            
        });
    });
    
}

#pragma mark - the example of how to cancel the executing task
- (void) cancel
{
    [self._condition lock];
    [self._esptouchTask interrupt];
    [self._condition unlock];
}

#pragma mark - the example of how to use executeForResults

- (NSArray *) executeForResults
{
    [self._condition lock];
    NSString *apSsid = self.ssidText;
    NSString *apPwd = self.bssid;
    NSString *apBssid = self.apSsid;
    self._esptouchTask =
    [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd andIsSsidHiden:NO];

    [self._condition unlock];
    
    NSArray * esptouchResults = [self._esptouchTask executeForResults:1];
    return esptouchResults;
}

- (void)dealloc {
    [_progressTimer invalidate];
    _progressTimer = nil;
    [self.repeatSendTimer invalidate];
    self.repeatSendTimer = nil;
}
@end
