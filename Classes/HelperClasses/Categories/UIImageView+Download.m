//
//  UIImageView+Download.m
//  SalesPoint
//
//  Created by Elluminati - macbook on 09/10/13.
//  Copyright (c) 2013 Elluminati MacBook Pro 1. All rights reserved.
//

#import "UIImageView+Download.h"

@implementation UIImageView (Download)

-(void)downloadFromURL:(NSString *)url withPlaceholder:(UIImage *)placehold
{
    if (placehold) {
        [self setImage:placehold];
    }
    if (url) {
        //
        if ([url rangeOfString:@"/Caches/"].location != NSNotFound) {
            NSData *imageData=[NSData dataWithContentsOfFile:url];
            UIImage* image = [[UIImage alloc] initWithData:imageData];
            if (image) {
                [self setImage:image];
                [self setNeedsLayout];
            }
            return;
        }
        
        NSString *strImgName = [[[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@"/"] lastObject];
        
        NSString *imagePath = [NSString stringWithFormat:@"%@/%@",[[UtilityClass sharedObject]applicationCacheDirectoryString],strImgName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *aURL=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if ([fileManager fileExistsAtPath:imagePath]==NO)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void) {
                
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:aURL]];
                [imageData writeToFile:imagePath atomically:YES];
                
                UIImage* image = [[UIImage alloc] initWithData:imageData];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setImage:image];
                        [self setNeedsLayout];
                        
                    });
                }
            });
        }
        else{
            NSData *imageData=[NSData dataWithContentsOfFile:imagePath];
            UIImage* image = [[UIImage alloc] initWithData:imageData];
            if (image) {
                [self setImage:image];
                [self setNeedsLayout];
            }
        }
    }
}

/*
 - (NSString *)applicationCacheDirectoryString
 {
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
 NSString *cacheDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
 return cacheDirectory;
 }
 */

@end
