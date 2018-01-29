//
//  NSString+Extension.m
//  联侠
//
//  Created by 杭州阿尔法特 on 16/9/19.
//  Copyright © 2016年 张海昌. All rights reserved.
//

#import "NSString+Extension.h"
#import <sys/utsname.h>
@implementation NSString (Extension)

+ (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}


+ (void)setNSMutableAttributedString:(CGFloat)number andSuperLabel:(UILabel *)superLabel andDanWei:(NSString *)danWei andSize:(CGFloat)size andTextColor:(UIColor *)color isNeedTwoXiaoShuo:(NSString *)isNeedTwoXiaoShu {
    
    if ([isNeedTwoXiaoShu isEqualToString:@"YES"]) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%.2f%@" , number , danWei]];
        [str addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0,[NSString stringWithFormat:@"%.2f" , number].length)];
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontWithName size:size] range:NSMakeRange(0, [NSString stringWithFormat:@"%.2f" , number].length)];
        superLabel.attributedText = str;
    } else if ([isNeedTwoXiaoShu isEqualToString:@"NO"]) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%.0f%@" , number , danWei]];
        [str addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0,[NSString stringWithFormat:@"%.0f" , number].length)];
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontWithName size:size] range:NSMakeRange(0, [NSString stringWithFormat:@"%.0f" , number].length)];
        superLabel.attributedText = str;
    }
    
    
}

+ (void)setAttributedString:(NSString *)sumStr WithSubString:(NSInteger)subFromIndex andSize:(CGFloat)size andTextColor:(UIColor *)color isNeedTwoXiaoShuo:(NSString *)isNeedTwoXiaoShu andSuperLabel:(UILabel *)superLabel {
    NSString *subStr = [sumStr substringFromIndex:subFromIndex];
    
    if ([isNeedTwoXiaoShu isEqualToString:@"YES"]) {
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:sumStr];
        [str addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(subFromIndex,subStr.length)];
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontWithName size:size] range:NSMakeRange(subFromIndex, subStr.length)];
        superLabel.attributedText = str;
    } else if ([isNeedTwoXiaoShu isEqualToString:@"NO"]) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:sumStr];
        [str addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(subFromIndex,subStr.length)];
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontWithName size:size] range:NSMakeRange(subFromIndex, subStr.length)];
        superLabel.attributedText = str;
    }
    superLabel.textColor = color;
    
}

+ (NSString *)timeAndAfterHours:(NSNumber *)hour andAfterDays:(NSNumber *)day andMonth:(NSNumber *)month {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = nil;
    
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:[NSDate date]];
    
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    
    if (hour) {
        [adcomps setHour:-hour.intValue];
    } else {
        [adcomps setHour:0];
    }
    
    if (day) {
        [adcomps setDay:-day.intValue];
    } else {
        [adcomps setDay:0];
    }
    
    if (month) {
        [adcomps setMonth:-month.intValue];
    } else {
        [adcomps setMonth:0];
    }
    
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:[NSDate date] options:0];
    NSDateFormatter *formatyer = [[NSDateFormatter alloc]init];
    [formatyer setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *dateTime = [formatyer stringFromDate:newdate];
    
    NSString *subStr = nil;
    
    if (hour) {
        subStr = [NSString stringWithFormat:@"%@点" , [dateTime substringWithRange:NSMakeRange(11, 2)]];
    } else if (day) {
        subStr = [dateTime substringWithRange:NSMakeRange(5, 5)];
    } else if (month) {
        subStr = [NSString stringWithFormat:@"%@月份" , [dateTime substringWithRange:NSMakeRange(5, 2)]];
    }
        return subStr;
}

+ (NSMutableArray *)nowTimeAndAfterHour:(NSString *)afterHour andAfterMinutes:(NSString *)afterMinutes andIsNeedTimeInterval:(NSString *)isNeedTimeInterval {
    
    NSDate *nowDate = [NSDate date];
    NSTimeInterval destinationTimeInterval = 0.0;
    
    if (afterHour != nil) {
        destinationTimeInterval = (afterHour.integerValue * 3600 + (NSInteger)[nowDate timeIntervalSince1970]);
    }
    
    if (afterMinutes != nil) {
        destinationTimeInterval = (afterMinutes.integerValue * 60 + (NSInteger)[nowDate timeIntervalSince1970]);
    }
    
    if (afterHour != nil && afterMinutes != nil) {
        destinationTimeInterval = (afterHour.integerValue * 3600 + afterMinutes.integerValue * 60 + (NSInteger)[nowDate timeIntervalSince1970]);
    }
    
    NSDate *destinationDate = [NSDate dateWithTimeIntervalSince1970:destinationTimeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    
    NSString *locationDate = [dateFormatter stringFromDate:nowDate];
    NSString *confirmTimeStr = [dateFormatter stringFromDate:destinationDate];
    NSLog(@"%@ , %@" , locationDate , confirmTimeStr);
    
    NSMutableArray *array = [NSMutableArray array];
    if ([isNeedTimeInterval isEqualToString:@"YES"]) {
        NSInteger nowTimeInterval = (NSInteger)[nowDate timeIntervalSince1970];
        [array addObject:@(nowTimeInterval)];
        [array addObject:@(destinationTimeInterval)];
    } else {
        [array addObject:locationDate];
        [array addObject:confirmTimeStr];
    }
    
    return array;
    
}

+ (NSString *)getNowTimeString {
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    NSString *nowTime = [dateFormatter stringFromDate:nowDate];
    return nowTime;
}

+ (NSInteger)getNowTimeInterval {
    NSDate *nowDate = [NSDate date];
    NSInteger nowTimeInterval = (NSInteger)[nowDate timeIntervalSince1970];
    return nowTimeInterval;
}

+ (NSString *)turnTimeIntervalToString:(NSInteger)timeInterval {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *time = [dateFormatter stringFromDate:date];
    return time;
}

+ (NSString *)turnHexToInt:(NSString *)hexString {
    NSString * temp10 = [NSString stringWithFormat:@"%lu",strtoul([hexString UTF8String],0,16)];
    
    return temp10;
}

+ (NSMutableAttributedString *)setSubStringOfOriginalString:(NSString *)originalStr andColorString:(NSString *)colorSubString andColor:(UIColor *)color{
    NSString *string = originalStr;
    NSString *stringForColor = colorSubString;
    NSMutableAttributedString *mAttStri = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange range = [string rangeOfString:stringForColor];
    [mAttStri addAttribute:NSForegroundColorAttributeName value:color range:range];
    return mAttStri;
}

//10进制转16进制
+(NSString *)ToHex:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i =0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        
        if (tmpid == 0) {
            break;
        }
        
    }

    
    if (str.length == 1) {
        str = [NSString stringWithFormat:@"0%@" , str];
    }
    
    str = [NSString stringWithFormat:@"0x%@" , str];
    return str;
}

//将某个时间转化成 时间戳

#pragma mark - 将某个时间转化成 时间戳
+(NSInteger)turnTimeToInterval:(NSString *)formatTime {
    
    NSString *format = @"YYYY-MM-dd";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:format]; //(@"YYYY-MM-dd hh:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate* date = [formatter dateFromString:formatTime];
    //------------将字符串按formatter转成nsdate
    
    //时间转时间戳的方法:
    
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    
    return timeSp;
    
}

#pragma mark - 把当前时间的 时 和 分  转化为十六进制
+ (NSArray *)sendXinFengNowTime {
    NSString *nowTime = [NSString getNowTimeString];
    nowTime = [nowTime substringWithRange:NSMakeRange(11, 5)];
    
    NSString *hourTime = [nowTime substringWithRange:NSMakeRange(0, 2)];
    NSString *minuteTime = [nowTime substringWithRange:NSMakeRange(3, 2)];
    
    NSString *hourHex = [[NSString ToHex:hourTime.integerValue] substringFromIndex:2];
    NSString *minuteHex = [[NSString ToHex:minuteTime.integerValue] substringFromIndex:2];
    
    NSArray *array = @[hourHex , minuteHex];
    return array;
}


// 获取设备型号然后手动转化为对应名称
+ (NSString *)getDeviceName
{
    // 需要#import "sys/utsname.h"
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"国行、日版、港行iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"港行、国行iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"美版、台版iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"美版、台版iPhone 7 Plus";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    
    if ([deviceString isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2";
    if ([deviceString isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceString;
}


+ (NSString *)getDeviceSystemVersion {
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    return phoneVersion;
}

@end
