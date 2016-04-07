//
//  TinderFBFQL.h
//  Tinder
//
//  Created by Vinay Raja on 07/12/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TinderFBFQLDelegate <NSObject>

@optional
-(void)doneLoadingProfileImage:(UIImage*)image;
-(void)doneDownloadingProfileImages;

@end

@interface TinderFBFQL : NSObject

+ (BOOL) isSessionActive;
+(void)updateFacebookSession;
+(void)openCreateFBSession:(id<TinderFBFQLDelegate>)delegate;
+ (void)executeFQlForProfileImage:(id<TinderFBFQLDelegate>)delegate;
+ (void)executeFQlForMatchProfileForId:(NSString*)fbid andDelegate:(id<TinderFBFQLDelegate>)delegate;
+ (void)executeFQlForMutualFriendForId:(NSString*)fbid andFriendId :(NSString*)FriendId andDelegate:(id<TinderFBFQLDelegate>)delegate;
+ (void)executeFQlForMutualLikesForId:(NSString*)fbid andFriendId :(NSString*)FriendId andDelegate:(id<TinderFBFQLDelegate>)delegate;

@end