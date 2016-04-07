//
//  AllConstants.m
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//


#import "AllConstants.h"

//Fonts Helper
NSString *const FontRegular = @"LobsterTwo";
NSString *const FontBold = @"LobsterTwo-Bold";

//Entity Helper
NSString *const ENTITY_GETPROFILE=@"GetProfile";
NSString *const ENTITY_LOGIN=@"Login";
NSString *const ENTITY_MATCHEDUSERLIST=@"MatchedUserList";
NSString *const ENTITY_MESSAGETABLE=@"MessageTable";
NSString *const ENTITY_UPLOADIMAGES=@"UploadImages";

NSString *const ENTITY_EDITPROFILE=@"EditProfile";

//Methods or Paths for Webservice
NSString *const METHOD_LOGIN=@"login";
NSString *const METHOD_FINDMATCHES=@"findMatches";
NSString *const METHOD_GETPROFILEMATCHES=@"getProfileMatches";
NSString *const METHOD_GETCHATSYNC=@"getChatSync";
NSString *const METHOD_BLOCKUSER=@"blockUser";
NSString *const METHOD_GETPROFILE=@"getProfile";
NSString *const METHOD_UPDATEPREFERENCES=@"updatePreferences";
NSString *const METHOD_GETPREFERENCES=@"getPreferences";
NSString *const METHOD_GET_QUESTION=@"get_quetion";
NSString *const METHOD_GET_QUESTION_ANS_INSERT=@"get_question_ans_insert";
NSString *const METHOD_GET_USER_PROFILE_PIC=@"get_user_profile_pic";
NSString *const METHOD_UPLOAD_USER_IMAGE=@"upload_user_image";
NSString *const METHOD_DELETE_USER_IMAGE=@"delete_user_Image";
NSString *const METHOD_UPDATELOCATIONS=@"updateLocation";
NSString *const METHOD_UPDATE_PROFILE_PIC=@"update_profile_pic";
NSString *const METHOD_UPDATE_STATUS=@"update_status";


NSString *const METHOD_SETLIKES=@"setLikes";
NSString *const METHOD_INVITEACTION=@"inviteAction";
NSString *const METHOD_GETNOTIFICATIONS=@"getNotifications";
NSString *const METHOD_EDITPROFILE=@"editProfile";
NSString *const METHOD_SENDMESSAGE=@"sendMessage";
NSString *const METHOD_GETCHATHISTORY=@"getChatHistory";
NSString *const METHOD_GETCHATMESSAGE=@"getChatMessage";
NSString *const METHOD_LOGOUT=@"logout";
NSString *const METHOD_UPDATESESSION=@"updateSession";
NSString *const METHOD_DELETEACCOUNT=@"deleteAccount";
NSString *const METHOD_GETQUESTION=@"getQuestion";
NSString *const METHOD_USER_ANSWER=@"User_answer";
NSString *const METHOD_UPDATE_PREFERENCES_TIME=@"update_Preferences_time";
NSString *const METHOD_DELETE_MESSAGE=@"delete_message";
NSString *const METHOD_GET_DETAIL_QUE=@"get_detail_que";
NSString *const METHOD_GET_DETAIL_ANS_INSERT=@"get_detail_ans_insert";
NSString *const METHOD_GET_DETAIL_OPTION=@"get_detail_Option";
NSString *const METHOD_GET_ABOUT_QUE=@"get_about_que";
NSString *const METHOD_GET_ABT_ANS_INSERT=@"get_abt_ans_insert";
NSString *const METHOD_PROMOTED_LIST=@"Promoted_list";
NSString *const METHOD_PROMOTED_ME=@"promote_me";
NSString *const METHOD_ADDLIKES=@"addLikes";
NSString *const METHOD_ADDFRIENDS_ID=@"addFriends_id";
NSString *const METHOD_MUTUAL_FRIEND=@"mutual_friend";
NSString *const METHOD_CREATE_MOMENT=@"create_moment";
NSString *const METHOD_GET_MOMENTS=@"get_moments";
NSString *const METHOD_DELETE_MOMENT=@"delete_moment";
NSString *const METHOD_LIKE_DISLIKE_MOMENT=@"like_moment";
NSString *const METHOD_GET_ACTIVITIES=@"get_moment_activities";
NSString *const METHOD_UNMATCH=@"unmatchUser";
NSString *const METHOD_UPLOAD_IMAGE=@"upload_image";
NSString *const METHOD_GET_APPSETTINGS=@"get_setting";
NSString *const METHOD_UPDATE_APPSETTINGS=@"update_setting";

//PARAMS
NSString *const PARAM_ENT_FBID=@"ent_fbid";
NSString *const PARAM_ENT_FIRST_NAME=@"ent_first_name";
NSString *const PARAM_ENT_LAST_NAME=@"ent_last_name";
NSString *const PARAM_ENT_SEX=@"ent_sex";
NSString *const PARAM_ENT_PUSH_TOKEN=@"ent_push_token";
NSString *const PARAM_ENT_CURR_LAT=@"ent_curr_lat";
NSString *const PARAM_ENT_CURR_LONG=@"ent_curr_long";
NSString *const PARAM_ENT_DOB=@"ent_dob";
NSString *const PARAM_ENT_PROFILE_PIC=@"ent_profile_pic";
NSString *const PARAM_ENT_DEVICE_TYPE=@"ent_device_type";
NSString *const PARAM_ENT_USER_FBID=@"ent_user_fbid";
NSString *const PARAM_ENT_USER_XAUTHID=@"ent_user_fbid";
NSString *const PARAM_ENT_LAST_MESS_ID=@"ent_last_mess_id";
NSString *const PARAM_ENT_RECEVER_USER_FBID=@"ent_recever_user_fbid";
NSString *const PARAM_ENT_MESSAGE=@"ent_message";
NSString *const PARAM_ENT_FLAG=@"ent_flag";
NSString *const PARAM_ENT_USER_BLOCK_FBID=@"ent_user_block_fbid";
NSString *const PARAM_ENT_PREF_SEX=@"ent_pref_sex";
NSString *const PARAM_ENT_PREF_LOWER_AGE=@"ent_pref_lower_age";
NSString *const PARAM_ENT_PREF_UPPER_AGE=@"ent_pref_upper_age";
NSString *const PARAM_ENT_PREF_RADIUS=@"ent_pref_radius";
NSString *const PARAM_ENT_JSON=@"ent_json";
NSString *const PARAM_ENT_USERIMAGE=@"ent_userimage";
NSString *const PARAM_ENT_INDEX_ID=@"ent_index_id";
NSString *const PARAM_ENT_IMAGE_ID=@"ent_image_id";
NSString *const PARAM_ENT_NEW_PRF_INDEX_ID=@"ent_new_prf_index_id";
NSString *const PARAM_ENT_NEW_IMAGE_ID=@"ent_new_image_id";
NSString *const PARAM_ENT_USER_RECEVER_FBID=@"ent_user_recever_fbid";
NSString *const PARAM_ENT_STATUS=@"ent_status";
NSString *const PARAM_ENT_PROFILE_PIC_DATA=@"fbUserProfilePicData";
NSString *const PARAM_ENT_MOMENT_ID=@"moment_id";

//for tinder
NSString *const PARAM_TND_XAUTHTOKEN = @"tnd_xauth_token";
NSString *const PARAM_TND_TINDERID = @"tnd_tinderid";


NSString *const PARAM_ENT_SESS_TOKEN=@"ent_sess_token";
NSString *const PARAM_ENT_DEV_ID=@"ent_dev_id";
NSString *const PARAM_ENT_EMAIL=@"ent_email";
NSString *const PARAM_ENT_CITY=@"ent_city";
NSString *const PARAM_ENT_COUNTRY=@"ent_country";
NSString *const PARAM_ENT_TAG_LINE=@"ent_tag_line";
NSString *const PARAM_ENT_PERS_DESC=@"ent_pers_desc";
NSString *const PARAM_ENT_QBID=@"ent_qbid";
NSString *const PARAM_ENT_AUTH_TYPE=@"ent_auth_type";
NSString *const PARAM_ENT_DISTANCE_TYPE=@"ent_distance_type";
NSString *const PARAM_ENT_PROF_URL=@"ent_prof_url";
NSString *const PARAM_ENT_OTHER_URLS=@"ent_other_urls";
NSString *const PARAM_ENT_IMAGE_NAME=@"ent_image_name";
NSString *const PARAM_ENT_IMAGE_FLAG=@"ent_image_flag";
NSString *const PARAM_ENT_INVITEE_FBID=@"ent_invitee_fbid";
NSString *const PARAM_ENT_USER_ACTION=@"ent_user_action";
NSString *const PARAM_ENT_DATETIME=@"ent_datetime";
NSString *const PARAM_ENT_MSG_ID=@"ent_msg_id";
NSString *const PARAM_ENT_CHAT_PAGE=@"ent_chat_page";
NSString *const PARAM_ENT_IOS_CER=@"ent_ios_cer";
NSString *const PARAM_ENT_CER_PASS=@"ent_cer_pass";
NSString *const PARAM_ENT_CER_TYPE=@"ent_cer_type";
NSString *const PARAM_ENT_D_ID=@"ent_d_id";
NSString *const PARAM_ENT_TYPE=@"ent_type";
NSString *const PARAM_ENT_YOUR_ANS=@"ent_your_ans";
NSString *const PARAM_ENT_FEET=@"ent_feet";
NSString *const PARAM_ENT_INCHES=@"ent_inches";
NSString *const PARAM_ENT_CENTIMETERS=@"ent_Centimeters";
NSString *const PARAM_ENT_ABT_ID=@"ent_abt_id";
NSString *const PARAM_ENT_PROMOTE_ME=@"ent_promote_me";
NSString *const PARAM_ENT_MEDIA_CHUNK=@"media_chunk";
NSString *const PARAM_ENT_LIKES=@"ent_likes";
NSString *const PARAM_ENT_NAMES=@"ent_names";
NSString *const PARAM_ENT_PICTURES=@"ent_pictures";
NSString *const PARAM_ENT_FRD_FB_ID=@"ent_frd_fb_id";
NSString *const PARAM_ENT_FRD_NAMES=@"ent_frd_names";
NSString *const PARAM_ENT_FRD_PICS=@"ent_frd_pics";
NSString *const PARAM_ENT_FRIEND_ID=@"ent_friend_id";

//XMPP
NSString *const kKeyUDAMNUserName    =   @"AMN_Username";
NSString *const kKeyUDAMNPassword    =   @"AMN_Password";