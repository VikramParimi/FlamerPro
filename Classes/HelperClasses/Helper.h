//
//  Helper.h
//  Restaurant
//
//  Created by 3Embed on 14/09/12.
//
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject
{
   
}
@property(nonatomic,assign)float _latitude;
@property(nonatomic,assign)float _longitude;

+ (id)sharedInstance;

+(void)setToLabel:(UILabel*)lbl Text:(NSString*)txt WithFont:(NSString*)font FSize:(float)_size Color:(UIColor*)color;
+(void)setButton:(UIButton*)btn Text:(NSString*)txt WithFont:(NSString*)font FSize:(float)_size TitleColor:(UIColor*)t_color ShadowColor:(UIColor*)s_color;
+(void)showAlertWithTitle:(NSString*)title Message:(NSString*)message;
+(void)showErrorFor:(int)errorCode;
+ (NSString *)removeWhiteSpaceFromURL:(NSString *)url;
+ (NSString *)stripExtraSpacesFromString:(NSString *)string;
+(NSString*)getCurrentTime;
+ (UIColor *)getColorFromHexString:(NSString *)hexString :(CGFloat)alphaValue;
+(NSString*)getBirthDate :(NSString*)date;
+(NSInteger)getAge :(NSString*)date;
+(NSString *)ConverGMTtoLocal :(NSString*)date;
+(NSString *)relativeDateStringForDate:(NSDate*)bDate;

@end
