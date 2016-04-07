//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSMessagesViewController
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import "JSBubbleView.h"
#import "JSMessageInputView.h"
#import "JSAvatarImageFactory.h"
#import "NSString+JSMessagesView.h"
#import "UIImageView+Download.h"

#define kMarginTop 8.0f
#define kMarginBottom 4.0f
#define kPaddingTop 4.0f
#define kPaddingBottom 8.0f
#define kBubblePaddingRight 35.0f


@interface JSBubbleView()<EGOImageViewDelegate>

- (void)setup;

- (CGSize)textSizeForText:(NSString *)txt;
- (CGSize)bubbleSizeForText:(NSString *)txt;

@end


@implementation JSBubbleView

#pragma mark - Setup

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
                   bubbleType:(JSBubbleMessageType)bubleType
              bubbleImageView:(UIImageView *)bubbleImageView
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
        
        _type = bubleType;
        
        bubbleImageView.userInteractionEnabled = YES;
        [self addSubview:bubbleImageView];
        _bubbleImageView = bubbleImageView;
        
        UITextView *textView = [[UITextView alloc] init];
        textView.font = [UIFont systemFontOfSize:16.0f];
        textView.textColor = [UIColor blackColor];
        textView.editable = NO;
        textView.userInteractionEnabled = YES;
        textView.showsHorizontalScrollIndicator = NO;
        textView.showsVerticalScrollIndicator = NO;
        textView.scrollEnabled = NO;
        textView.backgroundColor = [UIColor clearColor];
        textView.contentInset = UIEdgeInsetsZero;
        textView.scrollIndicatorInsets = UIEdgeInsetsZero;
        textView.contentOffset = CGPointZero;
        textView.dataDetectorTypes = UIDataDetectorTypeAll;
        [self addSubview:textView];
        [self bringSubviewToFront:textView];
        _textView = textView;
        
        EGOImageView *img=[[EGOImageView alloc]init];
        img.backgroundColor=[UIColor clearColor];
        img.contentMode=UIViewContentModeScaleToFill;
        img.hidden=TRUE;
        [self addSubview:img];
        _textImageView=img;
        
        [_textImageView.layer setCornerRadius:7.0];
        [_textImageView.layer setMasksToBounds:YES];
        [_textImageView.layer setBorderColor:[ACTION_SHEET_COLOR CGColor]];
        [_textImageView.layer setBorderWidth:1.0];
        
        UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *imgSelected = [UIImage imageNamed:@"checkbox_yes.png"];
        UIImage *imgUnselected = [UIImage imageNamed:@"checkbox_no.png"];
        [checkButton setImage:imgUnselected forState:UIControlStateNormal];
        [checkButton setImage:imgSelected forState:UIControlStateSelected];
        [self addSubview:checkButton];

        _btnCheckmark = checkButton;
      
        
    }
    return self;
}

- (void)dealloc
{
    _bubbleImageView = nil;
    _textView = nil;
    _textImageView=nil;
}

#pragma mark - Setters

- (void)setType:(JSBubbleMessageType)type
{
    _type = type;
    [self setNeedsLayout];
}

- (void)setText:(NSString *)text
{
    self.textView.text = text;
    self.textView.hidden = NO;
    
    [self setNeedsLayout];
}

-(void)setImageWithUrl:(NSString *)imgUrl
{
    self.textView.hidden = YES;
    
    [self.textImageView setShowActivity:YES];
    [self.textImageView setImageURL:[NSURL URLWithString:imgUrl]];
    [self.textImageView setDelegate:self];
    
    [self setNeedsLayout];
}

#pragma mark - EgoImageView Delegate

-(void)imageViewLoadedImage:(EGOImageView *)imageView
{
    //[self saveImage:imageView.image withFileName:imageView.imageURL ofType:@"jpg" inDirectory:[self cacheDirectoryName]];
}


-(NSString*) cacheDirectoryName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *cacheDirectoryName = [documentsDirectory stringByAppendingPathComponent:@"TinderCloneImages"];
    return cacheDirectoryName;
}

-(UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}

-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath
{
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
    }
}

- (void)setFont:(UIFont *)font
{
    self.textView.font = font;
    [self setNeedsLayout];
}

- (void)setTextColor:(UIColor *)textColor
{
    self.textView.textColor = textColor;
    [self setNeedsLayout];
}

#pragma mark - Getters

- (NSString *)text
{
    return self.textView.text;
}

- (UIFont *)font
{
    return self.textView.font;
}

- (UIColor *)textColor
{
    return self.textView.textColor;
}

- (CGRect)bubbleFrame
{
    CGSize bubbleSize = [self bubbleSizeForText:self.textView.text];
    
    return CGRectMake((self.type == JSBubbleMessageTypeOutgoing || self.type == JSBubbleMessageTypeOutgoingImage? self.frame.size.width - bubbleSize.width : 0.0f),
                      kMarginTop,
                      bubbleSize.width,
                      bubbleSize.height + kMarginTop);
}

- (CGFloat)neededHeightForCell;
{
    return [self bubbleSizeForText:self.textView.text].height + kMarginTop + kMarginBottom;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (![self isShowingForImage])
    {
        self.bubbleImageView.frame = [self bubbleFrame];
        
        CGFloat textX = self.bubbleImageView.frame.origin.x;
        
        if(self.type == JSBubbleMessageTypeIncoming || self.type == JSBubbleMessageTypeIncomingImage)
        {
            textX += (self.bubbleImageView.image.capInsets.left / 2.0f);
        }
        else
        {
            textX += (self.bubbleImageView.image.capInsets.left / 2.0f);
        }
        
        CGRect textFrame = CGRectMake(textX,
                                      self.bubbleImageView.frame.origin.y,
                                      self.bubbleImageView.frame.size.width - (self.bubbleImageView.image.capInsets.right / 2.0f),
                                      self.bubbleImageView.frame.size.height - kMarginTop+50);
        
        self.textView.frame = textFrame;
        textFrame.origin.x+=kMarginTop;
        textFrame.origin.y+=kMarginTop;
        textFrame.size.height=150;
        textFrame.size.width=150;
        self.textImageView.frame=textFrame;
        [_bubbleImageView setHidden:NO];
    }
    else
    {
        self.bubbleImageView.frame = [self bubbleFrame];
        
        CGFloat textX = self.bubbleImageView.frame.origin.x;
        
        if(self.type == JSBubbleMessageTypeIncoming || self.type == JSBubbleMessageTypeIncomingImage)
        {
            textX += (self.bubbleImageView.image.capInsets.left / 2.0f);
        }
        else
        {
            textX += (self.bubbleImageView.image.capInsets.left / 2.0f);
        }
        
        CGRect textFrame = CGRectMake(textX,
                                      self.bubbleImageView.frame.origin.y,
                                      self.bubbleImageView.frame.size.width - (self.bubbleImageView.image.capInsets.right / 2.0f),
                                      self.bubbleImageView.frame.size.height - kMarginTop+50);
        
        self.textView.frame = textFrame;
        textFrame.origin.x+=kMarginTop;
        textFrame.origin.y+=kMarginTop;
        textFrame.size.height=150;
        textFrame.size.width=150;
        self.textImageView.frame=textFrame;

        [_bubbleImageView setHidden:YES];
        
    }
    
   
   CGRect bblFrame = self.bubbleImageView.frame;
   [_btnCheckmark setFrame:CGRectMake(0, bblFrame.origin.y, ScreenSize.width, bblFrame.size.height)];
   
    UIEdgeInsets insets ;
    
    if(_type == JSBubbleMessageTypeIncoming || _type == JSBubbleMessageTypeIncomingImage)
    {
         insets= UIEdgeInsetsMake(0.0f,ScreenSize.width/2+30,0.0f, 0.0f);
    }
    else
    {
         insets= UIEdgeInsetsMake(0.0f,-ScreenSize.width+25, 0.0f, 0.0f);
    }
    
   [_btnCheckmark setImageEdgeInsets:insets];

}

#pragma mark - Bubble view

-(BOOL)isText:(id)txt{
    
    if ([txt isKindOfClass:[NSString class]]) {
        return YES;
    }
    else
        return NO;
    
    /*
    BOOL isText=TRUE;
    if ([txt rangeOfString:@".png"].location == NSNotFound) {
        if ([txt rangeOfString:@".jpeg"].location == NSNotFound) {
            isText=TRUE;
        } else {
            isText=FALSE;
        }
    } else {
        isText=FALSE;
    }
    return isText;
     */
}

- (CGSize)textSizeForText:(NSString *)txt
{
    if (![self isShowingForImage])    //Previous [self isText:txt]
    {
        self.textImageView.hidden=TRUE;
        self.textView.hidden=FALSE;
        CGFloat maxWidth = [UIScreen mainScreen].applicationFrame.size.width * 0.60f;
        CGFloat maxHeight = MAX([JSMessageTextView numberOfLinesForMessage:txt],
                                [txt js_numberOfLines]) * [JSMessageInputView textViewLineHeight];
        maxHeight += kJSAvatarImageSize;
        
        return [txt sizeWithFont:self.textView.font
               constrainedToSize:CGSizeMake(maxWidth, maxHeight)];
    }
    else{
        self.textImageView.hidden=FALSE;
        self.textView.hidden=TRUE;
        return CGSizeMake(150, 150);
    }
    
}

-(BOOL)isShowingForImage
{
    if (_type == JSBubbleMessageTypeOutgoingImage || _type == JSBubbleMessageTypeIncomingImage)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (CGSize)bubbleSizeForText:(NSString *)txt
{
	CGSize textSize = [self textSizeForText:txt];
    
	return CGSizeMake(textSize.width + kBubblePaddingRight,
                      textSize.height + kPaddingTop + kPaddingBottom);
}

@end