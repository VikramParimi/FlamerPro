//
//  AsyncImageView.m
//  ImageLoading
//
//  Created by Hugo Wetterberg on 2009-08-06.
//  Copyright 2009 Hugo Wetterberg. All rights reserved.
//

#import "AsyncImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface AsyncImageView (Private)

@property (readonly) AsyncImageLoader *loader;

@end

@implementation AsyncImageView

@synthesize imageUrl;
@synthesize delegate;

-(AsyncImageLoader *) loader {
    if (!loader) {
        loader = [[AsyncImageLoader alloc] init];
        loader.delegate = self;
    }
    return loader;
}


- (void)setURL:(NSURL *)url {
    self.imageUrl = url;
    loadNeeded = YES;
}

-(void) setFrame:(CGRect)aRect {
	
	super.frame = aRect;
	
	CGRect activityRect = activity.frame;
	activityRect.origin.x = aRect.size.width / 2 - activityRect.size.width / 2;
	activityRect.origin.y = aRect.size.height / 2 - activityRect.size.height / 2;
	activity.frame = activityRect;
}

- (void)setShowActivity:(BOOL)showActivity {
    if (showActivity && !activity) {
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		CGRect activityRect = activity.frame;
		
		activityRect.origin.x = super.frame.size.width / 2 - activityRect.size.width / 2;
		activityRect.origin.y = super.frame.size.height / 2 - activityRect.size.height / 2;
		activity.frame = activityRect;
		
			//activity.hidesWhenStopped = YES;
        [self addSubview:activity];
    }
    else if (!showActivity) {
        [activity removeFromSuperview];
        [activity release];
        activity = nil;
    }

}

- (void) setActivityStyle:(UIActivityIndicatorViewStyle)style{
	if(activity)
		activity.activityIndicatorViewStyle = style;
}

- (void)loadImageIfNeeded {
    if (loadNeeded) {
        loadNeeded = NO;
        [activity startAnimating];
        [self.loader loadImageFromURL:imageUrl targetSize:self.bounds.size];
		//[self.loader loadImageFromURL:imageUrl];
    }
}

- (void)imageFromUrl:(NSURL *)url {
	self.contentMode = UIViewContentModeScaleAspectFit;
	
    if (url) {
		[self setURL:url];
		[self loadImageIfNeeded];

	}
}

- (void) loadImageFromURL:(NSURL*)url{
	[self imageFromUrl:url];
}

- (void)asyncImageLoader:(AsyncImageLoader *)imageLoader didFailWithError:(NSError *)error {
    if ([activity isAnimating]) {
        [activity stopAnimating];
    }
	
	if ([delegate respondsToSelector:@selector(didFailWithError:)])
		[delegate didFailWithError:error];
}

- (void)asyncImageLoader:(AsyncImageLoader *)imageLoader imageDidLoad:(UIImage *)image {
    if ([activity isAnimating]) {
        [activity stopAnimating];
    }
    self.image = image;
	[self setNeedsLayout];
	
	if ([delegate respondsToSelector:@selector(didLoadImage:)])
		[delegate didLoadImage:image]; 
}

- (void)dealloc {
	#if TW_DEBUG_LEVEL > 4
	NSLog(@"############################### %@ has been dealloced ###############################", [[self class] description]);
#endif
	
	delegate = nil;
	
    [loader release];
    [activity release];
	[imageUrl release];

    [super dealloc];
}


@end
