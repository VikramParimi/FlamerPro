//
//  UserSettings.h
//  Tinder
//
//  Created by Elluminati - macbook on 27/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettings : NSObject
{
    
}
@property(nonatomic,copy)NSString *sex;
@property(nonatomic,copy)NSString *prRad;
@property(nonatomic,copy)NSString *prSex;
@property(nonatomic,copy)NSString *prLAge; // minage
@property(nonatomic,copy)NSString *prUAge; // maxage
@property(nonatomic,copy)NSString *prDiscovery;

+(UserSettings *)currentSetting;

@end


