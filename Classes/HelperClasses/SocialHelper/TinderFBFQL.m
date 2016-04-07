//
//  TinderFBFQL.m
//  Tinder
//
//  Created by Vinay Raja on 07/12/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "TinderFBFQL.h"
#import "SDWebImageDownloader.h"
#import "DBHelper.h"

@interface TinderFBFQL ()
{
    
}

@end

@implementation TinderFBFQL


+(BOOL)isSessionActive
{
    return FBSession.activeSession.isOpen;
}

+(void)updateFacebookSession {
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // If there's one, just open the session silently, without showing the user the login UI
        //NSArray *permission = @[@"user_photos",@"friends_photos",@"read_stream"];
        NSArray *permission = ARRAY_FBPERMISSION_MAIN;

        [FBSession openActiveSessionWithPublishPermissions:permission defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            // Handler for session state changes
            // This method will be called EACH time the session state changes,
            // also for intermediate states and NOT just when the session open
            //[self sessionStateChanged:session state:state error:error];
            if (status == FBSessionStateOpen ) {
                DLog(@"session stat open");
            }
        }];
        // If there's no cached session, we will show a login button
    }
}

+(void)openCreateFBSession:(id<TinderFBFQLDelegate>)delegate
{
    if (!FBSession.activeSession.isOpen)
    {
        NSArray *permission = ARRAY_FBPERMISSION_MAIN;
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithPublishPermissions:permission defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:error.localizedDescription
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }];
        
    }
}

#pragma mark -
#pragma mark - FQL-ProfileImage

+ (void)executeFQlForProfileImage:(id<TinderFBFQLDelegate>)delegate
{
    NSArray __block *profileImg;
    
    // Query to fetch the active user's friends, limit to 25.
    NSString *query = [NSString stringWithFormat:@"SELECT src_big from photo  where album_object_id IN (SELECT  object_id  FROM album WHERE owner='%@' and name='Profile Pictures') LIMIT 5",[[[UserDefaultHelper sharedObject] facebookUserDetail] objectForKey:FACEBOOK_ID]];
  
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": query };
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  DLog(@"Error: %@", [error localizedDescription]);
                              } else {
                                  DLog(@"Result: %@ %s", result, __func__);
                                  // Get the friend data to display
                                  profileImg = (NSArray *) result[@"data"];
                                  NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
                                  for(NSDictionary *url in profileImg) {
                                      [imagesArray addObject:url[@"src_big"]];
                                  }
                                  
                                  [self gotImageURLs:imagesArray withDelegate:delegate];
                                  
                              }
                          }];
}

+(void)gotImageURLs:(NSArray*)imageURLs withDelegate:(id<TinderFBFQLDelegate>)delegate
{
    [[DBHelper sharedObject]deleteObjectsForEntity:ENTITY_UPLOADIMAGES];
    DataBase * da = [DataBase sharedInstance];
    [da performSelectorOnMainThread:@selector(makeDataBaseEntryForUploadImages:) withObject:imageURLs waitUntilDone:YES];
    [delegate performSelector:@selector(uploadImage:) withObject:imageURLs];
    
    for (int i = 0; i<imageURLs.count; i++)
    {
        if (i==0) {
            
            [[DataBase sharedInstance] saveImageToDocumentsDirectoryForLogin :[imageURLs objectAtIndex:i]:i];
            if (i==0) {
                [delegate performSelector:@selector(doneLoadingProfileImage:) withObject:[[UserDefaultHelper sharedObject] fbProfileURL]];
            }
        }
        else{
            [[DataBase sharedInstance] saveImageToDocumentsDirectoryForLogin :[imageURLs objectAtIndex:i]:i];
        }
    }
    [delegate performSelector:@selector(doneDownloadingProfileImages) withObject:nil];
}

+(void)saveImage:(NSDictionary*)dict
{
    [[DataBase sharedInstance] saveProfileImage:dict[@"local"] andFBURL:dict[@"fb"]];
}

+ (void)executeFQlForMatchProfileForId:(NSString*)fbid andDelegate:(id<TinderFBFQLDelegate>)delegate
{
    NSString *query = [NSString stringWithFormat:@"{'FriendsNumber':select mutual_friend_count from user WHERE uid = '%@','IntrestNumber': select page_fan_count from user WHERE uid = '%@',}",fbid,fbid];
   
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": query };
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              
                              NSDictionary * dict =result[@"data"];
                              NSLog(@"countfrnd%@",[dict objectForKey:@"mutual_friend_count"]);
                              
                              [[[UserDefaultHelper sharedObject] facebookUserDetail] setObject:[dict objectForKey:@"mutual_friend_count"] forKey:@"MUTUALFRND"];
                          }
     ];
}

//mutual friend
+ (void)executeFQlForMutualFriendForId:(NSString*)fbid andFriendId :(NSString*)FriendId andDelegate:(id<TinderFBFQLDelegate>)delegate{
    
    NSString *query = [NSString stringWithFormat:@"SELECT uid, first_name, last_name, pic_small FROM user WHERE uid IN (SELECT uid2 FROM friend where uid1='%@' and uid2 in (SELECT uid2 FROM friend where uid1=me()))",FriendId];

    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": query };
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              
                              NSArray *friendInfo = (NSArray *) result[@"data"];
                              
                              
                              [delegate performSelector:@selector(loadImageForSharedFrnd:) withObject:friendInfo];
                              
                          }
     ];
}

//mutual intrest
+ (void)executeFQlForMutualLikesForId:(NSString*)fbid andFriendId :(NSString*)FriendId andDelegate:(id<TinderFBFQLDelegate>)delegate{
    
    NSString *query = [NSString stringWithFormat:@"SELECT pic_square,name from page where page_id IN (SELECT page_id  FROM page_fan WHERE uid= '%@' AND page_id IN (SELECT page_id FROM page_fan WHERE uid = '%@'))",[[[UserDefaultHelper sharedObject] facebookUserDetail] objectForKey:FACEBOOK_ID],FriendId];

    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": query };
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              
                              
                              NSArray *friendIntrest = (NSArray *) result[@"data"];
                              
                              [delegate performSelector:@selector(loadImageForSharedIntrest:) withObject:friendIntrest];
                          }
     ];
}

@end
