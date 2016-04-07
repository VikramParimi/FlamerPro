
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class TinderAppDelegate;
@interface DBHelper : NSObject
{
    TinderAppDelegate *appDelegate;
}
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

+ (DBHelper *)sharedObject;

-(void)saveContext;

-(id)createObjectForEntity:(NSString *)entityName;
-(void)deleteObject:(NSManagedObject *)managedObject;
-(NSMutableArray*) getObjectsforEntity:(NSString *)strEntity;
-(NSMutableArray*) getObjectsforEntity:(NSString *)strEntity ShortBy:(NSString *)strShort isAscending:(BOOL)ascending;
-(NSMutableArray*) getObjectsforEntity:(NSString *)strEntity ShortBy:(NSString *)strShort isAscending:(BOOL)ascending predicate:(NSPredicate *)predicate;
-(NSUInteger) getObjectCountforEntity:(NSString *)strEntity;
-(void) deleteObjectsForEntity:(NSString *)strEntity;

-(NSEntityDescription *)getEnitityFor:(NSString *)strEntity;
-(NSEntityDescription *)getEnitityFor:(NSString *)strEntity inManagedObjectContext:(NSManagedObjectContext *)moc;


-(NSNumber *)getLastMsgID:(NSNumber *)senderId andRecever:(NSNumber *)receiverId;
-(void)insertMsgToDB:(NSMutableArray *)arrMsgs uniqueId:(NSString *)uniqueId;


@end
