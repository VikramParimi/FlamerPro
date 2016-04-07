//
//  AsyncImageViewTableCell.m
//  Kalendariet
//
//  Created by Hugo Wetterberg on 2009-07-23.
//  Copyright 2009 Hugo Wetterberg. All rights reserved.
//

#import "AsyncImageLoader.h"
#import "ImageCache.h"
#import "AsyncImageLoaderDelegate.h"
#import "UIImage+Additions.h"
#import "NSString+URLEncoding.h"
#import <CFNetwork/CFNetwork.h>

@interface AsyncImageLoader (Private)

- (UIImage *)getIfCached:(NSURL *)aUrl;

@end


@implementation AsyncImageLoader

@synthesize connection;
@synthesize data;
@synthesize request;
@synthesize resizedUrl;
@synthesize url;
@synthesize fileName;
@synthesize key;
@synthesize delegate;

- (id)init {
    self = [super init];
    if (self) {
        // Nothing here right now
		key = nil;
    }
	
    return self;
}

- (void)loadImageFromURL:(NSURL*)aUrl {
    [self loadImageFromURL:aUrl targetSize:CGSizeZero];
}

- (void)loadImageFromURL:(NSURL*)aUrl withKey:(NSURL*) aKey { //GM: new param self.key
	self.key = aKey;
	[self loadImageFromURL:aUrl targetSize:CGSizeZero];
}

- (void)loadImageFromURL:(NSURL*)aUrl targetSize:(CGSize)aTargetSize {
	////NSLog(@"Load requested for %fx%f of %@", aTargetSize.width, aTargetSize.height, aUrl);
	if(self.connection)
		[self.connection cancel];
	/*
    [connection release];
    connection = nil;
	 */
	
    targetSize = aTargetSize;
	
	//targetSize = CGSizeMake(200, 200);
	
    /*
	[data release];
    data = [[NSMutableData alloc] init];
	 */
	self.data = [[[NSMutableData alloc] init] autorelease];
	
	UIImage *img = nil;
    self.url = aUrl;
	
	NSString *urlBase = [url absoluteString];
	NSArray *components = [urlBase componentsSeparatedByString:@"/"];
	self.fileName = [components lastObject];
	
	
	//GM: new self.key parameter for cache association
	if(key == nil)
	{
		self.key = [[[NSURL alloc] initWithString:[self.url absoluteString] ] autorelease];
	}
		
    
    if (targetSize.width > 0.0) {
		
        self.resizedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"#%fx%f", targetSize.width, targetSize.height] 
                      relativeToURL:aUrl];
//        img = [self getIfCached:resizedUrl];
		 
		
		NSString* resizedImageName = [self resizedImageName:self.fileName withTarget:targetSize];
        NSLog(@"######################## ################### ###############  Resized Image Name is : %@",resizedImageName);
		img = [self getIfCachedWithName:resizedImageName];
		
    }
    else {
        resizedUrl = nil;
        //img = [self getIfCached:self.key];
		img = [self getIfCachedWithName:self.fileName];
    }
	
    
    if (img) { // Pass on the image to the delegate if it was in the cache
#if MN_DEBUG_LEVEL > 3
        //NSLog(@"Image already present in the image cache for %@", url);
#endif
		/*
		[self.key release];
		self.key = nil;
		*/
        if ([delegate respondsToSelector:@selector(asyncImageLoader:imageDidLoad:)]) {
            [delegate asyncImageLoader:self imageDidLoad:img];
        }
    }
	// Edit by raman soni B24 E solutions
	else 
	{
		NSFileManager *defaultFileManager = [NSFileManager defaultManager];
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		
		NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:self.fileName];
		
		if(![defaultFileManager fileExistsAtPath:fullPath])
		{
		#if MN_DEBUG_LEVEL > 3
			//NSLog(@"Started async loading of %@", url);
		#endif
			self.request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:120.0]  ;
			self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
		}
		else 
		{
			UIImage *img =[UIImage imageWithContentsOfFile:fullPath];
			
			// commented for test
		   //[[ImageCache sharedImageCache] storeImage:img withKey:[self.key absoluteString]];
			/*
			[key release];
			key = nil;
			*/
			// Resize if requested and if a resize is needed (we don't do upscaling)
			if (targetSize.width && (targetSize.width < img.size.width || targetSize.height < img.size.height)) {
				//img = [img scaleToSize:targetSize];
				
			/*	NSLog(@"Before, Image Size : %@ for Image Name : %@", NSStringFromCGSize(img.size), self.fileName);
				
				// Resize image before displaying it to screen
				img = [img imageByScalingProportionallyToSize:targetSize];
				
				
				NSString* resizedImageName = [self resizedImageName:self.fileName withTarget:targetSize];
				[self saveImageToDocumentFolder:img withName:resizedImageName];
				NSLog(@"After, Image Size : %@ for Image Name : %@", NSStringFromCGSize(img.size), resizedImageName);*/
				
				
				
				// commented for test
				//[[ImageCache sharedImageCache] storeImage:img withKey:[self.resizedUrl absoluteString]];
			}
			
			if(delegate && [delegate respondsToSelector:@selector(asyncImageLoader:imageDidLoad:)])
				[delegate asyncImageLoader:self imageDidLoad:img];
		}

	}
}

- (NSString*) resizedImageName:(NSString*)imageName withTarget:(CGSize)target{
	
	NSString* resizedImageName = nil;
	
	NSArray* components = [self.fileName componentsSeparatedByString:@"."];
	if([components count] == 2){
		NSString* justFileName = [components objectAtIndex:0];
		NSString* fileExtension = [components objectAtIndex:1];
		
		resizedImageName = [NSString stringWithFormat:@"%@#%0.0fx%0.0f.%@", justFileName, targetSize.width, targetSize.height, fileExtension];
	}
	
	return resizedImageName;
}

- (UIImage *)getIfCached:(NSURL *)aUrl {
    //return [[HURLCache sharedCache] getImageForUrl:aUrl];
	return [[ImageCache sharedImageCache] imageForKey:[aUrl absoluteString]];
	
	
}

- (UIImage *)getIfCachedWithName:(NSString*)imageName {

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:imageName];
	
	UIImage *img =[UIImage imageWithContentsOfFile:fullPath];
	
	return img;
}

- (void)_stopReceiveWithStatus:(NSString *)statusString
// Shuts down the connection and displays the result (statusString == nil) 
// or the error status (otherwise).
{
    if (connection != nil) {
        [connection cancel];
        connection = nil;
    }
    if (data != nil) {
        data = nil;
    }
#if MN_DEBUG_LEVEL > 2	
	//NSLog(@"Some error while loading image asyncronously: %@", statusString);
#endif
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:statusString forKey:NSLocalizedDescriptionKey];
	NSError* error = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorUnknown userInfo:userInfo];
	[delegate asyncImageLoader:self didFailWithError:error];
}

/*
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)urlResponse {
    [data setLength:0];
}
 */

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response 
// exchange is complete.  We look at the response to check that the HTTP 
// status code is 2xx and that the Content-Type is acceptable.  If these checks 
// fail, we give up on the transfer.
{
#pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse;
    NSString *          contentTypeHeader;
	
    assert(theConnection == connection);
    
    httpResponse = (NSHTTPURLResponse *) response;
    if( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] ){
		if ((httpResponse.statusCode / 100) != 2) {
			[self _stopReceiveWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
			////NSLog([NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]);
		} else {
			contentTypeHeader = [httpResponse.allHeaderFields objectForKey:@"Content-Type"];
			if (contentTypeHeader == nil) {
				[self _stopReceiveWithStatus:@"No Content-Type!"];
				////NSLog(@"No Content-Type!");
			} else if ( ! [contentTypeHeader isHTTPContentType:@"image/jpeg"] 
					   && ! [contentTypeHeader isHTTPContentType:@"image/png"] 
					   && ! [contentTypeHeader isHTTPContentType:@"image/gif"] ) {
				[self _stopReceiveWithStatus:[NSString stringWithFormat:@"Unsupported Content-Type (%@)", contentTypeHeader]];
				////NSLog([NSString stringWithFormat:@"Unsupported Content-Type (%@)", contentTypeHeader]);
			} else {
				 [data setLength:0];
			}
		} 
	}
	else if( [httpResponse isKindOfClass:[NSURLResponse class]] ){
		 [data setLength:0];
	}
		 
}

//the URL connection calls this repeatedly as data arrives
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    [data appendData:incrementalData];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
#if MN_DEBUG_LEVEL > 0
	//NSLog(@"AsyncImage Loader failed due to error : %@ for the url : %@", [error localizedDescription], [url absoluteString]);
	//NSLog(@"Recovery suggestion : %@", [error localizedRecoverySuggestion]);
#endif
    [delegate asyncImageLoader:self didFailWithError:error];
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    ////NSLog(@"Async loading of %@ finished", url);
    //so self data now has the complete image

	/*
    [connection release];
    connection = nil;
	*/
    
    //[[HURLCache sharedCache] storeData:data forUrl:url];
	
    //make an image view for the image
    UIImage *img = [UIImage imageWithData:self.data];
	
	if (img) {
		
		// Store the image to the image cache.
		// commented for test
		//[[ImageCache sharedImageCache] storeImage:img withKey:[self.key absoluteString]];
		/*
		[self.key release];
		self.key = nil;
		*/
		
		//[self saveImageToDocumentFolder:img withName:self.fileName];
		
        // Resize if requested and if a resize is needed (we don't do upscaling)
        if (targetSize.width && (targetSize.width < img.size.width || targetSize.height < img.size.height)) {
            img = [img scaleToSize:targetSize];

img = [img imageByScalingProportionallyToSize:targetSize];

//[[NSURLCache sharedCache] storeData:UIImageJPEGRepresentation(img, 0.6) forUrl:resizedUrl];
// commented for test

[[ImageCache sharedImageCache] storeImage:img withKey:[self.resizedUrl absoluteString]];

[self saveImageToDocumentFolder:img withName:[self.resizedUrl absoluteString]];
			
        }
		if (delegate && [delegate respondsToSelector:@selector(asyncImageLoader:imageDidLoad:)]) {
			[delegate asyncImageLoader:self imageDidLoad:img];			
		}
    }
	else {
		/*
		[self.key release];
		self.key = nil;
		 */
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"No image found.", @"No Image found.") forKey:NSLocalizedDescriptionKey];
		NSError *noFileFoundError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorFileDoesNotExist userInfo:userInfo];
		[delegate asyncImageLoader:self didFailWithError:noFileFoundError];
	}

}

-(void) saveImageToDocumentFolder:(UIImage *)image withName:(NSString *)ImageName
{
	NSData *imgdata;
	NSArray *aArray = [ImageName componentsSeparatedByString:@"."];
	
	if([aArray count]<=1)ImageName = [ImageName stringByAppendingString:@".png"];
		aArray = [ImageName componentsSeparatedByString:@"."];
	if([[aArray objectAtIndex:1] caseInsensitiveCompare:@"png"]==0)
		imgdata = UIImageJPEGRepresentation(image, 1.0);
	else 
		imgdata=UIImagePNGRepresentation(image);
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:ImageName];
	if(![fileManager fileExistsAtPath:fullPath])
		[fileManager createFileAtPath:fullPath contents:imgdata attributes:nil];
}


+ (UIImage *)resizeImage:(UIImage *)image toFillFrame:(CGSize)frame {
    if (frame.width == 0) {
        return image;
    }
    
    CGSize original = image.size;
    CGSize scaled;
    
    float xratio = original.width / frame.width;
    float yratio = original.height / frame.height;
    
    if (xratio <= yratio) {
        scaled = CGSizeMake(original.width / xratio, original.height / xratio);
    }
    else {
        scaled = CGSizeMake(original.width / xratio, original.height / xratio);
    }
    
    CGImageRef imageRef = [image CGImage];
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
    
    if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
	
	CGContextRef bitmap = CGBitmapContextCreate(NULL, scaled.width, scaled.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
    CGContextDrawImage(bitmap, CGRectMake(0, 0, scaled.width, scaled.height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    
    UIImage *resized = [UIImage imageWithCGImage:ref];
    
    CGColorSpaceRelease(colorSpaceInfo);
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return resized;
}


- (void)dealloc {
	#if TW_DEBUG_LEVEL > 4
	NSLog(@"############################### %@ has been dealloced ###############################", [[self class] description]);
#endif

	delegate = nil;
    [connection cancel]; //in case the URL is still downloading
    [connection release];
    [data release];
    [request release];
	
	//GM: 
	[url release];
	[key release];

	[fileName release];

	[resizedUrl release];

    [super dealloc];
}

@end
