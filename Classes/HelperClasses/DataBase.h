//
//  DataBase.h
//  Restaurant
//
//  Created by 3Embed on 27/09/12.
//
//

#import "DBHelper.h"

#import "SDWebImageDownloader.h"

@protocol DataInsertedSuccessfullyDelegate <NSObject>

- (void)dataInsertedSucessfullyInDb:(BOOL)success;

@end

@interface DataBase : DBHelper
{
    
}
@property(nonatomic,assign)id <DataInsertedSuccessfullyDelegate>delegate;
+ (id)sharedInstance;
-(void)makeDataBaseEntryForLogin:(NSDictionary *)dictionary;
-(void)makeDataBaseEntryForUploadImages:(NSArray *)array;
-(void)makeDataBaseEntryForGetProfile:(NSDictionary*)dictionary;

- (void)insertMessageForFirstlaunch:(NSArray *)messages uniqueId:(NSString *)uniqueId;
- (void)insertMessages:(NSMutableDictionary *)messages;
- (void)insertMatchedUserList:(NSMutableArray *)mMatchedUser;
- (void)saveImageToDocumentsDirectoryForLogin :(NSString *)imageUrl :(int)index;

-(void)saveProfileImage:(NSString*)localPath andFBURL:(NSString*)fburl;

@end
