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

#import "JSMessagesViewController.h"
#import "JSMessageTextView.h"
#import "NSString+JSMessagesView.h"

@interface JSMessagesViewController () <JSDismissiveTextViewDelegate,JSBubbleMessageCellDelegate>
{
    BOOL isEditingTable;
    NSMutableArray *arrayIndexSelected;
    UIButton *btnSelectAll;
    UIButton *btnDeleteMsgs;
    
    UIBarButtonItem *defaultLeftBarButton;
    UIBarButtonItem *defaultRightBarButton;
    
}

@property (assign, nonatomic, readonly) UIEdgeInsets originalTableViewContentInset;
@property (assign, nonatomic) CGFloat previousTextViewContentHeight;
@property (assign, nonatomic) BOOL isUserScrolling;

- (void)setup;

- (void)sendPressed:(UIButton *)sender;

- (BOOL)shouldHaveTimestampForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)shouldHaveAvatarForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)shouldHaveSubtitleForRowAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)shouldAllowScroll;

- (void)handleWillShowKeyboardNotification:(NSNotification *)notification;
- (void)handleWillHideKeyboardNotification:(NSNotification *)notification;
- (void)keyboardWillShowHide:(NSNotification *)notification;

- (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve;

@end


@implementation JSMessagesViewController

#pragma mark - Initialization

- (void)setup
{
   
    
    
    if([self.view isKindOfClass:[UIScrollView class]]) {
        // FIXME: hack-ish fix for ipad modal form presentations
        ((UIScrollView *)self.view).scrollEnabled = NO;
    }
    
	_isUserScrolling = NO;
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    JSMessageInputViewStyle inputViewStyle = [self.delegate inputViewStyle];
    CGFloat inputViewHeight = (inputViewStyle == JSMessageInputViewStyleFlat) ? 45.0f : 40.0f;
    
    CGRect tableFrame = CGRectMake(0.0f, 0.0f, size.width, size.height - inputViewHeight-15.0f);
	UITableView *tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tableView.dataSource = self;
	tableView.delegate = self;
	[self.view addSubview:tableView];
	_tableView = tableView;
    
    [self setBackgroundColor:[UIColor js_backgroundColorClassic]];
    
    
    if ([self.delegate respondsToSelector:@selector(addSubviewsToSuperViewInitially)]) {
        [self.delegate addSubviewsToSuperViewInitially];
    }
    
//    CGRect inputFrame = CGRectMake(0.0f,
//                                   size.height - inputViewHeight,
//                                   size.width,
//                                   inputViewHeight);
    
    CGRect inputFrame = CGRectMake(0.0f,
                                   size.height - 65.0,
                                   size.width,
                                   inputViewHeight+18);
    
    JSMessageInputView *inputView = [[JSMessageInputView alloc] initWithFrame:inputFrame
                                                                        style:inputViewStyle
                                                                     delegate:self
                                                         panGestureRecognizer:_tableView.panGestureRecognizer];
    
    if([self.delegate respondsToSelector:@selector(sendButtonForInputView)])
    {
        UIButton *sendButton = [self.delegate sendButtonForInputView];
        [inputView setSendButton:sendButton];
    }
    
    inputView.sendButton.enabled = NO;
    [inputView.sendButton addTarget:self
                             action:@selector(sendPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [inputView.otherAttachButton addTarget:self
                             action:@selector(otherAttachPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:inputView];
    _messageInputView = inputView;
    
    arrayIndexSelected = [[NSMutableArray alloc]init];
    [self setEditModeView];
 
}

-(void)setEditModeView
{
    UIImage *imgButton = [UIImage imageNamed:@"three-dot-icon.png"];
    btnSelectAll = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSelectAll setFrame:CGRectMake(0,4,80, 35)];
   // [rightbarbutton setImage:imgButton forState:UIControlStateNormal];
    [btnSelectAll setTitle:@"Select All" forState:UIControlStateNormal];
    [btnSelectAll setTitle:@"Unselect All" forState:UIControlStateSelected];
    [btnSelectAll setTitleColor:ACTION_SHEET_COLOR forState:UIControlStateNormal];
    [btnSelectAll setFont:[UIFont systemFontOfSize:14]];
    [btnSelectAll addTarget:self action:@selector(selectAllRowsAction:) forControlEvents:UIControlEventTouchUpInside];
   
    
    UIImage *imgBtn = [UIImage imageNamed:@"back-active-icon.png"];
    btnDeleteMsgs = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDeleteMsgs setFrame:CGRectMake(0,4,60, 35)];
   // [btnDeleteMsgs setImage:imgButton forState:UIControlStateNormal];
    [btnDeleteMsgs setTitleColor:ACTION_SHEET_COLOR forState:UIControlStateNormal];
    [btnDeleteMsgs setTitle:@"Delete" forState:UIControlStateNormal];
    [btnDeleteMsgs setFont:[UIFont systemFontOfSize:14]];
    [btnDeleteMsgs addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
   // self.tableView.frame = CGRectMake(0,0.,ScreenSize.width, self.messageInputView.frame.origin.y-44.0);
    NSLog(@"TBL Frame %@",NSStringFromCGRect(self.tableView.frame));
    [self scrollToBottomAnimated:YES];
    
    //  FIXME: this is a hack
    //  ---------------------
    //  Possibly an iOS 7 bug?
    //  tableView.contentInset.top = 0.0 on iOS 6
    //  tableView.contentInset.top = 64.0 on iOS 7
    //  save here in order to reset in [ keyboardWillShowHide: ]
    //  ---------------------
    _originalTableViewContentInset = self.tableView.contentInset;
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillShowKeyboardNotification:)
												 name:UIKeyboardWillShowNotification
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillHideKeyboardNotification:)
												 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.messageInputView resignFirstResponder];
    [self setEditing:NO animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"*** %@: didReceiveMemoryWarning ***", self.class);
}

- (void)dealloc
{
    _delegate = nil;
    _dataSource = nil;
    _tableView = nil;
    _messageInputView = nil;
}

#pragma mark - View rotation

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.tableView reloadData];
    [self.tableView setNeedsLayout];
}

#pragma mark - Actions

- (void)sendPressed:(UIButton *)sender
{
    [self.delegate didSendText:[self.messageInputView.textView.text js_stringByTrimingWhitespace]];
}

- (void)otherAttachPressed:(UIButton *)sender
{
    [self.delegate otherAttachPressed];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSBubbleMessageType type = [self.delegate messageTypeForRowAtIndexPath:indexPath];
    
    UIImageView *bubbleImageView = [self.delegate bubbleImageViewWithType:type
                                                        forRowAtIndexPath:indexPath];
    
    BOOL hasTimestamp = [self shouldHaveTimestampForRowAtIndexPath:indexPath];
    BOOL hasAvatar = [self shouldHaveAvatarForRowAtIndexPath:indexPath];
	BOOL hasSubtitle = [self shouldHaveSubtitleForRowAtIndexPath:indexPath];
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"MessageCell_%d_%d_%d_%d", type, hasTimestamp, hasAvatar, hasSubtitle];
    JSBubbleMessageCell *cell = (JSBubbleMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell) {
        cell = [[JSBubbleMessageCell alloc] initWithBubbleType:type
                                               bubbleImageView:bubbleImageView
                                                  hasTimestamp:hasTimestamp
                                                     hasAvatar:hasAvatar
                                                   hasSubtitle:hasSubtitle
                                               reuseIdentifier:CellIdentifier];
    }
    
    if(hasTimestamp) {
        [cell setTimestamp:[self.dataSource timestampForRowAtIndexPath:indexPath]];
    }
	
    if(hasAvatar) {
        [cell setAvatarImageView:[self.dataSource avatarImageViewForRowAtIndexPath:indexPath]];
    }
    
	if(hasSubtitle) {
		[cell setSubtitle:[self.dataSource subtitleForRowAtIndexPath:indexPath]];
    }
    
    if (type == JSBubbleMessageTypeIncomingImage || type == JSBubbleMessageTypeOutgoingImage)
    {
        [cell setImageWithUrl:[self.dataSource imageUrlForRowAtIndexPath:indexPath]];
    }
    else if (type == JSBubbleMessageTypeIncoming || type == JSBubbleMessageTypeOutgoing)
    {
        [cell setMessage:[self.dataSource textForRowAtIndexPath:indexPath]];
    }

    [cell setIndexOfRow:indexPath.row];
    [cell setDelegate:self];
   
    [cell setBackgroundColor:tableView.backgroundColor];
    
    if([self.delegate respondsToSelector:@selector(configureCell:atIndexPath:)]) {
        [self.delegate configureCell:cell atIndexPath:indexPath];
    }
    
    [cell.bubbleView.btnCheckmark setTag:indexPath.row];
    [cell.bubbleView.btnCheckmark addTarget:self action:@selector(btnCheckMarkTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    if (isEditingTable)
        [cell.bubbleView.btnCheckmark setHidden:NO];
    else
        [cell.bubbleView.btnCheckmark setHidden:YES];
    
    [cell.bubbleView.btnCheckmark setSelected:NO];
    
    if ([arrayIndexSelected containsObject:[NSNumber numberWithInt:indexPath.row]]) {
         [cell.bubbleView.btnCheckmark setSelected:YES];
    }
    
    [cell prepareForReuse];
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [(JSBubbleMessageCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath] height];
}

#pragma mark - Messages view controller

- (BOOL)shouldHaveTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([self.delegate timestampPolicy]) {
        case JSMessagesViewTimestampPolicyAll:
            return YES;
            
        case JSMessagesViewTimestampPolicyAlternating:
            return indexPath.row % 2 == 0;
            
        case JSMessagesViewTimestampPolicyEveryThree:
            return indexPath.row % 3 == 0;
            
        case JSMessagesViewTimestampPolicyEveryFive:
            return indexPath.row % 5 == 0;
            
        case JSMessagesViewTimestampPolicyCustom:
            if([self.delegate respondsToSelector:@selector(hasTimestampForRowAtIndexPath:)])
                return [self.delegate hasTimestampForRowAtIndexPath:indexPath];
            
        default:
            return NO;
    }
}

- (BOOL)shouldHaveAvatarForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch ([self.delegate avatarPolicy]) {
        case JSMessagesViewAvatarPolicyAll:
            return YES;
            
        case JSMessagesViewAvatarPolicyIncomingOnly:
            return [self.delegate messageTypeForRowAtIndexPath:indexPath] == JSBubbleMessageTypeIncoming;
			
		case JSMessagesViewAvatarPolicyOutgoingOnly:
			return [self.delegate messageTypeForRowAtIndexPath:indexPath] == JSBubbleMessageTypeOutgoing;
            
        case JSMessagesViewAvatarPolicyNone:
        default:
            return NO;
    }
}

- (BOOL)shouldHaveSubtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([self.delegate subtitlePolicy]) {
        case JSMessagesViewSubtitlePolicyAll:
            return YES;
        
        case JSMessagesViewSubtitlePolicyIncomingOnly:
            return [self.delegate messageTypeForRowAtIndexPath:indexPath] == JSBubbleMessageTypeIncoming;
            
        case JSMessagesViewSubtitlePolicyOutgoingOnly:
            return [self.delegate messageTypeForRowAtIndexPath:indexPath] == JSBubbleMessageTypeOutgoing;
            
        case JSMessagesViewSubtitlePolicyNone:
        default:
            return NO;
    }
}

- (void)finishSend
{
    [self.messageInputView.textView setText:nil];
    [self textViewDidChange:self.messageInputView.textView];
    //[self.tableView reloadData];
}

- (void)setBackgroundColor:(UIColor *)color
{
    self.view.backgroundColor = color;
    _tableView.backgroundColor = color;
    _tableView.separatorColor = color;
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
	if(![self shouldAllowScroll])
        return;
	
    NSInteger rows = [self.tableView numberOfRowsInSection:0];

    if(rows > 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
			  atScrollPosition:(UITableViewScrollPosition)position
					  animated:(BOOL)animated
{
	if(![self shouldAllowScroll])
        return;
	
	[self.tableView scrollToRowAtIndexPath:indexPath
						  atScrollPosition:position
								  animated:animated];
}

- (BOOL)shouldAllowScroll
{
    if(self.isUserScrolling) {
        if([self.delegate respondsToSelector:@selector(shouldPreventScrollToBottomWhileUserScrolling)]
           && [self.delegate shouldPreventScrollToBottomWhileUserScrolling]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	self.isUserScrolling = YES;
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.isUserScrolling = NO;
   
}

#pragma mark - Text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
	
    if(!self.previousTextViewContentHeight)
		self.previousTextViewContentHeight = textView.contentSize.height;
    
    [self scrollToBottomAnimated:YES];
 
    if ([self.delegate respondsToSelector:@selector(didBeginEditingInMessageTextView)]) {
         [self.delegate didBeginEditingInMessageTextView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat maxHeight = [JSMessageInputView maxHeight];
    
    //  TODO:
    //
    //  CGFloat textViewContentHeight = textView.contentSize.height;
    //
    //  The line above is broken as of iOS 7.0
    //
    //  There seems to be a bug in Apple's code for textView.contentSize
    //  The following code was implemented as a workaround for calculating the appropriate textViewContentHeight
    //
    //  https://devforums.apple.com/thread/192052
    //  https://github.com/jessesquires/MessagesTableViewController/issues/50
    //  https://github.com/jessesquires/MessagesTableViewController/issues/47
    //
    // BEGIN HACK
    //
        CGSize size = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, maxHeight)];
        CGFloat textViewContentHeight = size.height;
    //
    //  END HACK
    //
    
    BOOL isShrinking = textViewContentHeight < self.previousTextViewContentHeight;
    CGFloat changeInHeight = textViewContentHeight - self.previousTextViewContentHeight;
    
    if(!isShrinking && self.previousTextViewContentHeight == maxHeight) {
        changeInHeight = 0;
    }
    else
    {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    
    if(changeInHeight != 0.0f) {
        
        [UIView animateWithDuration:0.25f
                         animations:^{
                             UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,
                                                                    0.0f,
                                                                    self.tableView.contentInset.bottom + changeInHeight,
                                                                    0.0f);
                             
                             self.tableView.contentInset = insets;
                             self.tableView.scrollIndicatorInsets = insets;
                             [self scrollToBottomAnimated:NO];
                             
                             if(isShrinking) {
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [self.messageInputView adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             CGRect inputViewFrame = self.messageInputView.frame;
                             self.messageInputView.frame = CGRectMake(0.0f,
                                                                      inputViewFrame.origin.y - changeInHeight,
                                                                      inputViewFrame.size.width,
                                                                      inputViewFrame.size.height + changeInHeight);
                             
                             if(!isShrinking) {
                                 // growing the view, animate the text view frame AFTER input view frame
                                 [self.messageInputView adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
        
        self.previousTextViewContentHeight = MIN(textViewContentHeight, maxHeight);
    }
    
    self.messageInputView.sendButton.enabled = ([textView.text js_stringByTrimingWhitespace].length > 0);
}

#pragma mark - Keyboard notifications

- (void)handleWillShowKeyboardNotification:(NSNotification *)notification
{
    [self keyboardWillShowHide:notification];
}

- (void)handleWillHideKeyboardNotification:(NSNotification *)notification
{
    [self keyboardWillShowHide:notification];
}

- (void)keyboardWillShowHide:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
	double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:[self animationOptionsForCurve:curve]
                     animations:^{
                         CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
                         
                         CGRect inputViewFrame = self.messageInputView.frame;
                         CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
                         
                         // for ipad modal form presentations
                         CGFloat messageViewFrameBottom = self.view.frame.size.height - inputViewFrame.size.height;
                         if(inputViewFrameY > messageViewFrameBottom)
                             inputViewFrameY = messageViewFrameBottom;
						 
                         self.messageInputView.frame = CGRectMake(inputViewFrame.origin.x,
																  inputViewFrameY,
																  inputViewFrame.size.width,
																  inputViewFrame.size.height);

                         
                         /*
                         UIEdgeInsets insets = self.originalTableViewContentInset;
                         insets.bottom = self.view.frame.size.height
                                            - self.messageInputView.frame.origin.y
                                            - inputViewFrame.size.height;
                         
                         self.tableView.contentInset = insets;
                         self.tableView.scrollIndicatorInsets = insets;
                          */
                         
                         self.tableView.frame = CGRectMake(0, 44.0f,ScreenSize.width, self.messageInputView.frame.origin.y-44.0);
                          NSLog(@"TBL Frame %@",NSStringFromCGRect(self.tableView.frame));
                         [self scrollToBottomAnimated:YES];
                         
                     }
                     completion:^(BOOL finished) {
                     }];
}

#pragma mark - Dismissive text view delegate

- (void)keyboardDidScrollToPoint:(CGPoint)point
{
    CGRect inputViewFrame = self.messageInputView.frame;
    CGPoint keyboardOrigin = [self.view convertPoint:point fromView:nil];
    inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
    self.messageInputView.frame = inputViewFrame;
}

- (void)keyboardWillBeDismissed
{
    CGRect inputViewFrame = self.messageInputView.frame;
    inputViewFrame.origin.y = self.view.bounds.size.height - inputViewFrame.size.height;
    self.messageInputView.frame = inputViewFrame;
}

- (void)keyboardWillSnapBackToPoint:(CGPoint)point
{
    CGRect inputViewFrame = self.messageInputView.frame;
    CGPoint keyboardOrigin = [self.view convertPoint:point fromView:nil];
    inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
    self.messageInputView.frame = inputViewFrame;
}

#pragma mark -
#pragma mark - Utilities

- (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve
{
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
            
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
            
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
            
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
            
        default:
            return kNilOptions;
    }
}

#pragma mark - JsBubbleMessageCell Delegate
-(void)callForDeleteRowAtIndex:(int)indexRow
{
    if([self.delegate respondsToSelector:@selector(deleteRowAtIndex:)])
    {
        [self.delegate deleteRowAtIndex:indexRow];
    }
}

-(void)deleteMessageTapped
{
    defaultLeftBarButton = self.navigationItem.leftBarButtonItem;
    defaultRightBarButton = self.navigationItem.rightBarButtonItem;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnSelectAll];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnDeleteMsgs];

    isEditingTable = YES;
    [self.tableView reloadData];
}

-(IBAction)btnCheckMarkTapped:(UIButton *)sender
{
    NSNumber *indexSelected = [NSNumber numberWithInt:sender.tag];
    
    if (![sender isSelected])
    {
        [sender setSelected:YES];
        [arrayIndexSelected addObject:indexSelected];
    }
    else
    {
        [sender setSelected:NO];
        if ([arrayIndexSelected containsObject:indexSelected]) {
            [arrayIndexSelected removeObject:indexSelected];
        }
    }
    
    [self.tableView reloadData];
}

-(IBAction)selectAllRowsAction:(UIButton *)sender
{
    if (![sender isSelected])
    {
        [sender setSelected:YES];
        [arrayIndexSelected removeAllObjects];
        int totalRows = [self.tableView numberOfRowsInSection:0];
        for (int i =0; i<totalRows; i++)
        {
            if (![arrayIndexSelected containsObject:[NSNumber numberWithInt:i]])
            {
                [arrayIndexSelected addObject:[NSNumber numberWithInt:i]];
            }
        }
    }
    else
    {
        [sender setSelected:NO];
        [arrayIndexSelected removeAllObjects];
    }
    
    [self.tableView reloadData];
}

-(IBAction)deleteAction:(UIBarButtonItem *)sender
{
    isEditingTable = NO;
   
    if([self.delegate respondsToSelector:@selector(deleteRowsWithIndexes:)])
    {
        [self.delegate deleteRowsWithIndexes:arrayIndexSelected];
    }
    
    [arrayIndexSelected removeAllObjects];
    self.navigationItem.leftBarButtonItem  = defaultLeftBarButton;
    self.navigationItem.rightBarButtonItem = defaultRightBarButton;
}

@end