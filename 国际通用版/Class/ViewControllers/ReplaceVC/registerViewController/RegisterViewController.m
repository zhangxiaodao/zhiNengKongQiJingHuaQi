//
//  RegisterViewController.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/8.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "RegisterViewController.h"
#import "YinSiViewController.h"
#import "XieYiNeiRongViewController.h"
#import "AuthcodeView.h"
#import "AlertMessageView.h"
#import "PZXVerificationCodeView.h"

@interface RegisterViewController ()<UITextFieldDelegate>
@property (nonatomic , retain) UITextField *accTectFiled;
@property (nonatomic , retain) UITextField *pwdTectFiled;
@property (nonatomic , retain) UITextField *verificationCodeTectFiled;
@property (nonatomic , strong) AuthcodeView *authView;

@property (nonatomic , strong) UIView *markView;
@property (nonatomic , strong) AlertMessageView *alertMessageView;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"f2f4fb"];
    
    [self setUI];
}

- (void)whetherGegisterSuccess:(NSNotification *)post {
    NSString *success = post.userInfo[@"RegisterSuccess"];
    NSString *vercodeStr = post.userInfo[@"VercodeStr"];
//    NSLog(@"%@" , success);
    if ([success isEqualToString:@"YES"]) {
        
        [self cancleAtcion];

        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"code" : vercodeStr , @"user.phone":self.accTectFiled.text , @"user.password" : self.pwdTectFiled.text ,  @"ua.phoneType" : @(2), @"ua.phoneBrand":@"iPhone" , @"ua.phoneModel":[NSString getDeviceName] , @"ua.phoneSystem":[NSString getDeviceSystemVersion]}];
        if ([kStanderDefault objectForKey:@"GeTuiClientId"]) {
            [parameters setObject:[kStanderDefault objectForKey:@"GeTuiClientId"] forKey:@"ua.clientId"];
        }
        [kStanderDefault setObject:self.pwdTectFiled.text forKey:@"password"];
        [kStanderDefault setObject:self.accTectFiled.text forKey:@"phone"];
        
        [kNetWork requestPOSTUrlString:kRegisterURL parameters:parameters isSuccess:^(NSDictionary * _Nullable responseObject) {
            [kPlistTools saveDataToFile:responseObject name:@"UserData"];
            NSInteger state = [responseObject[@"state"] integerValue];
            
            if (state == 0) {
                
                NSDictionary *user = responseObject[@"data"];
                
                [kStanderDefault setObject:user[@"sn"] forKey:@"userSn"];
                [kStanderDefault setObject:user[@"id"] forKey:@"userId"];
                [kTools setAlertText:@"恭喜您，注册成功" viewController:self handle:^{
                    [kWindowRoot presentViewController:[[TabBarViewController alloc]init] animated:YES completion:^{
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }];
                }];
            }
        } failure:^(NSError * _Nonnull error) {
            [kNetWork noNetWork];
        }];
    }
}

#pragma mark - alertVerificationCodeView 退出
- (void)cancleAtcion {
    [UIView animateWithDuration:.3 animations:^{
        self.markView.alpha = 0;
        self.alertMessageView.alpha = 0;
    }];
    [self.view endEditing:YES];
}

#pragma mark - 弹出alertVerificationCodeView
- (void)alertVerificationCodeView {
    
    self.alertMessageView.phoneNumber = self.accTectFiled.text;
    
    [UIView animateWithDuration:.3 animations:^{
        self.markView.alpha = .8;
        self.alertMessageView.alpha = 1;
        
    }];
    
    PZXVerificationCodeView *pzxView = [self.alertMessageView viewWithTag:10003];
    UITextField *firstTf = [pzxView viewWithTag:100];
    [firstTf becomeFirstResponder];
    
    CGRect frame = self.alertMessageView.frame;
    int offset = frame.origin.y + frame.size.height - (kScreenH - (216+36)) + kScreenW / 10;
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    if(offset > 0) {
        self.alertMessageView.frame = CGRectMake((kScreenW - kScreenW / 1.4) / 2, (kScreenH - kScreenH / 2.66) / 2 - offset, kScreenW / 1.4, kScreenH / 2.66);
    }
    [UIView commitAnimations];
    
}
#pragma mark - 隐私政策点击事件
- (void)yinSiAtcion{
    YinSiViewController *yinSiVC = [[YinSiViewController alloc]init];
    yinSiVC.navigationItem.title = @"隐私政策";
    [self.navigationController pushViewController:yinSiVC animated:YES];
}

#pragma mark - 用户协议点击事件
- (void)xieYiAction{
    XieYiNeiRongViewController *xieYiVC = [[XieYiNeiRongViewController alloc]init];
    xieYiVC.navigationItem.title = @"协议内容";
    [self.navigationController pushViewController:xieYiVC animated:YES];
}

#pragma mark - 立即注册按钮点击事件
- (void)registerAction{
    
    if (self.accTectFiled.text.length > 0 && self.pwdTectFiled.text.length > 0 && self.verificationCodeTectFiled.text.length > 0) {
        if (self.accTectFiled.text.length == 11 && [NSString validateNumber:self.accTectFiled.text] && self.pwdTectFiled.text.length >= 6 && self.pwdTectFiled.text.length <= 12 && [self.verificationCodeTectFiled.text isEqualToString:self.authView.authCodeStr]) {
            NSDictionary *parameters = @{@"phone":self.accTectFiled.text};
            [kNetWork requestPOSTUrlString:kJiaoYanZhangHu parameters:parameters isSuccess:^(NSDictionary * _Nullable responseObject) {
                [self alertVerificationCodeView];
            } failure:^(NSError * _Nonnull error) {
                [kNetWork noNetWork];
            }];
            
        } else {
            if (self.accTectFiled.text.length != 11) {
                [kTools setAlertText:@"手机号码格式不正确" viewController:self handle:^{
                    self.accTectFiled.text = nil;
                }];
            } else if ( self.pwdTectFiled.text.length < 6 || self.pwdTectFiled.text.length > 12) {
                [kTools setAlertText:@"密码长度必须大于6位并小于16位" viewController:self handle:^{
                    self.pwdTectFiled.text = nil;
                }];
            } else if (![self.verificationCodeTectFiled.text isEqualToString:self.authView.authCodeStr]) {
                [kTools setAlertText:@"您输入的验证码错误，请重新输入" viewController:self handle:^{
                    self.verificationCodeTectFiled.text = nil;
                }];
            }
        }
    } else {
        if (self.accTectFiled.text.length == 0) {
            [kTools setAlertText:@"手机号码为空" viewController:self handle:nil];
        } else if (self.pwdTectFiled.text.length == 0) {
            [kTools setAlertText:@"密码为空" viewController:self handle:nil];
        } else if (self.verificationCodeTectFiled.text.length == 0) {
            [kTools setAlertText:@"验证码为空" viewController:self handle:nil];
        }
    }
}


#pragma mark - 设置UI
- (void)setUI{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whetherGegisterSuccess:) name:@"RegisterSuccess" object:nil];
    
    UIView *phoneFiledView = [UIView creatViewWithFiledCoradiusOfPlaceholder:@"请输入您的手机号码" andSuperView:self.view];
    [phoneFiledView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW - kScreenW / 15.625, kScreenW / 8.3));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.view.mas_top).offset(10);
    }];
    self.accTectFiled = phoneFiledView.subviews[0];
    self.accTectFiled.delegate = self;
    
    UIView *pwdFiledView = [UIView creatViewWithFiledCoradiusOfPlaceholder:@"请输入密码" andSuperView:self.view];
    [pwdFiledView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW - kScreenW / 15.625, kScreenW / 8.3));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(phoneFiledView.mas_bottom)
        .offset(10);
    }];
    self.pwdTectFiled = pwdFiledView.subviews[0];
    self.pwdTectFiled.keyboardType = UIKeyboardTypeDefault;
    self.pwdTectFiled.secureTextEntry = YES;
    self.pwdTectFiled.delegate = self;
    
    UIView *verificationCodeView = [UIView creatViewWithFiledCoradiusOfPlaceholder:@"请输入验证码" andSuperView:self.view];
    [verificationCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW - kScreenW / 15.625, kScreenW / 8.3));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(pwdFiledView.mas_bottom)
        .offset(10);
    }];
    self.verificationCodeTectFiled = verificationCodeView.subviews[0];
    self.verificationCodeTectFiled.delegate = self;
    
    self.authView = [[AuthcodeView alloc]init];
    [self.view addSubview:self.authView];
    [self.authView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW / 5.35, kScreenW / 12.5));
        make.bottom
        .mas_equalTo(verificationCodeView.mas_bottom).offset(-5);
        make.right
        .mas_equalTo(verificationCodeView.mas_right);
    }];
    
    UIButton *registerBtn = [UIButton initWithTitle:@"立即注册" andColor:[UIColor redColor] andSuperView:self.view];
    [registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kStandardW, kScreenW / 8.3));
        make.centerX
        .mas_equalTo(verificationCodeView.mas_centerX);
        make.top
        .mas_equalTo(verificationCodeView.mas_bottom).offset(kScreenW / 7);
    }];
    [registerBtn addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    registerBtn.layer.cornerRadius = kScreenW / 16.6;
    registerBtn.backgroundColor = kMainColor;
    
    UILabel *changLable = [UILabel creatLableWithTitle:@"点击'立即注册'，即表示你同意遵守欧众" andSuperView:self.view andFont:k12 andTextAligment:NSTextAlignmentCenter];
    changLable.textColor = [UIColor grayColor];
    changLable.layer.borderWidth = 0;
    [changLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kStandardW, kScreenW / 20));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-kScreenW / 5.55);
    }];
    
    UILabel *heLable = [UILabel creatLableWithTitle:@"和" andSuperView:self.view andFont:k12 andTextAligment:NSTextAlignmentCenter];
    heLable.layer.borderWidth = 0;
    heLable.textColor = [UIColor grayColor];
    [heLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW / 20, kScreenW / 13));
        make.centerX.mas_equalTo(changLable.mas_centerX);
        make.top.mas_equalTo(changLable.mas_bottom);
    }];
    
    
    UILabel *xieYiLable = [UILabel creatLableWithTitle:@"协议内容" andSuperView:self.view andFont:k12 andTextAligment:NSTextAlignmentRight];
    xieYiLable.textColor = [UIColor blackColor];
    xieYiLable.layer.borderWidth = 0;
    [xieYiLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW / 6, kScreenW / 14));
        make.right.mas_equalTo(heLable.mas_left);
        make.top.mas_equalTo(changLable.mas_bottom);
    }];
    xieYiLable.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapXieYi = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(xieYiAction)];
    [xieYiLable addGestureRecognizer:tapXieYi];
    
    UILabel *yinSiLable = [UILabel creatLableWithTitle:@"隐私政策" andSuperView:self.view andFont:k12 andTextAligment:NSTextAlignmentLeft];
    yinSiLable.textColor = [UIColor blackColor];
    yinSiLable.layer.borderWidth = 0;
    [yinSiLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(heLable.mas_right);
        make.size.mas_equalTo(CGSizeMake(kScreenW / 6, kScreenW / 14));
        make.top.mas_equalTo(changLable.mas_bottom);
    }];
    
    yinSiLable.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapYinSi = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(yinSiAtcion)];
    [yinSiLable addGestureRecognizer:tapYinSi];
    
    self.markView = [[UIView alloc]initWithFrame:kScreenFrame];
    [self.view addSubview:self.markView];
    //模糊效果
    UIBlurEffect *light = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *bgView = [[UIVisualEffectView alloc]initWithEffect:light];
    bgView.frame = self.markView.bounds;
    [self.markView addSubview:bgView];
    self.markView.alpha = 0;
    
    self.alertMessageView = [[AlertMessageView alloc]initWithFrame:CGRectMake((kScreenW - kScreenW / 1.4) / 2, (kScreenH - kScreenH / 2.66) / 2, kScreenW / 1.4, kScreenH / 2.66) TitleText:@"请输入验证码" andBtnTarget:self andCancleAtcion:@selector(cancleAtcion)];
    [self.view addSubview:self.alertMessageView];
    
    self.alertMessageView.alpha = 0;
    
}

#pragma mark - 点击空白处收回键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
