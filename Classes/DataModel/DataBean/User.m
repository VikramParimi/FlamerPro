//
//  User.m
//  Tinder
//
//  Created by Elluminati - macbook on 07/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "User.h"
#import "Photo.h"
#import "SingleChatMessage.h"
#import "AFHTTPRequestOperation.h"

@implementation User

@synthesize fbid,fbToken, first_name,last_name,sex,push_token,curr_lat,curr_long,dob,profile_pic,flag,
            name,bio,gender, discoverable,dateCreated,dateOfBirth,lastActive,
            xAuthToken,tinderID,ageFilterMin,ageFilterMax,distanceFilter,liked,match,mainUser,photos
            , commonLikesCount,commonFriendsCount;

@dynamic friend_JID;
@dynamic friend_Name;
@dynamic friend_DisplayName;
//@dynamic lastMessage;
@dynamic lastMessageTime;
//@dynamic messageCount;
@dynamic profileImage;
@dynamic presenceStatus;
@dynamic isBlocked;
@dynamic lastMessageStatus;
@dynamic lastMessageID;

#pragma mark -
#pragma mark - Init

-(id)init{
    
    if((self = [super init]))
    {
         [self setUser];
    }
    return self;
}

+(User *)currentUser
{
    static User *user = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [[User alloc] init];
    });
    return user;
}


+(User*) create
{
    User *user = [[User alloc] init];
    return user;
}

- (int) getAge
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];
    NSInteger curyear = [calendar component:NSCalendarUnitYear fromDate:date];
    NSInteger birthyear = [calendar component:NSCalendarUnitYear fromDate:dateOfBirth];
    int age = (int) (curyear - birthyear);
    return age;
}

-(void)setUser{
    
    if([[UserDefaultHelper sharedObject]facebookLoginRequest]!=nil) {
        NSMutableDictionary *dictParam=[[UserDefaultHelper sharedObject] facebookLoginRequest];
        fbid=[dictParam objectForKey:PARAM_ENT_FBID];
        fbToken = [[UserDefaultHelper sharedObject] facebookToken];
        first_name=[dictParam objectForKey:PARAM_ENT_FIRST_NAME];
        last_name=[dictParam objectForKey:PARAM_ENT_LAST_NAME];
        sex=[dictParam objectForKey:PARAM_ENT_SEX];
        push_token=[dictParam objectForKey:PARAM_ENT_PUSH_TOKEN];
        curr_lat=[USERDEFAULT objectForKey:UD_CURRENTLATITUDE];
        curr_long=[USERDEFAULT objectForKey:UD_CURRENTLONGITUDE];
        dob=[dictParam objectForKey:PARAM_ENT_DOB];
        profile_pic=[dictParam objectForKey:PARAM_ENT_PROFILE_PIC];
    }
}

-(void)save
{
    
}

-(int) messageCount
{
    return  (int)[self.messages count];
}

-(NSString*) lastMessage
{
    NSString* msg = nil;
    
    if (self.messages != nil)
    {
        SingleChatMessage* lastMessage = (SingleChatMessage*)[self.messages objectAtIndex:(self.messages.count - 1)];
        msg = lastMessage.message;
    }
    return msg;
}

-(void)addMessages:(NSArray *)objects
{
    if (self.messages == nil){
        self.messages = [[NSMutableArray alloc] init];
    }
    [self.messages addObjectsFromArray:objects];
}

-(void)removeMessages
{
    if (self.messages == nil)
        [self.messages removeAllObjects];
}


-(Photo*) photoIndex:(int)index{
    Photo* photo;
    if (self.photos == nil)
    {
        NSArray* ptarray = [self.photos allObjects];
        if( index < [ptarray count])
        {
            photo = [ptarray objectAtIndex:index];
        }
    }
    return photo;
}

-(void)addPhotos:(NSMutableSet*)aphotos
{
    if (self.photos == nil)
    {
        self.photos = [NSMutableSet new];
    }
    //!aphotos?[self.photos unionSet:aphotos]:NSLog(@"Do Nothing");
   // [self.photos unionSet:aphotos];
    self.photos = [aphotos copy];
}

-(int) photoCount
{
    int count = 0;
    if (self.photos != nil)
        count = (int)self.photos.count;
    return count;
}

-(void)removePhotos:(NSMutableSet*)aphotos
{
    !aphotos?[aphotos removeAllObjects]:NSLog(@"No Elements to remove");
}

-(NSString*) lastActiveString
{
    NSDateFormatter *dateFormatter;
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    return [dateFormatter stringFromDate:lastActive];
}

@end
