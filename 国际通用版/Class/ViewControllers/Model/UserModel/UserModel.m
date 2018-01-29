//
//  UserModel.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/4/7.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

//- (void)setValue:(id)value forKey:(NSString *)key {
//    if ([key isEqualToString:@"birthdate"]) {
//        _birthdate = value;
//    } if ([key isEqualToString:@"email"]) {
//        _email = value;
//    } if ([key isEqualToString:@"headImageUrl"]) {
//        _headImageUrl = value;
//    } if ([key isEqualToString:@"id"]) {
//        _idd = [value integerValue];
//    } if ([key isEqualToString:@"nickname"]) {
//        _nickname = value;
//    } if ([key isEqualToString:@"sex"]) {
//        if ([value isKindOfClass:[NSNull class]]) {
//            _sex = 0;
//        } else {
//            _sex = [value integerValue];
//        }
//    } if ([key isEqualToString:@"sn"]) {
//        _sn = [value integerValue];
//    } if ([key isEqualToString:@"zmoney"]) {
//        _zmoney = value;
//    }
//}

- (NSString *)description {
    return [self yy_modelDescription];
}

@end
