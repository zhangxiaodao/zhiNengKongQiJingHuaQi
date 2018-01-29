//
//  DiZhiModel.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/4/11.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "DiZhiModel.h"

@implementation DiZhiModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.idd = [value integerValue];
    }
    
//    if ([key isEqualToString:@"postcode"]) {
//        self.postcode = [NSString stringWithFormat:@"%@" , value];
//    }
}
- (NSString *)description
{
    return [self yy_modelDescription];
}

@end
