//
//  RoundedImageView.m
//  RoundedImageView
//
//  Created by Danny Shmueli on 9/17/13.
//  Copyright (c) 2013 Danny Shmueli. All rights reserved.
//

#import "RoundedImageView.h"
//#import "NSObject+DelayedBlock.h"

@interface RoundedImageView ()

//Since roundIt method is called from setImage, and since roundIt method calls self.image it will cause a loop
@property (atomic, readwrite) BOOL didMakeImageRound;
@end

@implementation RoundedImageView

-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	[self roundIt];
	return self;
}

//this is called from [super setImage:image] when actually needed (on image change)
-(void)setNeedsDisplay
{
	[super setNeedsDisplay];
	self.didMakeImageRound = NO;
}

-(void)setImage:(UIImage *)image
{
	[super setImage:image];
    
	if (!self.didMakeImageRound)
		[self roundIt];
}

- (void)roundIt
{
	self.didMakeImageRound = YES;
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextAddEllipseInRect(ctx, self.bounds);
	CGContextClip(ctx);
	[self.image drawInRect:self.bounds];
	self.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
}

@end