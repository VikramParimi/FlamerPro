//
//  AsyncImageLoader.h
//  Kalendariet
//
//  Created by Hugo Wetterberg on 2009-07-23.
//  Copyright 2009 Hugo Wetterberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol AsyncImageLoaderDelegate;

@interface AsyncImageLoader : NSObject {
    NSURLConnection *connection; //keep a reference to the connection so we can cancel download in dealloc
    NSMutableData *data; //keep reference to the data so we can collect it as it downloads
    NSURLRequest *request;
    NSURL *url;
	NSURL *key; //GM: new param: key to force image association in cache
    NSURL *resizedUrl;
    CGSize targetSize;
    id<AsyncImageLoaderDelegate> delegate;
	NSString *fileName;
	
}

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSURL *resizedUrl;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, retain) NSURL *key;

- (id)init;
- (void)loadImageFromURL:(NSURL*)url;
- (void)loadImageFromURL:(NSURL*)aUrl targetSize:(CGSize)targetSize;
- (UIImage *)getIfCached:(NSURL *)aUrl;
- (UIImage *)getIfCachedWithName:(NSString*)imageName;
- (void)loadImageFromURL:(NSURL*)aUrl withKey:(NSURL*) aKey; //GM: new param key
- (NSString*) resizedImageName:(NSString*)imageName withTarget:(CGSize)target;
+ (UIImage *)resizeImage:(UIImage *)image toFillFrame:(CGSize)frame;
-(void) saveImageToDocumentFolder:(UIImage *)image withName:(NSString *)ImageName;

@property (assign) id<AsyncImageLoaderDelegate> delegate;

@end