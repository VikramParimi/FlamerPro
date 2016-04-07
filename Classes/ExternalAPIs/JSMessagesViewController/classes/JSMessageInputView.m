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

#import "JSMessageInputView.h"
#import "JSBubbleView.h"
#import "NSString+JSMessagesView.h"
#import "UIColor+JSMessagesView.h"
#import <QuartzCore/QuartzCore.h>
#define SEND_BUTTON_WIDTH 65.0f
#define OTHER_ATTACHMENT_BUTTON_WIDTH 40.0f

@interface JSMessageInputView ()

- (void)setup;
- (void)configureInputBarWithStyle:(JSMessageInputViewStyle)style;
- (void)configureSendButtonWithStyle:(JSMessageInputViewStyle)style;
- (void)configureOtherAttachmentButtonWithStyle:(JSMessageInputViewStyle)style;

@end

@implementation JSMessageInputView


#pragma mark - Initialization

- (void)setup
{

    
    
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    self.userInteractionEnabled = YES;
}

- (void)configureInputBarWithStyle:(JSMessageInputViewStyle)style
{
    //jigs
    //CGFloat width = self.frame.size.width - SEND_BUTTON_WIDTH;
    CGFloat width = self.frame.size.width - SEND_BUTTON_WIDTH;
    CGFloat height = [JSMessageInputView textViewLineHeight];
    
    CGFloat padding = 8.0;
    
    JSMessageTextView *textView = [[JSMessageTextView  alloc] initWithFrame:CGRectMake(OTHER_ATTACHMENT_BUTTON_WIDTH+padding, 0, width, height)];
    [self addSubview:textView];
	_textView = textView;
    
    if(style == JSMessageInputViewStyleClassic)
    {
        //jigs
        //_textView.frame = CGRectMake(6.0f, 3.0f, width, height);
        _textView.frame = CGRectMake(36.0f, 3.0f, width, height);
        _textView.backgroundColor = [UIColor whiteColor];
        
        self.image = [[UIImage imageNamed:@"input-bar-background"] resizableImageWithCapInsets:UIEdgeInsetsMake(19.0f, 3.0f, 19.0f, 3.0f)
                                                                                  resizingMode:UIImageResizingModeStretch];
        
        UIImageView *inputFieldBack = [[UIImageView alloc] initWithFrame:CGRectMake(_textView.frame.origin.x - 1.0f,
                                                                                    0.0f,
                                                                                    _textView.frame.size.width + 2.0f,
                                                                                    self.frame.size.height)];
        inputFieldBack.image = [[UIImage imageNamed:@"input-field-cover"] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 12.0f, 18.0f, 18.0f)];
        inputFieldBack.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        inputFieldBack.backgroundColor = [UIColor clearColor];
        [self addSubview:inputFieldBack];
    }
    else
    {
      //  _textView.frame = CGRectMake(OTHER_ATTACHMENT_BUTTON_WIDTH+padding, padding/2, width, height);
        _textView.frame = CGRectMake(padding, padding/2, width, height);
        _textView.backgroundColor = [UIColor clearColor];
        _textView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        _textView.layer.borderWidth = 0.65f;
        _textView.layer.cornerRadius = 6.0f;
        
        self.image = [[UIImage imageNamed:@"input-bar-flat"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)
                                                                            resizingMode:UIImageResizingModeStretch];
    }
}

- (void)configureOtherAttachmentButtonWithStyle:(JSMessageInputViewStyle)style
{
    UIButton *otherAttchButton;
    
    if(style == JSMessageInputViewStyleClassic) {
        otherAttchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f);
        UIImage *sendBack = [[UIImage imageNamed:@"send-button"] resizableImageWithCapInsets:insets];
        UIImage *sendBackHighLighted = [[UIImage imageNamed:@"send-button-pressed"] resizableImageWithCapInsets:insets];
        [otherAttchButton setBackgroundImage:sendBack forState:UIControlStateNormal];
        [otherAttchButton setBackgroundImage:sendBack forState:UIControlStateDisabled];
        [otherAttchButton setBackgroundImage:sendBackHighLighted forState:UIControlStateHighlighted];
        
        UIColor *titleShadow = [UIColor colorWithRed:0.325f green:0.463f blue:0.675f alpha:1.0f];
        [otherAttchButton setTitleShadowColor:titleShadow forState:UIControlStateNormal];
        [otherAttchButton setTitleShadowColor:titleShadow forState:UIControlStateHighlighted];
        otherAttchButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        
        [otherAttchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [otherAttchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [otherAttchButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateDisabled];
        
        otherAttchButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    }
    else {
        otherAttchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        otherAttchButton.backgroundColor = [UIColor clearColor];
        
        [otherAttchButton setTitleColor:[UIColor js_iOS7blueColor] forState:UIControlStateNormal];
        [otherAttchButton setTitleColor:[UIColor js_iOS7blueColor] forState:UIControlStateHighlighted];
        [otherAttchButton setTitleColor:[UIColor js_iOS7lightGrayColor] forState:UIControlStateDisabled];
        
        otherAttchButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    }
    
    /*
    NSString *title = NSLocalizedString(@"Other", nil);
    [otherAttchButton setTitle:title forState:UIControlStateNormal];
    [otherAttchButton setTitle:title forState:UIControlStateHighlighted];
    [otherAttchButton setTitle:title forState:UIControlStateDisabled];
    */
    
    UIImage *sendBack = [UIImage imageNamed:@"icon_option_filters.png"];
  //  UIImage *sendBackHighLighted = [[UIImage imageNamed:@"send-button-pressed"] resizableImageWithCapInsets:insets];
    [otherAttchButton setBackgroundImage:sendBack forState:UIControlStateNormal];
    [otherAttchButton setBackgroundImage:sendBack forState:UIControlStateDisabled];
  //  [otherAttchButton setBackgroundImage:sendBackHighLighted forState:UIControlStateHighlighted];
    [otherAttchButton setBackgroundColor:[UIColor lightGrayColor]];
    
    otherAttchButton.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
    
    [self setOtherAttachButton:otherAttchButton];
}


- (void)configureSendButtonWithStyle:(JSMessageInputViewStyle)style
{
    UIButton *sendButton;
    
    if(style == JSMessageInputViewStyleClassic) {
        sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f);
        UIImage *sendBack = [[UIImage imageNamed:@"send-button"] resizableImageWithCapInsets:insets];
        UIImage *sendBackHighLighted = [[UIImage imageNamed:@"send-button-pressed"] resizableImageWithCapInsets:insets];
        [sendButton setBackgroundImage:sendBack forState:UIControlStateNormal];
        [sendButton setBackgroundImage:sendBack forState:UIControlStateDisabled];
        [sendButton setBackgroundImage:sendBackHighLighted forState:UIControlStateHighlighted];
        
        UIColor *titleShadow = [UIColor colorWithRed:0.325f green:0.463f blue:0.675f alpha:1.0f];
        [sendButton setTitleShadowColor:titleShadow forState:UIControlStateNormal];
        [sendButton setTitleShadowColor:titleShadow forState:UIControlStateHighlighted];
        sendButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [sendButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateDisabled];
        
        sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    }
    else
    {
        sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.backgroundColor = [UIColor clearColor];
        
        [sendButton setTitleColor:[UIColor js_iOS7blueColor] forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor js_iOS7blueColor] forState:UIControlStateHighlighted];
        [sendButton setTitleColor:[UIColor js_iOS7lightGrayColor] forState:UIControlStateDisabled];
        
        sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    }
    
    NSString *title = NSLocalizedString(@"Send", nil);
    [sendButton setTitle:title forState:UIControlStateNormal];
    [sendButton setTitle:title forState:UIControlStateHighlighted];
    [sendButton setTitle:title forState:UIControlStateDisabled];
    
    sendButton.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
    
    [self setSendButton:sendButton];
}

- (instancetype)initWithFrame:(CGRect)frame
                        style:(JSMessageInputViewStyle)style
                     delegate:(id<UITextViewDelegate, JSDismissiveTextViewDelegate>)delegate
         panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
    self = [super initWithFrame:frame];
    if(self) {
        _style = style;
        [self setup];
        [self configureInputBarWithStyle:style];
        [self configureSendButtonWithStyle:style];
     //   [self configureOtherAttachmentButtonWithStyle:style];
        
        _textView.delegate = delegate;
        _textView.keyboardDelegate = delegate;
        _textView.dismissivePanGestureRecognizer = panGestureRecognizer;
    }
    return self;
}

- (void)dealloc
{
    _textView = nil;
    _sendButton = nil;
}

#pragma mark - UIView

- (BOOL)resignFirstResponder
{
    [self.textView resignFirstResponder];
    return [super resignFirstResponder];
}

#pragma mark - Setters

- (void)setSendButton:(UIButton *)btn
{
    if(_sendButton)
        [_sendButton removeFromSuperview];
    
    if(self.style == JSMessageInputViewStyleClassic) {
        btn.frame = CGRectMake(self.frame.size.width - 65.0f, 8.0f, 59.0f, 26.0f);
    }
    else {
        CGFloat padding = 8.0;
        btn.frame = CGRectMake(self.textView.frame.origin.x + self.textView.frame.size.width,
                               padding,
                               SEND_BUTTON_WIDTH,
                               self.textView.frame.size.height - padding);
    }
    
    [self addSubview:btn];
    _sendButton = btn;
}

- (void)setOtherAttachButton:(UIButton *)btn
{
    if(_otherAttachButton)
        [_otherAttachButton removeFromSuperview];
    
    if(self.style == JSMessageInputViewStyleClassic) {
        btn.frame = CGRectMake(0, 8.0f, 59.0f, 26.0f);
    }
    else {
        CGFloat padding =
        
        8.0f;
        btn.frame = CGRectMake(3,
                               padding,
                               OTHER_ATTACHMENT_BUTTON_WIDTH-3,
                               self.textView.frame.size.height - padding);
    }
    
    [self addSubview:btn];
    _otherAttachButton = btn;
}


#pragma mark - Message input view

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight
{
    CGRect prevFrame = self.textView.frame;
    
    int numLines = MAX([self.textView numberOfLinesOfText],
                       [self.textView.text js_numberOfLines]);
    
    self.textView.frame = CGRectMake(prevFrame.origin.x,
                                     prevFrame.origin.y,
                                     prevFrame.size.width,
                                     prevFrame.size.height + changeInHeight);
    
    self.textView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f,
                                                  (numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f);
    
    self.textView.scrollEnabled = (numLines >= 4);
    
    if(numLines >= 6) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.textView.contentSize.height - self.textView.bounds.size.height);
        [self.textView setContentOffset:bottomOffset animated:YES];
    }
}

+ (CGFloat)textViewLineHeight
{
return 36.0f; // for fontSize 16.0f
    
}

+ (CGFloat)maxLines
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 4.0f : 8.0f;
}

+ (CGFloat)maxHeight
{
    return ([JSMessageInputView maxLines] + 1.0f) * [JSMessageInputView textViewLineHeight];
}

@end