//
//  UserDefaultHelper.m
//  Tinder
//
//  Created by Elluminati - macbook on 10/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//


#import "UserDefaultHelper.h"

//UserDefault Keys
NSString *const UD_CURRENTLATITUDE=@"currentLatitude";
NSString *const UD_CURRENTLONGITUDE=@"currentLongitude";
NSString *const UD_FB_USER_DETAIL=@"FacebookUserDetail";
NSString *const UD_FB_LOGIN_REQUEST=@"FacebookLoginRequest";
NSString *const UD_FB_TOKEN=@"FacebookToken";

NSString *const UD_ISFIRSTLAUNCHFORMATCHEDLIST=@"isFirstLaunchForMatchedList";
NSString *const UD_LASTMESSAGETEXT=@"LASTMESSAGETEXT";
NSString *const UD_FBPROFILEURL=@"FBPROFILEURL";
NSString *const UD_ISUPLOADED=@"IsUploaded";
NSString *const UD_FBIDD=@"fbidd";
NSString *const UD_ITSMATCH=@"ITSMATCH";
NSString *const UD_ITSMATCHTINDER=@"ITSMATCHTINDER";
NSString *const UD_LOCATIONDISABLED=@"LocationDisabled";
NSString *const UD_PATH=@"PATH";
NSString *const UD_BLOCK=@"BLOCK";
NSString *const UD_DEVICETOKEN=@"DeviceToken";
NSString *const UD_UUID=@"UUID";


@implementation UserDefaultHelper

#pragma mark -
#pragma mark - Init

-(id)init
{
    if((self = [super init]))
    {
        [self setAllData];
    }
    return self;
}

+(UserDefaultHelper *)sharedObject
{
    static UserDefaultHelper *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[UserDefaultHelper alloc] init];
    });
    return obj;
}

#pragma mark -
#pragma mark - SetAllData

-(void)setAllData
{
    [self currentLatitude];
    [self currentLongitude];
    
    [self facebookUserDetail];
    [self facebookLoginRequest];
    [self facebookToken];
    
    [self lastMessageText];
    [self fbProfileURL];
    
    [self setUUID];
}

#pragma mark -
#pragma mark - Getter

-(NSString *)currentLatitude
{
    currentLatitude=[USERDEFAULT objectForKey:UD_CURRENTLATITUDE];
    return currentLatitude;
}

-(NSString *)currentLongitude
{
    currentLongitude=[USERDEFAULT objectForKey:UD_CURRENTLONGITUDE];
    return currentLongitude;
}

-(NSMutableDictionary *)facebookUserDetail
{
    facebookUserDetail=[USERDEFAULT objectForKey:UD_FB_USER_DETAIL];
    return facebookUserDetail;
}

-(NSString*) facebookid
{
    facebookLoginRequest = [self facebookLoginRequest];
    
}
-(NSMutableDictionary *)facebookLoginRequest
{
    facebookLoginRequest=[USERDEFAULT objectForKey:UD_FB_LOGIN_REQUEST];
    return facebookLoginRequest;
}
-(NSString *)facebookToken
{
    facebookToken=[USERDEFAULT objectForKey:UD_FB_TOKEN];
    return facebookToken;
}

-(BOOL)isFirstLaunchForMatchedList
{
    isFirstLaunchForMatchedList=[USERDEFAULT boolForKey:UD_ISFIRSTLAUNCHFORMATCHEDLIST];
    return isFirstLaunchForMatchedList;
}

-(NSString *)lastMessageText
{
    lastMessageText=[USERDEFAULT objectForKey:UD_LASTMESSAGETEXT];
    return lastMessageText;
}

-(NSString *)fbProfileURL
{
    fbProfileURL=[USERDEFAULT objectForKey:UD_FBPROFILEURL];
    return fbProfileURL;
}
-(BOOL)isUploaded
{
    isUploaded=[USERDEFAULT boolForKey:UD_ISUPLOADED];
    return isUploaded;
}
-(NSString *)fbidd
{
    fbidd=[USERDEFAULT objectForKey:UD_FBIDD];
    return fbidd;
}
-(NSMutableDictionary *)itsMatch
{
    itsMatch=[USERDEFAULT objectForKey:UD_ITSMATCH];
    return itsMatch;
}

-(NSMutableArray *)itsMatchTinder
{
    itsMatchTinder =[USERDEFAULT objectForKey:UD_ITSMATCHTINDER];
    return itsMatchTinder;
}

-(NSString *)locationDisable
{
    locationDisable=[USERDEFAULT objectForKey:UD_LOCATIONDISABLED];
    return locationDisable;
}
-(NSString *)path
{
    path=[USERDEFAULT objectForKey:UD_PATH];
    return path;
}
-(BOOL)block
{
    block=[USERDEFAULT boolForKey:UD_BLOCK];
    return block;
}

-(NSString *)deviceToken
{
    deviceToken=[USERDEFAULT objectForKey:UD_DEVICETOKEN];
    return deviceToken;
}

-(NSString *)uuid
{
    uuid=[USERDEFAULT objectForKey:UD_UUID];
    return uuid;
}

#pragma mark -
#pragma mark - Setter

-(void)setCurrentLatitude:(NSString *)newLat
{
    currentLatitude=newLat;
    [USERDEFAULT setObject:currentLatitude forKey:UD_CURRENTLATITUDE];
    [USERDEFAULT synchronize];
}
-(void)setCurrentLongitude:(NSString *)newLong
{
    currentLongitude=newLong;
    [USERDEFAULT setObject:currentLongitude forKey:UD_CURRENTLONGITUDE];
    [USERDEFAULT synchronize];
}
-(void)setFacebookUserDetail:(NSMutableDictionary *)newFBUserDetail
{
    facebookUserDetail=newFBUserDetail;
    [USERDEFAULT setObject:facebookUserDetail forKey:UD_FB_USER_DETAIL];
    [USERDEFAULT synchronize];
}
-(void)setFacebookLoginRequest:(NSMutableDictionary *)newFBLoginReq
{
    facebookLoginRequest=newFBLoginReq;
    [USERDEFAULT setObject:facebookLoginRequest forKey:UD_FB_LOGIN_REQUEST];
    [USERDEFAULT synchronize];
}
-(void)setFacebookToken:(NSString *)newFBToken
{
    facebookToken=newFBToken;
    [USERDEFAULT setObject:facebookToken forKey:UD_FB_TOKEN];
    [USERDEFAULT synchronize];
}

-(void)setIsFirstLaunchForMatchedList:(BOOL)newIsFirstLaunchForMatchedList
{
    isFirstLaunchForMatchedList=newIsFirstLaunchForMatchedList;
    [USERDEFAULT setBool:isFirstLaunchForMatchedList forKey:UD_ISFIRSTLAUNCHFORMATCHEDLIST];
    [USERDEFAULT synchronize];
}

-(void)setLastMessageText:(NSString *)newLastMessageText
{
    lastMessageText=newLastMessageText;
    [USERDEFAULT setObject:lastMessageText forKey:UD_LASTMESSAGETEXT];
    [USERDEFAULT synchronize];
}
-(void)setFBProfileURL:(NSString *)newFBProfileURL
{
    fbProfileURL=newFBProfileURL;
    [USERDEFAULT setObject:fbProfileURL forKey:UD_FBPROFILEURL];
    [USERDEFAULT synchronize];
}
-(void)setIsUploaded:(BOOL)newIsUploaded
{
    isUploaded=newIsUploaded;
    [USERDEFAULT setBool:isUploaded forKey:UD_ISUPLOADED];
    [USERDEFAULT synchronize];
}

-(void)setFbidd:(NSString *)newFbidd
{
    fbidd=newFbidd;
    [USERDEFAULT setObject:fbidd forKey:UD_FBIDD];
    [USERDEFAULT synchronize];
}

-(void)setItsMatchTinder:(NSMutableArray *)newItsMatch
{
    itsMatchTinder=newItsMatch;
    [USERDEFAULT setObject:itsMatch forKey:UD_ITSMATCHTINDER];
    [USERDEFAULT synchronize];
}

-(void)setItsMatch:(NSMutableDictionary *)newItsMatch
{
    itsMatch=newItsMatch;
    [USERDEFAULT setObject:itsMatch forKey:UD_ITSMATCH];
    [USERDEFAULT synchronize];
}

-(void)setLocationDisable:(NSString *)newLocationDisable
{
    locationDisable=newLocationDisable;
    [USERDEFAULT setObject:locationDisable forKey:UD_LOCATIONDISABLED];
    [USERDEFAULT synchronize];
}
-(void)setPath:(NSString *)newPath
{
    path=newPath;
    [USERDEFAULT setObject:path forKey:UD_PATH];
    [USERDEFAULT synchronize];
}
-(void)setBlock:(BOOL)newBlock
{
    block=newBlock;
    [USERDEFAULT setBool:block forKey:UD_BLOCK];
    [USERDEFAULT synchronize];
}
-(void)setDeviceToken:(NSString *)newDeviceToken
{
    deviceToken=newDeviceToken;
    [USERDEFAULT setObject:deviceToken forKey:UD_DEVICETOKEN];
    [USERDEFAULT synchronize];
}

-(void)setUUID
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
        uuid = [oNSUUID UUIDString];
    } else {
        NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
        uuid = [oNSUUID UUIDString];
        // strUUID = [[UIDevice currentDevice] uniqueIdentifier];
        // Load resources for iOS 7 or later
    }
    [USERDEFAULT setObject:uuid forKey:UD_UUID];
    [USERDEFAULT synchronize];
}

@end
