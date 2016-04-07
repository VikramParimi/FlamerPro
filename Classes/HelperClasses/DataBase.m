//
//  DataBase.m
//  Restaurant
//
//  Created by 3Embed on 27/09/12.
//
//

#import "DataBase.h"
#import "TinderAppDelegate.h"
#import "Login.h"
#import "MatchedUserList.h"
#import "SDWebImageDownloader.h"
#import "Helper.h"
#import "UploadImages.h"

static DataBase *sharedObject;

@implementation DataBase

@synthesize delegate;

#pragma mark -
#pragma mark - Init

+ (id)sharedInstance
{
	if (!sharedObject)
    {
		sharedObject = [[self alloc] init];
	}
	return sharedObject;
}

-(void)makeDataBaseEntryForLogin:(NSDictionary*)dictionary
{
    Login *item=(Login *)[self createObjectForEntity:ENTITY_LOGIN];
    
    int age = age = [Helper getAge:[dictionary objectForKey:PARAM_ENT_DOB]];
    if (age == 0)
    {
        age = 25;
    }
    item.fbId=[dictionary objectForKey:PARAM_ENT_FBID];
    item.firstname=[dictionary objectForKey:PARAM_ENT_FIRST_NAME];
    item.lastname=[dictionary objectForKey:PARAM_ENT_LAST_NAME];
    item.age=[NSNumber numberWithInt:age];
    item.gender=[NSNumber numberWithInt:[[dictionary objectForKey:PARAM_ENT_SEX] intValue]];
    item.prefsex=[NSNumber numberWithInt:[[dictionary objectForKey:PARAM_ENT_PREF_SEX] intValue]];
    item.lowerage=[NSNumber numberWithInt:[[dictionary objectForKey:PARAM_ENT_PREF_LOWER_AGE] intValue]];
    item.maxage=[NSNumber numberWithInt:[[dictionary objectForKey:PARAM_ENT_PREF_UPPER_AGE] intValue]];
    item.likes=[dictionary objectForKey:PARAM_ENT_LIKES];
    item.about=[dictionary objectForKey:PARAM_ENT_TAG_LINE];
    item.dob=[dictionary objectForKey:PARAM_ENT_DOB];
    item.email=[dictionary objectForKey:PARAM_ENT_EMAIL];
    
    [self saveContext];
}

-(void)makeDataBaseEntryForGetProfile:(NSDictionary*)dictionary
{
    //check if there is any images
    NSArray *images = dictionary[@"images"];
    if (images.count > 0)
    {
        if ([images[0] isKindOfClass:[NSNull class]])
        {
            [delegate dataInsertedSucessfullyInDb:YES];
            return;
        }
    }
    [self deleteObjectsForEntity:ENTITY_UPLOADIMAGES];
    [self performSelectorOnMainThread:@selector(makeDataBaseEntryForUploadImages:) withObject:[dictionary objectForKey:@"images"] waitUntilDone:YES];
    NSArray * imageURLs = (NSArray*)[dictionary objectForKey:@"images"];
    for (int i = 0; i<imageURLs.count; i++){
        [self saveImageToDocumentsDirectoryForLogin :[imageURLs objectAtIndex:i]:i];
    }
    [delegate dataInsertedSucessfullyInDb:YES];
}

- (void)removeImage:(NSString*)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    [fileManager removeItemAtPath: documentsDirectory error:NULL];
}

- (void)imageDownloader:(SDWebImageDownloader *)downloader didFinishWithImage:(UIImage *)image
{
    DLog(@"finish imageDownloader");
}

-(void)saveImage:(NSDictionary*)dict
{
    [self saveProfileImage:dict[@"local"] andFBURL:dict[@"fb"]];
}

-(void)makeDataBaseEntryForUploadImages:(NSArray *)array
{
    for (int i = 0; i<array.count; i++) {
        
        UploadImages *item=(UploadImages *)[self createObjectForEntity:ENTITY_UPLOADIMAGES];
        item.fbId = [[[UserDefaultHelper sharedObject] facebookUserDetail] objectForKey:FACEBOOK_ID];
        item.imageUrlFB = [array objectAtIndex:i];
        [self saveContext];
    }
}

#pragma mark-
#pragma mark getDatabase Data


- (void)insertMatchedUserList:(NSMutableArray *)mMatchedUser
{
    [self deleteObjectsForEntity:ENTITY_MATCHEDUSERLIST];
    NSManagedObjectContext *context = [APPDELEGATE managedObjectContext];
    
    if (mMatchedUser.count > 0)
    {
        for (int i = 0; i < mMatchedUser.count; i++) {
            MatchedUserList *matchedTable = [NSEntityDescription insertNewObjectForEntityForName:@"MatchedUserList" inManagedObjectContext:context];
            [matchedTable setFName:mMatchedUser[i][@"fName"]];
            [matchedTable setFId:mMatchedUser[i][@"fbId"]];
            if([mMatchedUser[i][@"flag"] isEqual: [NSNull null]]){
                [matchedTable setStatus:@"0"];
            }
            else{
                [matchedTable setStatus:mMatchedUser[i][@"flag"]];
            }
            [matchedTable setLastActive:mMatchedUser[i][@"ladt"]];
            if (mMatchedUser[i][@"pPic"]) {
                [self saveImageToDocumentsDirectory:matchedTable :mMatchedUser[i][@"pPic"]];
            }else{
                [matchedTable setProficePic:@""];
            }
            NSError *error;
            if(![context save:&error])
            {
                DLog(@"error ------->%@",error);
            }
        }
    }
    [delegate dataInsertedSucessfullyInDb:YES];
}

-(void)saveProfileImage:(NSString*)localPath andFBURL:(NSString*)fburl
{
    NSManagedObjectContext *context = [APPDELEGATE managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UploadImages" inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"imageUrlFB = %@", fburl]];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    
    if (result.count == 1) {
        UploadImages *item = [result objectAtIndex:0];
        item.imageUrlLocal = localPath;
        //BOOL isSaved = [context save:&error];
    }
}

- (void)saveImageToDocumentsDirectoryForLogin :(NSString *)imageUrl :(int)index
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * imgpath;
    imgpath = [NSString stringWithFormat:@"%@/%d.jpg",docDir,index];
    NSData  *data = nil;
    NSURL *url = [NSURL URLWithString:[Helper removeWhiteSpaceFromURL:imageUrl]];
    UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
    data = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
    
    NSString *strPath =[[NSBundle mainBundle] pathForResource:@"pfImage" ofType:@"png"];
    [[UserDefaultHelper sharedObject]setFBProfileURL:strPath];
    
    if ([data writeToFile:imgpath atomically:YES]) {
        switch (index) {
            case 0:{
                [[UserDefaultHelper sharedObject]setFBProfileURL:imgpath];
                [self saveImage:@{@"fb":imageUrl, @"local":imgpath}];
                break;
            }
            case 1:{
                [self saveImage:@{@"fb":imageUrl, @"local":imgpath}];
                break;
            }
            case 2:{
                [self saveImage:@{@"fb":imageUrl, @"local":imgpath}];
                break;
            }
            case 3:
            {
                [self saveImage:@{@"fb":imageUrl, @"local":imgpath}];
                break;
            }
            case 4:
            {
                [self saveImage:@{@"fb":imageUrl, @"local":imgpath}];
                break;
            }
            default:
                break;
        }
    }
}

- (void)saveImageToDocumentsDirectory:(MatchedUserList *)matchList :(NSString *)imageUrl
{
    if([imageUrl isEqual:[NSNull null]])
        imageUrl=@"";
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * imgpath ;
    
    NSArray *imageName = [imageUrl componentsSeparatedByString:@"/"];
    imgpath = [NSString stringWithFormat:@"%@/%@",docDir,[imageName lastObject]];
    matchList.proficePic = imgpath;
    NSData  *data = nil;
    NSFileManager *fm = [NSFileManager new];
    if ( [fm fileExistsAtPath:imgpath])
    {
        NSURL *url = [NSURL URLWithString:[Helper removeWhiteSpaceFromURL:imageUrl]];
        UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
        data = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
        
        //do nothing
    }else{
        NSURL *url = [NSURL URLWithString:[Helper removeWhiteSpaceFromURL:imageUrl]];
        UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
        data = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
    }
    if ([data writeToFile:imgpath atomically:YES]) {
    }
}


@end
