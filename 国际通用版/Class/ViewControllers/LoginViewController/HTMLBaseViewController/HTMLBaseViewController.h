//
//  HTMLBaseViewController.h
//  联侠
//
//  Created by 杭州阿尔法特 on 2016/12/1.
//  Copyright © 2016年 张海昌. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol SendServiceModelToParentVCDelegate <NSObject>
- (void)whetherDelegateService:(BOOL)delateService;
- (void)sendServiceModelToParentVC:(ServicesModel *)serviceModel;
@end

@interface HTMLBaseViewController : UIViewController

@property (nonatomic , strong) ServicesModel *serviceModel;

@property (nonatomic , assign) id<SendServiceModelToParentVCDelegate> delegate;
@end
