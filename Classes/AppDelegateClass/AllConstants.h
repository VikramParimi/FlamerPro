//
//  AllConstants.h
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//


#import "TinderAppDelegate.h"

//Views Index
enum ViewType {
    TagMenuVIEW = 0,
    TagHomeView,
    TagChatView ,
    TagMomentsView,
};

//sex selection
typedef enum : NSUInteger{
    EntSexMale=1,
    EntSexFemale=2
}EntSex;

//pref sex selection
typedef enum : NSUInteger{
    EntPrefSexMale=1,
    EntPrefSexFemale=2,
    EntPrefSexBoth=3
}EntPrefSex;


//Image upload
typedef enum : NSUInteger{
    EntImageFlagProfilePic=1,
    EntImageFlagOther=2
}EntImageFlag;


//User action
typedef enum : NSUInteger{
    EntUserActionLike=1,
    EntUserActionDislike=2
}EntUserAction;

//User Block Unblock flag
typedef enum : NSUInteger{
    EntFlagUnblock=3,
    EntFlagBlock=4
}EntFlag;





//Api Url
//#define API_URL    @"http://srsahu.com/tinderclone/process.php/"
//#define API_URL    @"http://localhost/Flamer/process.php/"
//#define API_URL    @"http://104.236.104.6/tindercloneApp/app/process.php/"
//#define API_URL    @"http://104.236.104.6/flamerpro_web/process.php/"
#define API_URL    @"http://provenlogic.info/flamerpro_web/process.php/"
//#define API_URL    @"http://52.32.31.42/process.php/" //API for magnet

//origin.
#define is_OPEN_FIRE YES
#define MESSAGE_TYPING_CONS @"typing"
#define MESSAGE_TYPING_CANCEL_CONS @"typing_cancel"

//Tinder
#define NOTIFICATION_TINDER_UPDATE_MESSAGE_COUNTER @"tinderupdateMessages"
#define NOTIFICATION_TINDER_LOGGED_IN @"notification_tinder_connected"

//origin.
#define NOTIFICATION_XMPP_LOGGED_IN @"notification_xmpp_connected"
#define NOTIFICATION_XMPP_FRIENDS_PRESENCE_UPDATE @"friendPresenceUpdated"
#define NOTIFICATION_XMPP_UPDATE_MESSAGE_COUNTER @"updateMessageCounter"
#define NOTIFICATION_XMPP_LAST_MESSAGE_STATUS_CHANGED @"lastMessageStatusChanged"
#define NOTIFICATION_XMPP_MESSAGE_STATUS_CHANGED @"messageStatusChanged"
#define NOTIFICATION_XMPP_MESSAGE_RECEIVE_TYPING_STATUS @"receiveTypingStatus"
#define NOTIFICATION_XMPP_STREAM_CONNECTED @"XMPP_STREAM_CONNECTED"


#define NOTIFICATION_SCREEN_NAVIGATION_BUTTON_CLICKED @"notification_Screen_Navigation"
#define NOTIFICATION_CHATSCREEN_REFRESH @"notification_chatScreen_refresh"
#define NOTIFICATION_HOMESCREEN_REFRESH @"notification_homeScreen_refresh"
#define NOTIFICATION_MOMENTSCREEN_REFRESH @"notification_momentScreen_refresh"
#define NOTIFICATION_MENUSCREEN_REFRESH @"notification_menuScreen_refresh"

#define NOTIFICATION_NEW_MOMENT_CREATED_DELETED @"notification_Moment_Created_Deleted"

#define KeyForScreenNavigation @"tagScreenNavigation"

#define APPDELEGATE (TinderAppDelegate*)[[UIApplication sharedApplication] delegate]

#define ScreenSize [UIScreen mainScreen].bounds.size

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

//iOS7 Or less
#define IS_IOS7 (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
//iPad/iPhone
#define IS_iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_iPhone ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)


//Colors
#define COLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define COLOR_BACKGROUND [UIColor colorWithRed:(230.0/255) green:(224.0/255) blue:(202.0/255) alpha:1.0]

//iPhone5 helper
#define IS_iPhone5 ([UIScreen mainScreen].bounds.size.height == 568.0)
#define ASSET_BY_SCREEN_HEIGHT(regular) (([[UIScreen mainScreen] bounds].size.height <= 480.0) ? regular : [regular stringByAppendingString:@"-568h"])

#define SET_XIB(regular) (isiPhone ? regular : [regular stringByAppendingString:@"_iPad"])

//Api Methods
#define POST_METHOD             @"POST"
#define GET_METHOD              @"GET"
#define PUT_METHOD              @"PUT"

//DateFormate
#define DateFormat              @"yyyy-mm-dd HH:MM:SS"//"2013-09-13 14:02:49"


#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif


//USER DEFAULTS
#define USER_DEFAULT        [NSUserDefaults standardUserDefaults]
#define USER_DEFAULT_SYNC   [[NSUserDefaults standardUserDefaults] synchronize]

//Xmpp

#define XmppJidPrefix @"tinderclone_"

#define CHAT_SERVER_ADDRESS @"104.236.104.6"// @"doubbletaptesting.com"//
#define XMPP_HOST         @"http://104.236.104.6:9090"//  @"doubbletaptesting.com"//
#define XMPP_OUTGOING_SERVER  @"http://104.236.104.6:9090"// @"doubbletaptesting.com"//
#define XMPP_HOST_PORT          5222

#define CHAT_SERVER_ADDRESS_Event @"104.236.104.6"

//self User Name
#define MY_USER_NAME        [USER_DEFAULT stringForKey:kKeyUDAMNUserName]
#define MY_PASSWORD         [USER_DEFAULT stringForKey:kKeyUDAMNPassword]

#define Show_AlertView(title , msg) [[[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show]

#define ShowAlertForNoNetwork [[[UIAlertView alloc]initWithTitle:@"Error!" message:@"Network not available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show]

// Sex
#define FEMALE 2
#define MALE   1
#define BOTH  3

#define KM     4
#define MILE    3

//menu btnTag

#define  PROFILE  10
#define  HOME    11
#define  DISCOVERY_PREFERENCE 12
#define  APP_SETTINGS 13
#define  INVITE   14
#define  QUESTION 15

// Controller
#define HOME_CONTROLER 1
#define CHAT_CONTROLER 2
#define PROMOTE_CONTROLER 3

//Facebbok Detail
#define  FACEBOOK_EDUCATION         @"education"
#define  FACEBOOK_EMAIL             @"email"
#define  FACEBOOK_GENDER            @"gender"
#define  FACEBOOK_HOMETOWN          @"hometown"
#define  FACEBOOK_LANGUAGE          @"languages"
#define  FACEBOOK_LASTNAME          @"last_name"
#define  FACEBOOK_FIRSTNAME         @"first_name"
#define  FACEBOOK_LANGUAGE          @"languages"
#define  FACEBOOK_LOCATION          @"location"
#define  FACEBOOK_NAME              @"name"
#define  FACEBOOK_USERNAME          @"username"
#define  FACEBOOK_BIO               @"bio"
#define  FACEBOOK_BIRTHDAY          @"birthday"
#define  FACEBOOK_ID                @"id"
#define  FACEBOOK_AGERANGE          @"age_range"
#define  FACEBOOK_LIKES             @"likes"
#define  FACEBOOK_INTRESTED_IN      @"interested_in"

//location
#define LOCATION_ID                 @"id"
#define LOCATION_NAME               @"name"

//AGERANGE
#define AGERANGE_MIN                @"min"
#define AGERANGE_MAX                @"max"

//Fonts
#define SEGOUE_BOLD                 @"SegoeUI-Bold"
#define SEGOUE_UI                   @"SegoeUI"
#define HELVETICALTSTD_LIGHT        @"HelveticaLTStd-Light"
#define HELVETICALTSTD_ROMAN        @"HelveticaLTStd-Roman"
#define HESTERISTICO_BOLD           @"Hasteristico-Bold "
#define HESTERISTICO                @"Hasteristico-Light"

//COLORS
#define WHITE_COLOR  [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define TEMPLTE1_RED_COLOR  [UIColor colorWithRed:194.0/255.0 green:52.0/255.0 blue:52.0/255.0 alpha:1.0]
#define TEMPLTE1_TEMPTEXT_COLOR [UIColor colorWithRed:274.0/255.0 green:72.0/255.0 blue:72.0/255.0 alpha:1.0]

#define TEMPLTE2_TEXTCOLOR [UIColor colorWithRed:129.0/255.0 green:221.0/255.0 blue:229.0/255.0 alpha:1.0]

#define ACCORDIAN_TEXT_COLOR [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]
#define SECTION_TEXT_COLOR [UIColor colorWithRed:0.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]

#define Templte4_TEXTCOLOR   [UIColor colorWithRed:38.0/255.0 green:108.0/255.0 blue:108.0/255.0 alpha:1.0]

#define VIEW_BACKGROUND_COLOR  [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5]

#define SHOWER_COLOR  [UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define TOPVIEW_COLOR [UIColor colorWithRed:15.0/255.0 green:105.0/255.0 blue:101.0/255.0 alpha:1.0]
#define PAGECONTROL_COLOR  [UIColor colorWithRed:266.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1.0]

#define FACEBOOK_COLOR  [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0]
#define RED_STRIP_COLOR  [UIColor colorWithRed:200.0/255.0 green:48.0/255.0 blue:47.0/255.0 alpha:1.0]

#define LOCATEANDMORE_COLOR  [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0]

#define ACTION_SHEET_COLOR [UIColor colorWithRed:255.0/255 green:92.0/255 blue:94.0/255 alpha:1.0]

#define CLEAR_COLOR  [UIColor clearColor]
//#define WHITE_COLOR  [UIColor whiteColor]
#define BLACK_COLOR  [UIColor blackColor]
#define LIGHT_GRAY_COLOR  [UIColor lightGrayColor]

#define ARRAY_FBPERMISSION_MAIN [NSArray arrayWithObjects:@"user_photos",@"friends_photos",@"user_birthday",@"email",@"user_relationship_details",@"publish_stream",@"publish_actions", nil]



//Fonts Helper
extern NSString *const FontRegular;
extern NSString *const FontBold;

//Entity Helper
extern NSString *const ENTITY_GETPROFILE;//GetProfile
extern NSString *const ENTITY_LOGIN;//Login
extern NSString *const ENTITY_MATCHEDUSERLIST;//MatchedUserList
extern NSString *const ENTITY_MESSAGETABLE;//MessageTable
extern NSString *const ENTITY_UPLOADIMAGES;//UploadImages
extern NSString *const ENTITY_EDITPROFILE;//EditProfile

//Methods or Paths for Webservice
extern NSString *const METHOD_LOGIN;//login
extern NSString *const METHOD_FINDMATCHES;//findMatches
extern NSString *const METHOD_GETPROFILEMATCHES;//getProfileMatches
extern NSString *const METHOD_GETCHATSYNC;//getChatSync
extern NSString *const METHOD_BLOCKUSER;//blockUser
extern NSString *const METHOD_GETPROFILE;//getProfile
extern NSString *const METHOD_UPDATEPREFERENCES;//updatePreferences
extern NSString *const METHOD_GETPREFERENCES;//getPreferences
extern NSString *const METHOD_GET_QUESTION;//get_quetion
extern NSString *const METHOD_GET_QUESTION_ANS_INSERT;//get_question_ans_insert
extern NSString *const METHOD_GET_USER_PROFILE_PIC;//get_user_profile_pic
extern NSString *const METHOD_UPLOAD_USER_IMAGE;//upload_user_image
extern NSString *const METHOD_DELETE_USER_IMAGE;//delete_user_Image
extern NSString *const METHOD_UPDATELOCATIONS;//updateLocation
extern NSString *const METHOD_UPDATE_PROFILE_PIC;//update_profile_pic
extern NSString *const METHOD_UPDATE_STATUS;//update_status
extern NSString *const METHOD_CREATE_MOMENT;
extern NSString *const METHOD_GET_MOMENTS;
extern NSString *const METHOD_DELETE_MOMENT;
extern NSString *const METHOD_LIKE_DISLIKE_MOMENT;
extern NSString *const METHOD_GET_ACTIVITIES;
extern NSString *const METHOD_UNMATCH;

extern NSString *const METHOD_SETLIKES;//setLikes
extern NSString *const METHOD_INVITEACTION;//inviteAction
extern NSString *const METHOD_GETNOTIFICATIONS;//getNotifications
extern NSString *const METHOD_EDITPROFILE;//editProfile
extern NSString *const METHOD_SENDMESSAGE;//sendMessage
extern NSString *const METHOD_GETCHATHISTORY;//getChatHistory
extern NSString *const METHOD_GETCHATMESSAGE;//getChatMessage
extern NSString *const METHOD_LOGOUT;//logout
extern NSString *const METHOD_UPDATESESSION;//updateSession
extern NSString *const METHOD_DELETEACCOUNT;//deleteAccount
extern NSString *const METHOD_GETQUESTION;//getQuestion
extern NSString *const METHOD_USER_ANSWER;//User_answer
extern NSString *const METHOD_UPDATE_PREFERENCES_TIME;//update_Preferences_time
extern NSString *const METHOD_DELETE_MESSAGE;//delete_message
extern NSString *const METHOD_GET_DETAIL_QUE;//get_detail_que
extern NSString *const METHOD_GET_DETAIL_ANS_INSERT;//get_detail_ans_insert
extern NSString *const METHOD_GET_DETAIL_OPTION;//get_detail_Option
extern NSString *const METHOD_GET_ABOUT_QUE;//get_about_que
extern NSString *const METHOD_GET_ABT_ANS_INSERT;//get_abt_ans_insert
extern NSString *const METHOD_PROMOTED_LIST;//Promoted_list
extern NSString *const METHOD_PROMOTED_ME;//promote_me
extern NSString *const METHOD_ADDLIKES;//addLikes
extern NSString *const METHOD_ADDFRIENDS_ID;//addFriends_id
extern NSString *const METHOD_MUTUAL_FRIEND;//mutual_friend
extern NSString *const METHOD_UPLOAD_IMAGE;
extern NSString *const METHOD_GET_APPSETTINGS;
extern NSString *const METHOD_UPDATE_APPSETTINGS;


//PARAMS
extern NSString *const PARAM_ENT_FBID;//ent_fbid
extern NSString *const PARAM_ENT_FIRST_NAME;//ent_first_name
extern NSString *const PARAM_ENT_LAST_NAME;//ent_last_name
extern NSString *const PARAM_ENT_SEX;//ent_sex
extern NSString *const PARAM_ENT_PUSH_TOKEN;//ent_push_token
extern NSString *const PARAM_ENT_CURR_LAT;//ent_curr_lat
extern NSString *const PARAM_ENT_CURR_LONG;//ent_curr_long
extern NSString *const PARAM_ENT_DOB;//ent_dob
extern NSString *const PARAM_ENT_PROFILE_PIC;//ent_profile_pic
extern NSString *const PARAM_ENT_DEVICE_TYPE;//ent_device_type
extern NSString *const PARAM_ENT_USER_FBID;//ent_user_fbid
extern NSString *const PARAM_ENT_LAST_MESS_ID;//ent_last_mess_id
extern NSString *const PARAM_ENT_RECEVER_USER_FBID;//ent_recever_user_fbid
extern NSString *const PARAM_ENT_MESSAGE;//ent_message
extern NSString *const PARAM_ENT_FLAG;//ent_flag
extern NSString *const PARAM_ENT_USER_BLOCK_FBID;//ent_user_block_fbid
extern NSString *const PARAM_ENT_PREF_SEX;//ent_pref_sex
extern NSString *const PARAM_ENT_PREF_LOWER_AGE;//ent_pref_lower_age
extern NSString *const PARAM_ENT_PREF_UPPER_AGE;//ent_pref_upper_age
extern NSString *const PARAM_ENT_PREF_RADIUS;//ent_pref_radius
extern NSString *const PARAM_ENT_JSON;//ent_json
extern NSString *const PARAM_ENT_USERIMAGE;//ent_userimage
extern NSString *const PARAM_ENT_INDEX_ID;//ent_index_id
extern NSString *const PARAM_ENT_IMAGE_ID;//ent_image_id

extern NSString *const PARAM_ENT_NEW_PRF_INDEX_ID;//ent_new_prf_index_id
extern NSString *const PARAM_ENT_NEW_IMAGE_ID;//ent_new_image_id
extern NSString *const PARAM_ENT_USER_RECEVER_FBID;//ent_user_recever_fbid
extern NSString *const PARAM_ENT_STATUS;//ent_status

extern NSString *const PARAM_ENT_SESS_TOKEN;//ent_sess_token
extern NSString *const PARAM_ENT_DEV_ID;//ent_dev_id

extern NSString *const PARAM_ENT_EMAIL;//ent_email
extern NSString *const PARAM_ENT_CITY;//ent_city
extern NSString *const PARAM_ENT_COUNTRY;//ent_country
extern NSString *const PARAM_ENT_TAG_LINE;//ent_tag_line
extern NSString *const PARAM_ENT_PERS_DESC;//ent_pers_desc

extern NSString *const PARAM_ENT_QBID;//ent_qbid
extern NSString *const PARAM_ENT_AUTH_TYPE;//ent_auth_type



extern NSString *const PARAM_ENT_DISTANCE_TYPE;//ent_distance_type
extern NSString *const PARAM_ENT_PROF_URL;//ent_prof_url
extern NSString *const PARAM_ENT_OTHER_URLS;//ent_other_urls
extern NSString *const PARAM_ENT_IMAGE_NAME;//ent_image_name
extern NSString *const PARAM_ENT_IMAGE_FLAG;//ent_image_flag
extern NSString *const PARAM_ENT_INVITEE_FBID;//ent_invitee_fbid
extern NSString *const PARAM_ENT_USER_ACTION;//ent_user_action

extern NSString *const PARAM_ENT_DATETIME;//ent_datetime

extern NSString *const PARAM_ENT_MSG_ID;//ent_msg_id
extern NSString *const PARAM_ENT_CHAT_PAGE;//ent_chat_page
extern NSString *const PARAM_ENT_IOS_CER;//ent_ios_cer
extern NSString *const PARAM_ENT_CER_PASS;//ent_cer_pass
extern NSString *const PARAM_ENT_CER_TYPE;//ent_cer_type
extern NSString *const PARAM_ENT_D_ID;//ent_d_id
extern NSString *const PARAM_ENT_TYPE;//ent_type
extern NSString *const PARAM_ENT_YOUR_ANS;//ent_your_ans
extern NSString *const PARAM_ENT_FEET;//ent_feet
extern NSString *const PARAM_ENT_INCHES;//ent_inches
extern NSString *const PARAM_ENT_CENTIMETERS;//ent_Centimeters
extern NSString *const PARAM_ENT_ABT_ID;//ent_abt_id
extern NSString *const PARAM_ENT_PROMOTE_ME;//ent_promote_me
extern NSString *const PARAM_ENT_MEDIA_CHUNK;//media_chunk


extern NSString *const PARAM_ENT_LIKES;//ent_likes
extern NSString *const PARAM_ENT_NAMES;//ent_names
extern NSString *const PARAM_ENT_PICTURES;//ent_pictures

extern NSString *const PARAM_ENT_FRD_FB_ID;//ent_frd_fb_id
extern NSString *const PARAM_ENT_FRD_NAMES;//ent_frd_names
extern NSString *const PARAM_ENT_FRD_PICS;//ent_frd_pics
extern NSString *const PARAM_ENT_FRIEND_ID;//ent_friend_id
extern NSString *const PARAM_ENT_PROFILE_PIC_DATA;
extern NSString *const PARAM_ENT_MOMENT_ID;

//constants
FOUNDATION_EXPORT NSString *const kKeyUDAMNUserName;
FOUNDATION_EXPORT NSString *const kKeyUDAMNPassword;



