//
//  UserDefaultHelper.h
//  Tinder
//
//  Created by Elluminati - macbook on 10/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USERDEFAULT [NSUserDefaults standardUserDefaults]

//UserDefault Keys
extern NSString *const UD_CURRENTLATITUDE;//currentLatitude
extern NSString *const UD_CURRENTLONGITUDE;//currentLongitude
extern NSString *const UD_FB_USER_DETAIL;//@"FacebookUserDetail";
extern NSString *const UD_FB_LOGIN_REQUEST;//@"FacebookLoginRequest";
extern NSString *const UD_FB_TOKEN;//FacebookToken
extern NSString *const UD_ISFIRSTLAUNCHFORMATCHEDLIST;//isFirstLaunchForMatchedList
extern NSString *const UD_LASTMESSAGETEXT;//LASTMESSAGETEXT
extern NSString *const UD_FBPROFILEURL;//FBPROFILEURL
extern NSString *const UD_ISUPLOADED;//IsUploaded
extern NSString *const UD_FBIDD;//fbidd
extern NSString *const UD_ITSMATCH;//ITSMATCH
extern NSString *const UD_LOCATIONDISABLED;//LocationDisabled
extern NSString *const UD_PATH;//PATH
extern NSString *const UD_BLOCK;//BLOCK
extern NSString *const UD_DEVICETOKEN;//DeviceToken
extern NSString *const UD_UUID;//UUID


@interface UserDefaultHelper : NSObject
{
    NSString *currentLatitude;
    NSString *currentLongitude;
    NSMutableDictionary *facebookUserDetail;
    NSMutableDictionary *facebookLoginRequest;
    NSString *facebookToken;
    BOOL isFirstLaunchForMatchedList;
    NSString *lastMessageText;
    NSString *fbProfileURL;
    
    BOOL isUploaded;
    
    NSString *fbidd;
    NSMutableDictionary *itsMatch;
    NSMutableArray *itsMatchTinder;
    NSString *locationDisable;
    NSString *path;
    BOOL block;
    
    NSString *deviceToken;

    
    NSString *uuid;
}
-(id)init;
+(UserDefaultHelper *)sharedObject;

//getter
-(NSString *)currentLatitude;
-(NSString *)currentLongitude;
-(NSMutableDictionary *)facebookUserDetail;
-(NSMutableDictionary *)facebookLoginRequest;
-(NSString *)facebookToken;
-(BOOL)isFirstLaunchForMatchedList;
-(NSString *)lastMessageText;
-(NSString *)fbProfileURL;
-(BOOL)isUploaded;

-(NSString*) facebookid;
-(NSString *)fbidd;
-(NSMutableDictionary *)itsMatch;
-(NSMutableArray *)itsMatchTinder;
-(NSString *)locationDisable;
-(NSString *)path;
-(BOOL)block;

-(NSString *)deviceToken;
-(NSString *)uuid;

//setter
-(void)setCurrentLatitude:(NSString *)newLat;
-(void)setCurrentLongitude:(NSString *)newLong;
-(void)setFacebookUserDetail:(NSMutableDictionary *)newFBUserDetail;
-(void)setFacebookLoginRequest:(NSMutableDictionary *)newFBLoginReq;
-(void)setFacebookToken:(NSString *)newFBToken;
-(void)setIsFirstLaunchForMatchedList:(BOOL)newIsFirstLaunchForMatchedList;
-(void)setLastMessageText:(NSString *)newLastMessageText;
-(void)setFBProfileURL:(NSString *)newFBProfileURL;
-(void)setIsUploaded:(BOOL)newIsUploaded;

-(void)setFbidd:(NSString *)newFbidd;
-(void)setItsMatch:(NSMutableDictionary *)newItsMatch;
-(void)setItsMatchTinder:(NSMutableArray *)newItsMatch;
-(void)setLocationDisable:(NSString *)newLocationDisable;
-(void)setPath:(NSString *)newPath;
-(void)setBlock:(BOOL)newBlock;

-(void)setDeviceToken:(NSString *)newDeviceToken;

-(void)setUUID;

@end
