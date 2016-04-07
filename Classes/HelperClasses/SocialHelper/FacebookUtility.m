//
//  FacebookUtility.m
//  NewFBapiDemo
//
//  Created by Jignesh on 15/05/13.
//  Copyright (c) 2013 Jignesh. All rights reserved.
//

#import "FacebookUtility.h"

NSString *const UD_FBACCESSTOKENDATA=@"FBAccessTokenDataDictionary";

@implementation FacebookUtility

@synthesize delegate;
@synthesize session = _session;
@synthesize dictUserInfo=_dictUserInfo,arrFBFriendList=_arrFBFriendList,arrFBLikesList=_arrFBLikesList;


#pragma mark -
#pragma mark - Init And Shared Object

-(id) init
{
    if((self = [super init]))
    {
        self.arrFBFriendList=[[NSMutableArray alloc]init];
        self.arrFBLikesList=[[NSMutableArray alloc]init];
    }
    return self;
}

+ (FacebookUtility *)sharedObject
{
    static FacebookUtility *objFBUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objFBUtility = [[FacebookUtility alloc] init];
    });
    return objFBUtility;
}

#pragma mark -
#pragma mark - Login and Permitions methods

-(NSArray *)getPermissionsArray
{
    /*
    static NSArray *permissions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        permissions = [[NSArray alloc] initWithObjects:@"user_birthday",@"email", @"publish_stream", @"offline_access",@"publish_actions",  @"user_location",  @"user_hometown",  @"user_about_me", @"user_relationships",@"user_address",@"user_relationship_details",@"read_stream",@"read_friendlists",@"user_likes",@"public_profile",@"user_friends", nil];
    });
    return permissions;
    */
    
    
   // @"user_about_me",@"user_friends",@"user_likes",@"user_groups",@"user_photos",@"email",@"user_birthday"
    
    static NSArray *permissions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        permissions = [[NSArray alloc] initWithObjects:@"user_birthday",@"email",@"public_profile",@"user_photos", nil];
    });
    return permissions;

}

-(BOOL)isLogin
{
    BOOL isLogin=FALSE;
    if (self.session.isOpen) {
        isLogin=TRUE;
    }
    return isLogin;
}

-(void)getFBToken
{
    if (!self.session.isOpen) {
        // create a fresh session object
        self.session = [[FBSession alloc] initWithPermissions:[self getPermissionsArray]];
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (self.session.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [self.session openWithCompletionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                // we recurse here, in order to update buttons and labels
                [FBSession setActiveSession:self.session];
            }];
        }
    }
    else{
        if (self.session.state==FBSessionStateOpen) {
            
            NSLog(@"%@",FBSession.activeSession.accessTokenData.accessToken);
            
            //Added
            [USERDEFAULT setObject:FBSession.activeSession.accessTokenData.accessToken forKey:UD_FB_TOKEN];
            
            
            [self.session openWithCompletionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                // we recurse here, in order to update buttons and labels
                [FBSession setActiveSession:self.session];
            }];
        }
    }
}

-(void)loginInFacebook:(LoginCompletionBlock)isLogin
{
    if (self.session.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        //[self.session closeAndClearTokenInformation];
        
        isLogin(TRUE,nil);
    }
    else
    {
        FBAccessTokenData *accessData=[FBAccessTokenData createTokenFromDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:UD_FBACCESSTOKENDATA]];
        
        if (accessData==nil) {
            if (self.session.state != FBSessionStateCreated) {
                // Create a new, logged out session.
                self.session = [[FBSession alloc] initWithPermissions:[self getPermissionsArray]];
            }
            // if the session isn't open, let's open it now and present the login UX to the user
            [self.session openWithCompletionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                // and here we make sure to update our UX according to the new session state
                [FBSession setActiveSession:self.session];
                //[self LoginSuccess];
                
                NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
                [userDefaults setObject:[self.session.accessTokenData dictionary] forKey:UD_FBACCESSTOKENDATA];
                [userDefaults synchronize];
                
//                [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                    NSLog(@"%@",result);
//                    //result contains a dictionary of your user, including Facebook ID.
//                }];
                
                
                if (!error) {
                    isLogin(TRUE,nil);
                }
                else{
                    isLogin(FALSE,error);
                }
            }];
        }
        else{
            [self.session openFromAccessTokenData:accessData completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                self.session=session;
                [FBSession setActiveSession:self.session];
                NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
                [userDefaults setObject:[self.session.accessTokenData dictionary] forKey:@"FBAccessTokenDataDictionary"];
                [userDefaults synchronize];
                if (self.session.isOpen) {
                    isLogin(TRUE,nil);
                }
                else{
                    if (self.session.state != FBSessionStateCreated) {
                        // Create a new, logged out session.
                        self.session = [[FBSession alloc] initWithPermissions:[self getPermissionsArray]];
                    }
                    // if the session isn't open, let's open it now and present the login UX to the user
                    [self.session openWithCompletionHandler:^(FBSession *session,
                                                              FBSessionState status,
                                                              NSError *error) {
                        // and here we make sure to update our UX according to the new session state
                        [FBSession setActiveSession:self.session];
                        //[self LoginSuccess];
                        
                        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
                        [userDefaults setObject:[self.session.accessTokenData dictionary] forKey:@"FBAccessTokenDataDictionary"];
                        [userDefaults synchronize];
                        
                        
                        if (!error) {
                            isLogin(TRUE,nil);
                        }
                        else{
                            isLogin(FALSE,error);
                        }
                    }];
                }
            }];
        }
    }
}

-(void)logOutFromFacebook
{
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession.activeSession close];
    [FBSession setActiveSession:nil];
    
    [self.session closeAndClearTokenInformation];
    [self.session close];
    self.session=nil;
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString *domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"facebook"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:UD_FB_TOKEN];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark -
#pragma mark - Fetch User Info

-(void)fetchMeWithFBCompletionBlock:(FBCompletionBlock)fbCompletion
{
    if (self.session.isOpen)
    {
        FBRequest *meRequest=[[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"me"]];
        [meRequest startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary* result,
           NSError *error)
         {
             fbCompletion(result,error);
         }];
    }
    else{
        fbCompletion(nil,[NSError errorWithDomain:@"FacebookSession" code:6969 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Session Expired",@"Info", nil]]);
    }
}

-(void)fetchMeWithFields:(NSString *)fields FBCompletionBlock:(FBCompletionBlock)fbCompletion
{
    if (self.session.isOpen)
    {
        FBRequest *meRequest=[[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"me?fields=%@",fields]];
        [meRequest startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary* result,
           NSError *error)
         {
             fbCompletion(result,error);
         }];
    }
    else{
        fbCompletion(nil,[NSError errorWithDomain:@"FacebookSession" code:6969 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Session Expired",@"Info", nil]]);
    }
}

#pragma mark -
#pragma mark - Fetch Friends Info

//Give Mutal Friend list for app in v2.0

- (void)fetchFriendsWithFBFriendCompletionBlock:(FBFriendCompletionBlock)fbFriends
{
    [self getFriendsFriends:@"me" WithLimit:200 WithCompletionBlock:^(id response, NSError *error) {
        if (response) {
            [self.arrFBFriendList removeAllObjects];
            [self.arrFBFriendList addObjectsFromArray:response];
        }
        fbFriends(response,error);
    }];
    
}

-(void)getFriendsFriends:(NSString *)userID WithLimit:(int)limit WithCompletionBlock:(FBCompletionBlock)fbResult
{
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"%@/friends?fields=picture.type(small),name&limit=%d",userID,limit]];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             NSArray* friends = [result objectForKey:@"data"];
             fbResult(friends,error);
         }
         else{
             fbResult(nil,error);
         }
     }];
}

#pragma mark -
#pragma mark - Post on My wall

-(void)postOnMyFacebookWall:(NSMutableDictionary *)dictPost WithFBCompletionBlock:(FBCompletionBlock)fbCompletion
{
    FBRequest *post=[[FBRequest alloc]initWithSession:self.session graphPath:@"me/feed" parameters:dictPost HTTPMethod:@"POST"];
    [post startWithCompletionHandler: ^(FBRequestConnection *connection,
                                        NSDictionary* result,
                                        NSError *error)
     {
         fbCompletion(result,error);
     }];
}

#pragma mark -
#pragma mark - Post On Friends Wall with FeedDialog

-(void)postOnFriendFacebookWallWithDialog:(NSMutableDictionary *)dictPost WithFBCompletionBlock:(FBCompletionBlock)fbCompletion
{
    [dictPost setObject:FBID forKey:@"app_id"];
    [dictPost setObject:@"feed" forKey:@"method"];
    
    // Invoke the dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:self.session//[FBSession activeSession]
                                           parameters:dictPost
                                              handler:
     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Case A: Error launching the dialog or publishing story.
             //NSLog(@"Error publishing story.");
             fbCompletion(nil,error);
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // Case B: User clicked the "x" icon
                 // NSLog(@"User canceled story publishing.");
                 fbCompletion(nil,[NSError errorWithDomain:@"StoryPublishing" code:6969 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"User canceled story publishing.",@"Info", nil]]);
             }
             else {
                 // Case C: Dialog shown and the user clicks Cancel or Share
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 
                 if (![urlParams valueForKey:@"post_id"]) {
                     // User clicked the Cancel button
                     //NSLog(@"User canceled story publishing.");
                     fbCompletion(nil,[NSError errorWithDomain:@"StoryPublishing" code:6969 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"User canceled story publishing.",@"Info", nil]]);
                 }
                 else {
                     // User clicked the Share button
                     NSString *postID = [urlParams valueForKey:@"post_id"];
                     // NSLog(@"Posted story, id: %@", postID);
                     fbCompletion(postID,error);
                 }
                 
             }
         }
     }];
}

- (NSDictionary*)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

-(void)getCommentsOfPost:(NSString *)postID WithCompletionBlock:(FBFriendCompletionBlock)fbFriends
{
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"%@/comments/?fields=from,message",postID]];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             NSArray* friends = [result objectForKey:@"data"];
             fbFriends(friends,error);
         }
         else{
             fbFriends(nil,error);
         }
     }];
    
}


-(void)sendCommentsOfPost:(NSString *)postID andMsg:(NSString *)strMsg WithCompletionBlock:(FBCompletionBlock)fbCompletion
{
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"%@/comments?message=%@",postID,strMsg]];
    friendsRequest.HTTPMethod=@"POST";
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             fbCompletion(result,nil);
         }
         else{
             fbCompletion(nil,error);
         }
     }];
    
}


-(void)searchPost:(NSString *)searchString WithCompletionBlock:(FBCompletionBlock)fbResult
{
    searchString=[searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"search?type=post&q=%@",searchString]];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             fbResult(result,error);
         }
         else{
             fbResult(nil,error);
         }
     }];
    
}

-(void)searchHomePost:(NSString *)searchString WithCompletionBlock:(FBCompletionBlock)fbResult
{
    searchString=[searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //@"me/home?type=post&q=%@"
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"me/home?q=%@",searchString]];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             fbResult(result,error);
         }
         else{
             fbResult(nil,error);
         }
     }];
    
}

#pragma mark -
#pragma mark - NewFB

-(void)getUserAlbumsListWithLastPhotoCompletionBlock:(FBCompletionBlock)fbResult
{
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"me/albums?fields=photos.limit(1),id,cover_photo,from,name,count"]];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             NSArray *arrAlums=[result objectForKey:@"data"];
             fbResult(arrAlums,error);
         }
         else{
             fbResult(nil,error);
         }
     }];
}

-(void)getUserAlbumsWithCompletionBlock:(FBCompletionBlock)fbResult
{
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"me/albums/?fields=name"]];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             NSArray *arrAlums=[result objectForKey:@"data"];
             fbResult(arrAlums,error);
         }
         else{
             fbResult(nil,error);
         }
     }];
}

-(void)getUserProfilePicturesAlbumsWithCompletionBlock:(FBCompletionBlock)fbResult
{
    [self getUserAlbumsWithCompletionBlock:^(id response, NSError *error) {
        if (!error) {
            if (response) {
                NSDictionary *dictPP=nil;
                for (NSDictionary *dict in response) {
                    if ([[dict objectForKey:@"name"]isEqualToString:@"Profile Pictures"]) {
                        dictPP=dict;
                    }
                }
                if (dictPP==nil) {
                    fbResult(nil,[NSError errorWithDomain:@"No Albums" code:900 userInfo:nil]);
                }else{
                    fbResult(dictPP,nil);
                }
            }
            else{
                fbResult(nil,[NSError errorWithDomain:@"No Albums" code:900 userInfo:nil]);
            }
        }
        else{
            fbResult(nil,error);
        }
    }];
}

-(void)getAlbumsPhotos:(NSString *)albumID WithCompletionBlock:(FBCompletionBlock)fbResult
{
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"%@/photos?fields=source&limit=5",albumID]];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             NSArray *arrPhotos=[result objectForKey:@"data"];
             fbResult(arrPhotos,error);
         }
         else{
             fbResult(nil,error);
         }
     }];
}

-(void)getAlbumsPhotos:(NSString *)albumID withLimit:(int)limit WithCompletionBlock:(FBCompletionBlock)fbResult
{
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"%@/photos?fields=source&limit=%d",albumID,limit]];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             NSArray *arrPhotos=[result objectForKey:@"data"];
             fbResult(arrPhotos,error);
         }
         else{
             fbResult(nil,error);
         }
     }];
}

#pragma mark -
#pragma mark - Mutable Friends

-(void)getMutualFriendsForUserID:(NSString *)userID WithCompletionBlock:(FBCompletionBlock)fbResult
{
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"%@?fields=context.fields(mutual_friends)",userID]];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             NSArray *arrPhotos=[result objectForKey:@"data"];
             fbResult(arrPhotos,error);
         }
         else{
             fbResult(nil,error);
         }
     }];
}

-(void)getMutualFriendsWithImageForUserID:(NSString *)userID WithCompletionBlock:(FBCompletionBlock)fbResult
{
    NSMutableArray *myFriends=[[NSMutableArray alloc]init];
    NSMutableArray *friendFriends=[[NSMutableArray alloc]init];
    NSMutableArray *mutualFriend=[[NSMutableArray alloc]init];
    
    [self fetchFriendsWithFBFriendCompletionBlock:^(NSArray *friends, NSError *error) {
        if (friends) {
            [myFriends addObjectsFromArray:friends];
        }
        [self getFriendsFriends:userID WithLimit:200 WithCompletionBlock:^(id response, NSError *error) {
            if (response) {
                [friendFriends addObjectsFromArray:response];
            }
            for (int i=0; i<[myFriends count]; i++) {
                NSDictionary *dictMyFri=[myFriends objectAtIndex:i];
                NSString *myFriID=[dictMyFri objectForKey:@"id"];
                for (int j=0; j<[friendFriends count]; j++) {
                    NSDictionary *dictFriFri=[myFriends objectAtIndex:j];
                    NSString *FriFriID=[dictFriFri objectForKey:@"id"];
                    
                    if ([myFriID isEqualToString:FriFriID]) {
                        [mutualFriend addObject:dictMyFri];
                    }
                    
                }
            }
            fbResult(mutualFriend,nil);
        }];
    }];
}


#pragma mark -
#pragma mark - Likes

-(void)getMyLikesWithLimit:(int)limit WithCompletionBlock:(FBCompletionBlock)fbResult
{
    [self getFriendsLikes:@"me" WithLimit:limit WithCompletionBlock:^(id response, NSError *error) {
        if (response) {
            [self.arrFBLikesList removeAllObjects];
            [self.arrFBLikesList addObjectsFromArray:response];
        }
        fbResult(response,error);
    }];
}

-(void)getFriendsLikes:(NSString *)userID WithLimit:(int)limit WithCompletionBlock:(FBCompletionBlock)fbResult
{
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"%@/likes?fields=picture.type(small),name&limit=%d",userID,limit]];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             NSArray *arrLikes=[result objectForKey:@"data"];
             fbResult(arrLikes,error);
         }
         else{
             fbResult(nil,error);
         }
     }];
}

#pragma mark -
#pragma mark - Mutable Likes

-(void)getMutualLikesForUserID:(NSString *)userID WithCompletionBlock:(FBCompletionBlock)fbResult
{
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"%@?fields=context.fields(mutual_likes)",userID]];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             NSArray *arrPhotos=[result objectForKey:@"data"];
             fbResult(arrPhotos,error);
         }
         else{
             fbResult(nil,error);
         }
     }];
}

#pragma mark -
#pragma mark - Mutable Likes And Friends

//100001404765028?fields=context.fields(mutual_likes,mutual_friends)

-(void)getMutualLikesAndFriendsForUserID:(NSString *)userID WithCompletionBlock:(FBCompletionBlock)fbResult
{
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"%@?fields=context.fields(mutual_likes,mutual_friends)",userID]];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             fbResult(result,error);
         }
         else{
             fbResult(nil,error);
         }
     }];
}


@end
