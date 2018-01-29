//
//  ServicesModel.h
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/4/11.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServicesModel : NSObject

/**
 设备绑定地址
 */
@property (nonatomic , copy) NSString *bindUrl;
/**
 图片地址
 */
@property (nonatomic , strong) NSString *imageUrl;

/**
 公司logo图片地址
 */
@property (nonatomic , strong) NSString *logoUrl;

/**
 HTML控制页地址
 */
@property (nonatomic , copy) NSString *indexUrl;

/**
 类型编号
 */
@property (nonatomic , copy) NSString *typeSn;
/**
 类型名称
 */
@property (nonatomic , strong) NSString *typeName;
/**
 设备编号
 */
@property (nonatomic , strong) NSString *devSn;
/**
 品牌
 */
@property (nonatomic , copy) NSString *brand;
/**
 设备ID，用于删除设备
 */
@property (nonatomic , assign) NSInteger userDeviceID;
/**
 Smartlink协议
 */
@property (nonatomic , copy) NSString *protocol;
/**
 Smartlink方式
 */
@property (nonatomic , assign) NSInteger slTypeInt;

/**
 自定义名称
 */
@property (nonatomic , copy) NSString *definedName;

/**
 厂家出厂编号
 */
@property (nonatomic , copy) NSString *typeNumber;

/**
 公司名称
 */
@property (nonatomic , copy) NSString *company;

/**
 查询设备是否在线
 */
@property (nonatomic , assign) NSInteger ifConn;

/**
 *  测试使用将来需要删除
 */
@property (nonatomic , strong) NSString *devTypeSn;
@end
