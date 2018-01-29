//
//  AlertMessageView.m
//  联侠
//
//  Created by 杭州阿尔法特 on 2017/3/14.
//  Copyright © 2017年 张海昌. All rights reserved.
//

#import "AlertMessageView.h"
#import "PZXVerificationCodeView.h"

#define kSpace (kScreenW / 20)

@interface AlertMessageView ()
@property(nonatomic,strong)PZXVerificationCodeView *pzxView;
@property (nonatomic , strong) UILabel *phoneLabel;
@property (nonatomic , strong) NSTimer *countDownTimer;
@property (nonatomic , strong) UIButton *countdownBtn;
@property (nonatomic , assign) NSInteger secondsCountDown;
@end

@implementation AlertMessageView

- (UIView *)initWithFrame:(CGRect)frame TitleText:(NSString *)titleText andBtnTarget:(nullable id)target andCancleAtcion:(nonnull SEL)cancleAtcion {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        
        UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:cancleBtn];
        [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kScreenW / 20, kScreenW / 20));
            make.right.mas_equalTo(self.mas_right).offset(-5);
            make.top.mas_equalTo(self.mas_top).offset(5);
        }];
        [cancleBtn addTarget:target action:cancleAtcion forControlEvents:UIControlEventTouchUpInside];
        [cancleBtn setImage:[UIImage imageNamed:@"cancleImage"] forState:UIControlStateNormal];
        
        UILabel *titleLabel = [UILabel creatLableWithTitle:titleText andSuperView:self andFont:k20 andTextAligment:NSTextAlignmentCenter];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(cancleBtn.mas_bottom);
        }];
        
        UILabel *phoneLabel = [UILabel creatLableWithTitle:@"" andSuperView:self andFont:k12 andTextAligment:NSTextAlignmentCenter];
        [phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(titleLabel.mas_bottom)
            .offset(kSpace);
        }];
        self.phoneLabel = phoneLabel;
 
        _countdownBtn = [UIButton creatBtnWithTitle:@"重新发送" withLabelFont:14 withLabelTextColor:[UIColor grayColor] andSuperView:self andBackGroundColor:kWhiteColor andHighlightedBackGroundColor:kWhiteColor andwhtherNeendCornerRadius:YES WithTarget:self andDoneAtcion:@selector(againSendAtcion)];
        [self addSubview:_countdownBtn];
        [_countdownBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(self.width / 2, self.height / 8));
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(phoneLabel.mas_bottom)
            .offset(kSpace);
        }];
        _countdownBtn.layer.cornerRadius = 3;
        _countdownBtn.layer.masksToBounds = YES;
        _countdownBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _countdownBtn.layer.borderWidth = 1;
        
        _pzxView = [[PZXVerificationCodeView alloc]initWithFrame:CGRectMake(0, 0, kScreenW / 1.4, self.height / 5)];
        [self addSubview:_pzxView];
        [_pzxView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kScreenW / 1.4, self.height / 5));
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(_countdownBtn.mas_bottom)
            .offset(kSpace);
        }];
        _pzxView.tag = 10003;

        _pzxView.selectedColor = kMainColor;
        _pzxView.VerificationCodeNum = 6;
        _pzxView.Spacing = 3;//每个格子间距属性
    }
    return self;
}

- (void)clearNumber {
    [_pzxView clearText];
}

- (void)timeFireMethod {
    [self.countdownBtn setTitle:[NSString stringWithFormat:@"%lds%@",(long)self.secondsCountDown , @"后重新发送"] forState:UIControlStateNormal];
    
    if(self.secondsCountDown==0){
        [_countDownTimer invalidate];
        _countDownTimer = nil;
        
        [self.countdownBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        self.countdownBtn.userInteractionEnabled = YES;
        
    }
    self.secondsCountDown--;
}

- (void)againSendAtcion {
    self.secondsCountDown = 60;
    _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
    self.countdownBtn.backgroundColor = [UIColor clearColor];
    self.countdownBtn.userInteractionEnabled = NO;
    
    NSDictionary *parameters = @{@"dest":self.phoneNumber , @"bool" : @(0)};
    [kNetWork requestPOSTUrlString:kFaSongDuanXin parameters:parameters isSuccess:^(NSDictionary * _Nullable responseObject) {
        NSLog(@"发送的短信%@" , responseObject);
    } failure:^(NSError * _Nonnull error) {
        [kNetWork noNetWork];
    }];
    
}

- (void)setPhoneNumber:(NSString *)phoneNumber {
    _phoneNumber = phoneNumber;
    
    _phoneLabel.text = [NSString stringWithFormat:@"验证码发送至:%@" , _phoneNumber];
    
    if (!_countDownTimer) {
        [self againSendAtcion];
    }
}

@end
