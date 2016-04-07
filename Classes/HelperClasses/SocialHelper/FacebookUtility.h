//
//  FacebookUtility.h
//  NewFBapiDemo
//
//  Created by Jignesh on 15/05/13.
//  Copyright (c) 2013 Jignesh. All rights reserved.
//

#import <Foundation/Foundation.h>

//Added
#define FBID @"975520955895440"
//#define FBID @"613709095446989"
extern NSString *const UD_FBACCESSTOKENDATA;//FBAccessTokenDataDictionary

typedef void (^LoginCompletionBlock)(BOOL success, NSError *error);
typedef void (^FBCompletionBlock)(id response, NSError *error);
typedef void (^FBFriendCompletionBlock)(NSArray *friends, NSError *error);

@protocol FacebookUtilityDelegate <NSObject>
@optional


@end

@interface FacebookUtility : NSObject
{
    
}
@property (nonatomic, assign) id<FacebookUtilityDelegate> delegate;
@property (strong, nonatomic) NSMutableDictionary *dictUserInfo;
@property (strong, nonatomic) NSMutableArray *arrFBFriendList;
@property (strong, nonatomic) NSMutableArray *arrFBLikesList;
@property (strong, nonatomic) FBSession *session;

//init and shared object
-(id) init;
+ (FacebookUtility *)sharedObject;
//for login chek
-(BOOL)isLogin;
//get fb token
-(void)getFBToken;
//login in FB
-(void)loginInFacebook:(LoginCompletionBlock)isLogin;
//logout from facebook
-(void)logOutFromFacebook;
//Fetch User Info
-(void)fetchMeWithFBCompletionBlock:(FBCompletionBlock)fbCompletion;
-(void)fetchMeWithFields:(NSString *)fields FBCompletionBlock:(FBCompletionBlock)fbCompletion;

//Post on My wall
-(void)postOnMyFacebookWall:(NSMutableDictionary *)dictPost WithFBCompletionBlock:(FBCompletionBlock)fbCompletion;
//Post On Friends Wall with FeedDialog
-(void)postOnFriendFacebookWallWithDialog:(NSMutableDictionary *)dictPost WithFBCompletionBlock:(FBCompletionBlock)fbCompletion;

//-(void)postOnFacebookFriendsWall;

-(void)getCommentsOfPost:(NSString *)postID WithCompletionBlock:(FBFriendCompletionBlock)fbFriends;

-(void)sendCommentsOfPost:(NSString *)postID andMsg:(NSString *)strMsg WithCompletionBlock:(FBCompletionBlock)fbCompletion;

//Search Post
-(void)searchPost:(NSString *)searchString WithCompletionBlock:(FBCompletionBlock)fbResult;
-(void)searchHomePost:(NSString *)searchString WithCompletionBlock:(FBCompletionBlock)fbResult;


/*
me/likes?fields=link,cover,picture.type(normal)
me/friends?fields=name,id,picture.type(normal)&limit=500
 */
//NewMethods
-(void)getUserAlbumsListWithLastPhotoCompletionBlock:(FBCompletionBlock)fbResult;
-(void)getUserAlbumsWithCompletionBlock:(FBCompletionBlock)fbResult;
-(void)getUserProfilePicturesAlbumsWithCompletionBlock:(FBCompletionBlock)fbResult;
-(void)getAlbumsPhotos:(NSString *)albumID WithCompletionBlock:(FBCompletionBlock)fbResult;
-(void)getAlbumsPhotos:(NSString *)albumID withLimit:(int)limit WithCompletionBlock:(FBCompletionBlock)fbResult;

//Friends
//Fetch Friends Info
- (void)fetchFriendsWithFBFriendCompletionBlock:(FBFriendCompletionBlock)fbFriends;
-(void)getFriendsFriends:(NSString *)userID WithLimit:(int)limit WithCompletionBlock:(FBCompletionBlock)fbResult;

//Friends Mutable
-(void)getMutualFriendsForUserID:(NSString *)userID WithCompletionBlock:(FBCompletionBlock)fbResult;

//Likes
-(void)getMyLikesWithLimit:(int)limit WithCompletionBlock:(FBCompletionBlock)fbResult;
-(void)getFriendsLikes:(NSString *)userID WithLimit:(int)limit WithCompletionBlock:(FBCompletionBlock)fbResult;

//Likes Mutable
-(void)getMutualLikesForUserID:(NSString *)userID WithCompletionBlock:(FBCompletionBlock)fbResult;

//Mutable Likes And Friends
-(void)getMutualLikesAndFriendsForUserID:(NSString *)userID WithCompletionBlock:(FBCompletionBlock)fbResult;



//me/albums?fields=photos.limit(1),id,name,from

/*
 me/likes?fields=picture.type(small),name&limit=20
 
 me/likes?fields=picture.type(large),name
 for friends
 me/friends?fields=picture.type(large),name,id
 */


@end
