//
//  ImageCache.m
//  mobnotes2
//
//  Created by luca on 1/14/10.
//  Copyright 2010 Mobnotes. All rights reserved.
//
#import "ImageCache.h"


@implementation ImageCache

static ImageCache *sharedImageCache;

- (id)init {
    if (self = [super init]) {
		memoryCache = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
	#if TW_DEBUG_LEVEL > 4
	NSLog(@"############################### %@ has been dealloced ###############################", [[self class] description]);
#endif
    [memoryCache release];
    [super dealloc];
}

+ (ImageCache *)sharedImageCache {
    if (!sharedImageCache) {
        sharedImageCache = [[ImageCache alloc] init];
    }
	
    return sharedImageCache;
}

- (UIImage *)imageForKey:(NSString *)key {
	return [memoryCache valueForKey:key];
}
- (BOOL)hasImageWithKey:(NSString *)key {
	return ([memoryCache objectForKey:key] != nil);
}
- (void)storeImage:(UIImage *)image withKey:(NSString *)key {
	[memoryCache setValue:image forKey:key];
}
- (BOOL)imageExistsInMemory:(NSString *)key {
	// not yet implemented
	return YES;
}
- (BOOL)imageExistsInDisk:(NSString *)key {
	// not yet implemented
	return YES;
}
- (NSUInteger)countImagesInMemory {
	return [memoryCache count];
}
- (NSUInteger)countImagesInDisk {
	return 0;
}
- (void)removeImageWithKey:(NSString *)key {
	[memoryCache removeObjectForKey:key];
}
- (void)removeAllImages {
	[self removeAllImagesInMemory];
	[self removeOldImages];
}
- (void)removeAllImagesInMemory {
	[memoryCache removeAllObjects];
}
- (void)removeOldImages {
	// not yet implemented
}


@end

@implementation UIImage (AKLoadingExtension)

+ (UIImage *)newImageFromResource:(NSString *)filename
{
    NSString *imageFile = [[NSString alloc] initWithFormat:@"%@/%@",
                           [[NSBundle mainBundle] resourcePath], filename];
    UIImage *image = nil;
    image = [[UIImage alloc] initWithContentsOfFile:imageFile];
    [imageFile release];
    return image;
}

@end

