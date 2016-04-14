//
//  HomeViewController.m
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "HomeViewController.h"
#import "JSDemoViewController.h"

#import "Photo.h"
#import "User.h"
#import "EBTinderClient.h"
#import "MenuViewController.h"
#define screenWidth [UIScreen mainScreen].bounds.size.width

@interface HomeViewController ()
{
    BOOL inAnimation;
    CALayer *waveLayer;
  
    EGOImageView *profileImageView;
  
    NSMutableArray *myProfileMatches;
    NSMutableArray *myProfileRecommendations; // Tinder
    
    IBOutlet UIView *matchesView;
    IBOutlet UIView *visibleView1;
    IBOutlet UIView *visibleView2;
    
    IBOutlet UIView *visibleView3;
    IBOutlet UIView *visibleView4;
    
    IBOutlet EGOImageView *mainImageView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *nameLabel2;
    IBOutlet UILabel *commonFriends;
    IBOutlet UILabel *picsCount;
    IBOutlet UILabel *commonInterest;
    
    IBOutlet UILabel *lblMutualFriend2;
    IBOutlet UILabel *lblMutualLikes2;
  
    CGFloat xDistanceForSnapShot;
    CGFloat yDistanceForSnapShot;
    
    CGPoint originalPositionOfvw1;
    CGPoint originalPositionOfvw2;
    CGPoint originalPositionOfvw3;
    CGRect originalFrameOfVW1;
    CGRect originalFrameOfVW2;
    CGRect originalFrameOfVW3;
    
    NSInteger lastIndexOfPage;
    NSInteger indexOfPageCalledWithNavigationButtons;
}

@property (nonatomic, strong, readonly) IBOutlet EGOImageView *imgvw;
@property (nonatomic, strong) IBOutlet UILabel *decision;
@property (nonatomic, strong) IBOutlet UILabel *liked;
@property (nonatomic, strong) IBOutlet UILabel *nope;
@property (nonatomic, strong) IBOutlet UIButton *likedBtn;
@property (nonatomic, strong) IBOutlet UIButton *nopeBtn;
@property (nonatomic, strong) IBOutlet UILabel *lblNoOfImage;

@end

@implementation HomeViewController
@synthesize imgvw;
@synthesize liked;
@synthesize nope;
@synthesize lblNoOfImage;


#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark - View cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getLocation];
    
    [self initialSettingUpHomeView];
    //[self showQuestionViewIfFirstTimeLaunch];
    
    [self addingAllViewsInSideScroller];
    
    //Adding Notification Observers
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userDidLoginToTinder) name:NOTIFICATION_TINDER_LOGGED_IN object:nil];
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userDidLoginToXmpp) name:NOTIFICATION_XMPP_LOGGED_IN object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(homeScreenRefresh) name:NOTIFICATION_HOMESCREEN_REFRESH object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(navigateToNewScreenWithInfo:) name:NOTIFICATION_SCREEN_NAVIGATION_BUTTON_CLICKED object:nil];
    
    //Added
    matchesView.userInteractionEnabled = NO;
    _profileGroupIcon.hidden = YES;
    _profileBookIcon.hidden = YES;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)initialSettingUpHomeView
{
    lblNoFriendAround.hidden = NO;
    btnInvite.hidden = YES;
    
    [Helper setToLabel:lblNoFriendAround Text:@"Finding People around you." WithFont:SEGOUE_UI FSize:17 Color:[UIColor blackColor]];
    lblNoFriendAround.textAlignment = NSTextAlignmentCenter;
    
    [visibleView1.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [visibleView1.layer setBorderWidth: 0.7];
    [visibleView2.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [visibleView2.layer setBorderWidth: 0.7];
    [visibleView3.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [visibleView3.layer setBorderWidth: 0.7];
    [visibleView4.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [visibleView4.layer setBorderWidth: 0.7];
    
    [visibleView1.layer setCornerRadius:7.0];
    [visibleView1.layer setMasksToBounds:YES];
    [visibleView2.layer setCornerRadius:7.0];
    [visibleView2.layer setMasksToBounds:YES];
    [visibleView3.layer setCornerRadius:7.0];
    [visibleView3.layer setMasksToBounds:YES];
    [visibleView4.layer setCornerRadius:7.0];
    [visibleView4.layer setMasksToBounds:YES];
    
    if (IS_IPHONE_5)
    {
        profileImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(105, 170+44, 110, 110)];
    }else{
        profileImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(105, 130+44, 110, 110)];
    }
    
    profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    profileImageView.clipsToBounds = YES;
    [profileImageView.layer setCornerRadius:55.0];
    [profileImageView.layer setMasksToBounds:YES];
    
    [homeScreenView addSubview:profileImageView];
    
    viewItsMatched.backgroundColor = [Helper getColorFromHexString:@"#000000" :1.0];
    inAnimation = NO;
    waveLayer=[CALayer layer];
    if (IS_IPHONE_5) {
        waveLayer.frame = CGRectMake(155, 220+44, 10, 10);
    }else{
        waveLayer.frame = CGRectMake(155, 180+44, 10, 10);
    }
    waveLayer.borderWidth =0.2;
    waveLayer.cornerRadius =5.0;
    [homeScreenView.layer addSublayer:waveLayer];
    profileImageView.hidden = NO;
    [waveLayer setHidden:NO];
    
    originalFrameOfVW1 = visibleView1.frame;
    originalFrameOfVW2 = visibleView2.frame;
    originalFrameOfVW3 = visibleView3.frame;
    originalPositionOfvw2 = visibleView2.center;
    originalPositionOfvw3 = visibleView3.center;
    
    self.viewPercentMatch.backgroundColor=[UIColor clearColor];
    [homeScreenView bringSubviewToFront:profileImageView];
}

-(void)showQuestionViewIfFirstTimeLaunch
{
    BOOL isQuestionShow=[[NSUserDefaults standardUserDefaults]boolForKey:@"isQuestionShow"];
    if (!isQuestionShow)
    {
        QuestionVC *vcQue=[[QuestionVC alloc]initWithNibName:@"QuestionVC" bundle:nil];
        [self presentViewController:vcQue animated:YES completion:^{
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isQuestionShow"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }

}

-(void)addingAllViewsInSideScroller
{
    menuVC = [[MenuViewController alloc]init];
    chatVC = [[ChatViewController alloc]init];
    //momentsVC = [[MomentsVC alloc]init];
    int numOfPages = 3;
    
    for (int i=0; i<numOfPages; i++)
    {
        
        CGRect frame;
       
        scrollVwContainer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        frame = CGRectMake(scrollVwContainer.frame.size.width*i,
                           0,
                           scrollVwContainer.frame.size.width,
                           scrollVwContainer.frame.size.height);
        
        if (i == TagMenuVIEW) {
            [menuVC.view setFrame:frame];
            [scrollVwContainer addSubview:menuVC.view];
        }
        else if (i == TagHomeView) {
            [homeScreenView setFrame:frame];
            [scrollVwContainer addSubview:homeScreenView];
        }
        else if (i == TagChatView) {
           /* [chatVC.view setFrame:frame];
            [scrollVwContainer addSubview:chatVC.view];*/
        }
        else if (i == TagMomentsView) {
           /*[momentsVC.view setFrame:frame];
           [scrollVwContainer addSubview:momentsVC.view];*/
        }
    }
   
    scrollVwContainer.contentOffset=CGPointMake([UIScreen mainScreen].bounds.size.width*2, 0);
    scrollVwContainer.contentSize = CGSizeMake(scrollVwContainer.frame.size.width * numOfPages, scrollVwContainer.frame.size.height);
    scrollVwContainer.delegate = self;
    scrollVwContainer.showsHorizontalScrollIndicator=NO;
    scrollVwContainer.pagingEnabled = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    

    NSInteger page = TagHomeView;
    CGRect frame = scrollVwContainer.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollVwContainer scrollRectToVisible:frame animated:YES];
    lastIndexOfPage = page;
    indexOfPageCalledWithNavigationButtons = -1;
}

#pragma mark -
#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
  
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    //This is additional code to force move to screen if scrollview start automatic decelerating
    if (indexOfPageCalledWithNavigationButtons != -1)
    {
        CGPoint offset = CGPointMake(scrollVwContainer.frame.size.width * indexOfPageCalledWithNavigationButtons, 0);
        [scrollVwContainer setContentOffset:offset animated:YES];
        lastIndexOfPage = indexOfPageCalledWithNavigationButtons;
        indexOfPageCalledWithNavigationButtons = -1;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updatePager];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    indexOfPageCalledWithNavigationButtons = -1;
    if (!decelerate) {
        [self updatePager];
    }
}

- (void)updatePager
{
    int indexOfPage = floorf(scrollVwContainer.contentOffset.x / scrollVwContainer.frame.size.width);
    
    CGPoint offset = CGPointMake(scrollVwContainer.frame.size.width * indexOfPage, 0);
    [scrollVwContainer setContentOffset:offset animated:YES];
    
    if (lastIndexOfPage != indexOfPage)
    {
        switch (indexOfPage)
        {
            case TagMenuVIEW:
                [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_MENUSCREEN_REFRESH afterDelay:0.5];
                break;
            case TagHomeView:
                [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_HOMESCREEN_REFRESH afterDelay:0.5];
                break;
            case TagChatView:
                [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_CHATSCREEN_REFRESH afterDelay:0.5];
                break;
            case TagMomentsView:
                [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_MOMENTSCREEN_REFRESH afterDelay:0.5];
                break;
            default:
                break;
        }
    }
    
    lastIndexOfPage = indexOfPage;
}

#pragma mark - Notification Handler

//Notification To Navigate to other screen
-(void)navigateToNewScreenWithInfo:(NSNotification *)_notificationObj
{
    NSNumber *numPage= [[_notificationObj userInfo] valueForKey:KeyForScreenNavigation];
    int indexOfPage = [numPage intValue];
   
    NSLog(@"Page %d",indexOfPage);
   
    switch (indexOfPage)
    {
        case TagMenuVIEW:
            [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_MENUSCREEN_REFRESH afterDelay:0.5];
            break;
        case TagHomeView:
            [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_HOMESCREEN_REFRESH afterDelay:0.5];
            break;
        case TagChatView:
            [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_CHATSCREEN_REFRESH afterDelay:0.5];
            break;
        case TagMomentsView:
            [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_MOMENTSCREEN_REFRESH afterDelay:0.5];
            break;
        default:
            break;
    }
    indexOfPageCalledWithNavigationButtons = indexOfPage;
    CGPoint offset = CGPointMake(scrollVwContainer.frame.size.width * indexOfPage, 0);
    [scrollVwContainer setContentOffset:offset animated:YES];
}

//Notification To Refresh Screen
-(void)homeScreenRefresh
{
    if ([User currentUser].profile_pic!=nil)
    {
        [profileImageView setShowActivity:YES];
        [profileImageView setImageURL:[NSURL URLWithString:[User currentUser].profile_pic]];
    }
    
    //origin
    [self performSelector:@selector(sendRequestForGetMatchesFromTinder) withObject:nil afterDelay:1];
    /*if ([[[XmppCommunicationHandler sharedInstance]xmppStream] isConnected])
    {
        [self performSelector:@selector(sendRequestForGetMatches) withObject:nil afterDelay:1];
    }*/
    
    [self performSelector:@selector(startAnimation) withObject:nil];
}

// Tinder Notifcation Handler.
-(void)userDidLoginToTinder
{
    [self sendRequestForGetMatchesFromTinder];
}

-(void) sendRequestForGetMatchesFromTinder
{
    //Added
//    [[EBTinderClient sharedClient] authenticateWithTinderCompletion:^(BOOL success) {
//        
//        
//            }];
    
    // Tinder.
    [[EBTinderClient sharedClient] recommendationsWithBlock: (Completion)^(NSArray *recommendations, NSInteger count, NSError *connectionError){
        
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
        
        if (count > 0)
        {
            NSArray *matches = [[EBTinderClient sharedClient] recommendations];
            if ([matches count] > 0) {
                [self performSelectorOnMainThread:@selector(fetchRecommendatiosnData:) withObject:matches waitUntilDone:NO];
                
                //Added
                matchesView.userInteractionEnabled = YES;
                matchesView.hidden = NO;
                lblNoFriendAround.hidden = YES;
                _profileGroupIcon.hidden = YES;
                _profileBookIcon.hidden = YES;
            }
        }
        else
        {
            [Helper setToLabel:lblNoFriendAround Text:@"There's no one new around you." WithFont:SEGOUE_UI FSize:17 Color:[UIColor blackColor]];
            
            btnInvite.hidden = NO;
            
            //Added
            lblNoFriendAround.hidden = NO;
            matchesView.hidden = YES;
            
            [waveLayer setHidden:YES];
        }
    }];
    
//    //Added
//    
//    [[EBTinderClient sharedClient] authenticateWithTinderCompletion:^(BOOL success) {
//       
//        
//    }];
}

-(void)fetchRecommendatiosnData:(NSArray*)matches
{
    myProfileRecommendations  = [[NSMutableArray alloc] initWithArray:matches];
    
    if(myProfileRecommendations.count > 0)
    {
        User *match0 = [myProfileRecommendations objectAtIndex:0];
        //[TinderFBFQL executeFQlForMutualFriendForId:nil andFriendId:match0.fbid  andDelegate:self];
        //[TinderFBFQL executeFQlForMutualLikesForId:nil andFriendId:match0.fbid andDelegate:self];
        [self setupRecommendationsView];
    }
}

-(void)setupRecommendationsView
{
    self.decision.hidden = YES;
    
    if ([myProfileRecommendations count] > 0)
    {
        lblNoFriendAround.hidden = YES;
        User *match0 = [myProfileRecommendations objectAtIndex:0];
        mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        mainImageView.clipsToBounds = YES;
        
        [mainImageView setShowActivity:YES];
        NSArray *photo0Array = [match0.photos allObjects];
        Photo *photo0 = (Photo*)[photo0Array objectAtIndex:0];
        [mainImageView setImageURL:[NSURL URLWithString:photo0.url]];
        [mainImageView setBackgroundColor:[UIColor whiteColor]];
        [mainImageView setPlaceholderImage:[UIImage imageNamed:@"pfImage.png"]];
        
        [Helper setToLabel:nameLabel Text:[NSString stringWithFormat:@"%@, %d", match0.first_name, [match0 getAge]] WithFont:HELVETICALTSTD_ROMAN FSize:16 Color: BLACK_COLOR];
        
        NSString *strMFC=[NSString stringWithFormat:@"%d",(int)match0.commonFriendsCount];
        NSString *strMLC=[NSString stringWithFormat:@"%d",(int)match0.commonLikesCount];
        
        [Helper setToLabel:commonFriends Text:strMFC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color:[UIColor lightGrayColor]];
        [Helper setToLabel:commonInterest Text:strMLC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: [UIColor lightGrayColor]];
        [Helper setToLabel:picsCount Text:[NSString stringWithFormat:@"%d", [match0 photoCount]] WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR] ;
        ///picsCount.text=match[@"images"];
        ///self.lblPercentMatch.text=[NSString stringWithFormat:@"%@%%",[match objectForKey:@"matchPercentage"]];
        
        [waveLayer setHidden:YES];
        [profileImageView setHidden:YES];
        [btnInvite setHidden:YES];
        [lblNoFriendAround setHidden:YES];
        
        [matchesView setHidden:NO];
        [btnInvite setHidden:YES];
        
        originalPositionOfvw1 = visibleView1.center;
        visibleView1.hidden = NO;
        
        if ([myProfileRecommendations count] > 1)
        {
            visibleView2.hidden = NO;
            imgvw.contentMode = UIViewContentModeScaleAspectFill;
            imgvw.clipsToBounds = YES;
            User *match1 = [myProfileRecommendations objectAtIndex:1];
            
            [imgvw setShowActivity:YES];
            [imgvw setImageURL:[NSURL URLWithString:[match1 valueForKey:@"profile_pic"]]];
            [imgvw setBackgroundColor:[UIColor whiteColor]];
            [imgvw setPlaceholderImage:[UIImage imageNamed:@"pfImage.png"]];
            
            [Helper setToLabel:nameLabel2 Text:[NSString stringWithFormat:@"%@, %d", match1.first_name, [match1 getAge]] WithFont:HELVETICALTSTD_ROMAN FSize:16 Color: BLACK_COLOR] ;
            
            NSString *strMFC=[NSString stringWithFormat:@"%d", (int)match1.commonFriendsCount];
            NSString *strMLC=[NSString stringWithFormat:@"%d", (int)match1.commonLikesCount];
            
            [Helper setToLabel:lblMutualFriend2 Text:strMFC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: [UIColor lightGrayColor]];
            [Helper setToLabel:lblMutualLikes2 Text:strMLC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: [UIColor lightGrayColor]];
            [Helper setToLabel:lblNoOfImage Text:[NSString stringWithFormat:@"%d", [match1 photoCount]] WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR] ;
            ///lblNoOfImage.text=match1[@"images"];
            
            if ([myProfileRecommendations count] > 2)
            {
                visibleView3.hidden = NO;
                if ([myProfileRecommendations count] > 3) {
                    visibleView4.hidden = NO;
                }
                else
                {
                    visibleView4.hidden = YES;
                }
            }
            else
            {
                visibleView3.hidden = YES;
                visibleView4.hidden = YES;
            }
        }
        else
        {
            visibleView2.hidden = YES;
            visibleView4.hidden = YES;
            visibleView3.hidden = YES;
        }
    }
    else
    {
        [matchesView setHidden:YES];
        [btnInvite setHidden:NO];
        [waveLayer setHidden:NO];
        [profileImageView setHidden:NO];
        // [self performSelector:@selector(startAnimation) withObject:nil];
    }
}

/*

-(void)imageDownloader:(NSString*)url forId:(NSString*)fbid
{
    
    NSString *tmpDir = NSTemporaryDirectory();
    
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:url]
                                                        options:0
                                                       progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         // progression tracking code
     }
                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
     {
         if (image && finished)
         {
             NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
             NSString *savePath = [tmpDir stringByAppendingPathComponent:fbid];
             [data writeToFile:[savePath stringByAppendingPathExtension:@"jpg"] atomically:YES];
             [self performSelectorOnMainThread:@selector(doneDownloadingImageFor:) withObject:fbid waitUntilDone:NO];
         }
     }];
}

-(void)doneDownloadingImageFor:(NSString*)fbid
{
    static NSInteger count = 0;
    count++;
    if (count <= [myProfileMatches count])
    {
        lblNoFriendAround.hidden = YES;
        NSDictionary *match = [myProfileMatches objectAtIndex:0];
        mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        mainImageView.clipsToBounds = YES;
        
        NSString *savePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:match[@"fbId"]] stringByAppendingPathExtension:@"jpg"];
        
        mainImageView.image = [UIImage imageWithContentsOfFile:savePath];
        [Helper setToLabel:nameLabel Text:[NSString stringWithFormat:@"%@, %@", match[@"firstName"], match[@"age"]] WithFont:HELVETICALTSTD_ROMAN FSize:16 Color: BLACK_COLOR] ;
        
        NSString *strMFC=[NSString stringWithFormat:@"%@",match[@"mutualFriendcout"]];
        NSString *strMLC=[NSString stringWithFormat:@"%@",match[@"mutualLikecount"]];
        
        [Helper setToLabel:commonFriends Text:strMFC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR];
        [Helper setToLabel:commonInterest Text:strMLC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR];
        
        [Helper setToLabel:picsCount Text:[NSString stringWithFormat:@"%@", match[@"imgCnt"]] WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR] ;
        picsCount.text=match[@"images"];
        
        self.lblPercentMatch.text=[NSString stringWithFormat:@"%@%%",[match objectForKey:@"matchPercentage"]];
        
        [waveLayer setHidden:YES];
        [profileImageView setHidden:YES];
        [btnInvite setHidden:YES];
        [lblNoFriendAround setHidden:YES];
        
        
        [matchesView setHidden:NO];
        [btnInvite setHidden:YES];
        
        
        originalPositionOfvw1 = visibleView1.center;
        visibleView1.hidden = NO;
        
        if (count >= 1 && [myProfileRecommendations count]>1)
        {
            visibleView2.hidden = NO;
            imgvw.contentMode = UIViewContentModeScaleAspectFill;
            imgvw.clipsToBounds = YES;
            NSDictionary *match1 = [myProfileMatches objectAtIndex:1];
            NSString *savePath1 = [[NSTemporaryDirectory() stringByAppendingPathComponent:match1[@"fbId"]] stringByAppendingPathExtension:@"jpg"];
            
            imgvw.image = [UIImage imageWithContentsOfFile:savePath1];
            
            [Helper setToLabel:nameLabel2 Text:[NSString stringWithFormat:@"%@, %@", match1[@"firstName"], match1[@"age"]] WithFont:HELVETICALTSTD_ROMAN FSize:16 Color: BLACK_COLOR] ;
            
            NSString *strMFC=[NSString stringWithFormat:@"%@",match1[@"mutualFriendcout"]];
            NSString *strMLC=[NSString stringWithFormat:@"%@",match1[@"mutualLikecount"]];
            
            [Helper setToLabel:lblMutualFriend2 Text:strMFC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR];
            [Helper setToLabel:lblMutualLikes2 Text:strMLC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR];
            
            [Helper setToLabel:lblNoOfImage Text:[NSString stringWithFormat:@"%@", match1[@"imgCnt"]] WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR] ;
            lblNoOfImage.text=match1[@"images"];
            
        }
        else {
            visibleView2.hidden = YES;
        }
        count = 0;
    }
}
 
*/
#pragma mark -
#pragma mark - actionForNopeAndLike

-(IBAction)pan:(UIPanGestureRecognizer*)gs
{
    CGPoint curLoc = visibleView1.center;
    CGPoint translation = [gs translationInView:gs.view.superview];
    float diff = 0;
    
    if (gs.state == UIGestureRecognizerStateBegan)
    {
        xDistanceForSnapShot = visibleView1.center.x;
        yDistanceForSnapShot = visibleView1.center.y;
    }
    else if (gs.state == UIGestureRecognizerStateChanged)
    {
        
        if (curLoc.x < originalPositionOfvw1.x)
        {
            diff = originalPositionOfvw1.x - curLoc.x;
            if (diff > 50)
                [nope setAlpha:1];
            else {
                [nope setAlpha:diff/50];
            }
            [liked setHidden:YES];
            [nope setHidden:NO];
            
        }
        else if (curLoc.x > originalPositionOfvw1.x) {
            diff = curLoc.x - originalPositionOfvw1.x;
            if (diff > 50)
                [liked setAlpha:1];
            else {
                [liked setAlpha:diff/50];
            }
            
            [liked setHidden:NO];
            [nope setHidden:YES];
        }
        
        /*
         gs.view.center = CGPointMake(gs.view.center.x + translation.x,
         gs.view.center.y + translation.y);
         [gs setTranslation:CGPointMake(0, 0) inView:self.view];
         */

        //Updated By Sanskar
        
        CGFloat xDistance = [gs translationInView:homeScreenView].x;
        CGFloat yDistance = [gs translationInView:homeScreenView].y;

        CGFloat rotationStrength = MIN(xDistance / screenWidth, 1);
        CGFloat rotationAngel = - (CGFloat) (2*M_PI * rotationStrength / 8);
        CGFloat scaleStrength = 1 - fabsf(rotationStrength) / 8;
        CGFloat scale = MAX(scaleStrength, 0.93);
        
        gs.view.center = CGPointMake(xDistanceForSnapShot + xDistance, yDistanceForSnapShot + yDistance);
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
        CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
        gs.view.transform = scaleTransform;
                
        CGFloat tran = diff/3000;
       
       // NSLog(@"tran %f",tran);
    
        if (tran <=0.03) {
            visibleView2.transform = CGAffineTransformMakeScale(1.0+tran,1.0);
            visibleView3.transform = CGAffineTransformMakeScale(1.0+tran,1.0);
        }
        CGPoint centerForVW2 = CGPointMake(originalPositionOfvw2.x, originalPositionOfvw2.y-diff/50);
        visibleView2.center = centerForVW2;
        
        CGPoint centerForVW3 = CGPointMake(originalPositionOfvw3.x, originalPositionOfvw3.y-diff/50);
        visibleView3.center = centerForVW3;
        
        if (abs(diff) > 50)
        {
            
        }
    }
    else if (gs.state == UIGestureRecognizerStateEnded)
    {
        if (![nope isHidden] || ![liked isHidden])
        {
            visibleView1.transform = CGAffineTransformIdentity;
            
            visibleView1.frame = originalFrameOfVW1;
            visibleView2.frame = originalFrameOfVW2;
            visibleView3.frame = originalFrameOfVW3;
            
            [nope setHidden:YES];
            [liked setHidden:YES];
            [visibleView1 setHidden:YES];
            visibleView1.center = originalPositionOfvw1;
           
            [visibleView1 setHidden:NO];
            diff = curLoc.x - originalPositionOfvw1.x;
            
            if (abs(diff) > 50) {
                
                UIButton *btn = nil;
                if (diff > 0) {
                    btn = self.nopeBtn;
                }
                else {
                    btn = self.likedBtn;
                }
                
                self.decision.text = @"";
                
                [self performSelector:@selector(likeDislikeButtonAction:) withObject:btn];
            }
        }
    }
}

-(void)updateNextProfileView
{
    self.decision.hidden = YES;
    [myProfileRecommendations removeObjectAtIndex:0];
    
    if(myProfileRecommendations.count>0)
    {
        User *user =[myProfileRecommendations objectAtIndex:0];
        //[TinderFBFQL executeFQlForMutualFriendForId:nil andFriendId:[dictForMutal valueForKey:@"fbId"] andDelegate:self];
        //[TinderFBFQL executeFQlForMutualLikesForId:nil andFriendId:[dictForMutal valueForKey:@"fbId"] andDelegate:self];
        
    }
    [self setupRecommendationsView];
    
    //origin.
    /*self.decision.hidden = YES;
    [myProfileMatches removeObjectAtIndex:0];
    
    if(myProfileMatches.count>0)
    {
        NSMutableDictionary *dictForMutal=[myProfileMatches objectAtIndex:0];
        [TinderFBFQL executeFQlForMutualFriendForId:nil andFriendId:[dictForMutal valueForKey:@"fbId"] andDelegate:self];
        [TinderFBFQL executeFQlForMutualLikesForId:nil andFriendId:[dictForMutal valueForKey:@"fbId"] andDelegate:self];
        
    }
    
    [self setupMatchesView];*/
    
}

-(IBAction)likeDislikeButtonAction:(UIButton*)sender
{
    User* profile = [myProfileRecommendations objectAtIndex:0];
    
    if (sender.tag == 300) { // Like
        [self performSelector:@selector(sendLikeAction:) withObject:@{@"user": profile, @"action": [NSNumber numberWithInt:1]}];
        
    }
    else if (sender.tag == 200) { // Dislike
         [self performSelector:@selector(sendLikeAction:) withObject:@{@"user": profile, @"action": [NSNumber numberWithInt:2]}];
    }
    
    if (self.decision.text.length > 0) {
        self.decision.hidden = NO;
        
        [homeScreenView bringSubviewToFront:self.decision];
        
        if (sender.tag == 300) {
            self.decision.text = @"Liked";
            self.decision.textColor = [UIColor colorWithRed:0.001 green:0.548 blue:0.002 alpha:1.000];
        }
        else {
            self.decision.text = @"Noped";
            self.decision.textColor = [UIColor redColor];
        }
        
        [self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0];
    }
    else {
        self.decision.text = @"Liked";
        [self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0];
    }
    
    
    // change tinder.
    /*NSDictionary *profile = [myProfileMatches objectAtIndex:0];
    
    if ([[[XmppCommunicationHandler sharedInstance] xmppStream]isConnected])
    {
       
        if (sender.tag == 300) { // Like
            [self performSelector:@selector(sendInviteAction:) withObject:@{@"fbid": profile[@"fbId"], @"action": [NSNumber numberWithInt:1]}];
            
        }
        else if (sender.tag == 200) { // Dislike
            [self performSelector:@selector(sendInviteAction:) withObject:@{@"fbid": profile[@"fbId"], @"action": [NSNumber numberWithInt:2]}];
        }
        
        if (self.decision.text.length > 0) {
            self.decision.hidden = NO;
            [homeScreenView bringSubviewToFront:self.decision];
            if (sender.tag == 300) {
                self.decision.text = @"Liked";
                self.decision.textColor = [UIColor colorWithRed:0.001 green:0.548 blue:0.002 alpha:1.000];
            }
            else {
                self.decision.text = @"Noped";
                self.decision.textColor = [UIColor redColor];
            }
            [self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0];
        }
        else {
            self.decision.text = @"Liked";
            [self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Please Try Again!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }*/

}

-(void)loadImageForSharedFrnd :(NSArray*)arrayFrnd
{
    commonFriends.text=[NSString stringWithFormat:@"%d",arrayFrnd.count];
}

-(void)loadImageForSharedIntrest:(NSArray*)arrayIntrst
{
    commonInterest.text=[NSString stringWithFormat:@"%d",arrayIntrst.count];
}

-(IBAction)showUserProfile:(id)sender
{
    if ([myProfileRecommendations count]==0)
    {
        return;
    }
    ProfileVC *vc=[[ProfileVC alloc]initWithNibName:@"ProfileVC" bundle:nil];
    User *user=[myProfileRecommendations objectAtIndex:0];
    vc.user=user;
    //origin
    /*if ([myProfileMatches count]==0)
    {
        return;
    }
    ProfileVC *vc=[[ProfileVC alloc]initWithNibName:@"ProfileVC" bundle:nil];
    
    NSDictionary *dict=[myProfileMatches objectAtIndex:0];
    User *user=[[User alloc]init];
    user.fbid=[dict objectForKey:@"fbId"];
    user.first_name=[dict objectForKey:@"firstName"];
    user.profile_pic=[dict objectForKey:@"pPic"];
    vc.user=user;*/
  
    UINavigationController *navVc = [[UINavigationController alloc]initWithRootViewController:vc];
    
    [self presentViewController:navVc animated:YES completion:nil];
       
}

/*
-(void)donePreviewing:(NSNumber*)val
{
    if ([val integerValue] == 0) {
        return;
    }
    
    NSDictionary *profile = [myProfileMatches objectAtIndex:0];
    [self performSelector:@selector(sendInviteAction:) withObject:@{@"fbid": profile[@"fbId"], @"action": val}];
    [self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0];
}*/


-(void)sendLikeAction:(NSDictionary*)params
{
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    User* user = (User*)params[@"user"];
    int likeKind = (int)params[@"action"]; // 1: like, 2: dislike.
    
    if (likeKind == 1) // like.
    {
        [[EBTinderClient sharedClient] likeUser:user onCompletion:^(BOOL success){
            [self likeActionResponse:NO user:user success:success];
        }];
    }
    else if (likeKind == 2) // dislike
    {
        [[EBTinderClient sharedClient] passUser:user onCompletion:^(BOOL success){
            [self likeActionResponse:NO user:user success:success];
        }];
    }
}

-(void)likeActionResponse:(BOOL)isLike user:(User*)user success:(BOOL)response
{
    if (response == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Karmic" message:@"Please Try Again!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    } else {
     
        if (isLike == YES)
        {
            viewItsMatched.hidden = NO;
            NSMutableArray* likedUsers = [[EBTinderClient sharedClient] likedUsers];
            [[UserDefaultHelper sharedObject] setItsMatchTinder:likedUsers];
            [homeScreenView bringSubviewToFront:viewItsMatched];
            [Helper setToLabel:lblItsMatchedSubText Text:[NSString stringWithFormat:@"You and %@ have liked each other.",user.name] WithFont:HELVETICALTSTD_LIGHT FSize:14 Color:[UIColor whiteColor]];
            
            lblItsMatchedSubText.textAlignment= NSTextAlignmentCenter;
            
            RoundedImageView *userImg  = [[RoundedImageView alloc] initWithFrame:CGRectMake(45, 125, 110, 110)];
            [userImg downloadFromURL:[User currentUser].profile_pic withPlaceholder:nil];
            
            RoundedImageView *FriendImg  = [[RoundedImageView alloc] initWithFrame:CGRectMake(155+20, 125, 110, 110)];
            UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(50/2-20/2, 46/2-20/2, 20, 20)];
            [FriendImg addSubview:activityIndicator];
            
            activityIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
            [activityIndicator startAnimating];
            
            Photo* photo0 = [user photoIndex:0];
            if (photo0 != nil)
                FriendImg.image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[Helper removeWhiteSpaceFromURL:photo0.url]]]];
            [activityIndicator stopAnimating];
            
            [viewItsMatched addSubview:userImg];
            [viewItsMatched addSubview:FriendImg];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            /*if ([[[XmppCommunicationHandler sharedInstance] xmppStream]isConnected])
            {
                [[XmppCommunicationHandler sharedInstance] acceptFriendRequestWithFriendName:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]] friendDisplayName:dict[@"uName"] friendImageUrl:dict[@"pPic"]];
                [[XmppCommunicationHandler sharedInstance]setCurrentFriendName:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]]];
            }
            
            NSMutableDictionary *dictFriend = [[NSMutableDictionary alloc] init];
            
            NSString *jid = [NSString stringWithFormat:@"%@@%@/%@",[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]],CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
            
            [dictFriend setObject:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]] forKey:@"friendName"];
            [dictFriend setObject:jid forKey:@"friendJid"];
            [dictFriend setObject:[NSNumber numberWithInt:0] forKey:@"messageCount"];
            [dictFriend setObject:@"You 're a match! Now say Hi :)" forKey:@"lastMessage"];
            [dictFriend setObject:@"" forKey:@"lastMessageTime"];
            [dictFriend setObject:@"Offline" forKey:@"presenceStatus"];
            [dictFriend setObject:dict[@"uName"] forKey:@"friendDisplayName"];
            [dictFriend setObject:@"NO" forKey:@"isBlocked"];
            
            NSString *matchedDate = user.lastActive//[dict valueForKey:@"ladt"];
            
            if (matchedDate.length)
            {
                matchedDate = [[UtilityClass sharedObject]stringFromDateString:matchedDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"MM/dd"];
                [dictFriend setObject:[NSString stringWithFormat:@"Matched on %@",matchedDate] forKey:@"lastMessage"];
            }
            else
            {
                [dictFriend setObject:[NSString stringWithFormat:@"Matched Just Now"] forKey:@"lastMessage"];
            }
            
            
            NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photo0.url]];
            
            if (imgData)
            {
                [dictFriend setObject:imgData forKey:@"friendImage"];
            }
            else
            {
                [dictFriend setObject:[NSData dataFromBase64String:@""] forKey:@"friendImage"];
            }
            
            [[XmppFriendHandler sharedInstance] insertOrUpdateFriendInfoInDatabase:dictFriend];
            
            [[XmppCommunicationHandler sharedInstance] setCurrentFriendName:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]]];*/
        }
    }
}

/*
-(void)sendInviteAction:(NSDictionary*)params
{
    if ([[[XmppCommunicationHandler sharedInstance] xmppStream]isConnected])
    {
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
        [paramDict setObject:params[@"fbid"]  forKey:PARAM_ENT_INVITEE_FBID];
        [paramDict setObject:flStrForObj(params[@"action"])  forKey:PARAM_ENT_USER_ACTION];
        [paramDict setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
        
        WebServiceHandler *handler = [[WebServiceHandler alloc] init];
        handler.requestType = eParseKey;
        NSMutableURLRequest * request = [Service parseInviteAction:paramDict];
        [handler placeWebserviceRequestWithString:request Target:self Selector:@selector(inviteActionResponse:)];
        
        [[XmppCommunicationHandler sharedInstance] SendFriendRequestWithFriendName:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,params[@"fbid"]]];
    }
   else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Karmic" message:@"Please Try Again!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)inviteActionResponse:(NSDictionary*)response
{
    NSDictionary * dict = [response objectForKey:@"ItemsList"];
    
    if ([[dict objectForKey:@"errFlag"]integerValue] ==0 &&[[dict objectForKey:@"errNum"]integerValue] ==55)
    {
        viewItsMatched.hidden = NO;
        [[UserDefaultHelper sharedObject]setItsMatch:[NSMutableDictionary dictionaryWithDictionary:dict]];
        [homeScreenView bringSubviewToFront:viewItsMatched];
        [Helper setToLabel:lblItsMatchedSubText Text:[NSString stringWithFormat:@"You and %@ have liked each other.",dict[@"uName"]] WithFont:HELVETICALTSTD_LIGHT FSize:14 Color:[UIColor whiteColor]];
        
        lblItsMatchedSubText.textAlignment= NSTextAlignmentCenter;
        
        RoundedImageView *userImg  = [[RoundedImageView alloc] initWithFrame:CGRectMake(45, 125, 110, 110)];
        [userImg downloadFromURL:[User currentUser].profile_pic withPlaceholder:nil];
        
        RoundedImageView *FriendImg  = [[RoundedImageView alloc] initWithFrame:CGRectMake(155+20, 125, 110, 110)];
        UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(50/2-20/2, 46/2-20/2, 20, 20)];
        [FriendImg addSubview:activityIndicator];
        
        activityIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
        [activityIndicator startAnimating];
        
        FriendImg.image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[Helper removeWhiteSpaceFromURL:dict[@"pPic"]]]]];
        [activityIndicator stopAnimating];
        
        [viewItsMatched addSubview:userImg];
        [viewItsMatched addSubview:FriendImg];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        if ([[[XmppCommunicationHandler sharedInstance] xmppStream]isConnected])
        {
            [[XmppCommunicationHandler sharedInstance] acceptFriendRequestWithFriendName:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]] friendDisplayName:dict[@"uName"] friendImageUrl:dict[@"pPic"]];
            [[XmppCommunicationHandler sharedInstance]setCurrentFriendName:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]]];
        }
        
        NSMutableDictionary *dictFriend = [[NSMutableDictionary alloc] init];
        
        NSString *jid = [NSString stringWithFormat:@"%@@%@/%@",[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]],CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
        
        [dictFriend setObject:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]] forKey:@"friendName"];
        [dictFriend setObject:jid forKey:@"friendJid"];
        [dictFriend setObject:[NSNumber numberWithInt:0] forKey:@"messageCount"];
        [dictFriend setObject:@"You 're a match! Now say Hi :)" forKey:@"lastMessage"];
        [dictFriend setObject:@"" forKey:@"lastMessageTime"];
        [dictFriend setObject:@"Offline" forKey:@"presenceStatus"];
        [dictFriend setObject:dict[@"uName"] forKey:@"friendDisplayName"];
        [dictFriend setObject:@"NO" forKey:@"isBlocked"];
        
        NSString *matchedDate = [dict valueForKey:@"ladt"];
        
        if (matchedDate.length)
        {
            matchedDate = [[UtilityClass sharedObject]stringFromDateString:matchedDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"MM/dd"];
            [dictFriend setObject:[NSString stringWithFormat:@"Matched on %@",matchedDate] forKey:@"lastMessage"];
        }
        else
        {
            [dictFriend setObject:[NSString stringWithFormat:@"Matched Just Now"] forKey:@"lastMessage"];
        }

        
        NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dict[@"pPic"]]];
        
        if (imgData)
        {
            [dictFriend setObject:imgData forKey:@"friendImage"];
        }
        else
        {
            [dictFriend setObject:[NSData dataFromBase64String:@""] forKey:@"friendImage"];
        }
        
        [[XmppFriendHandler sharedInstance] insertOrUpdateFriendInfoInDatabase:dictFriend];
        
        [[XmppCommunicationHandler sharedInstance] setCurrentFriendName:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]]];

    }
    else
    {
        viewItsMatched.hidden = YES;
        lblNoFriendAround.hidden = YES;
        [Helper setToLabel:lblNoFriendAround Text:@"There's no one new around you." WithFont:SEGOUE_UI FSize:17 Color:[UIColor blackColor]];
        btnInvite.hidden = YES;
    }
    
   // if (visibleView1.hidden == YES) {
   //     [Helper setToLabel:lblNoFriendAround Text:@"There's no one new around you." WithFont:SEGOUE_UI FSize:17 Color:[UIColor blackColor]];
   //     btnInvite.hidden = NO;
   //     lblNoFriendAround .hidden= NO;
   //     visibleView2.hidden = NO;
   // }
 
    
    if (matchesView.hidden == YES) {
        [Helper setToLabel:lblNoFriendAround Text:@"There's no one new around you." WithFont:SEGOUE_UI FSize:17 Color:[UIColor blackColor]];
        btnInvite.hidden = NO;
        lblNoFriendAround .hidden= NO;
    }
}*/

-(void)getLocation
{
    [[LocationHelper sharedObject]startLocationUpdatingWithBlock:^(CLLocation *newLocation, CLLocation *oldLocation, NSError *error) {
        if (!error) {
            [[LocationHelper sharedObject]stopLocationUpdating];
            [super updateLocation];
        }
    }];
    
}

-(IBAction)btnActionForItsMatchedView :(id)sender
{
    
    UIButton * btn =(UIButton*)sender;
    if (btn.tag ==100) {
        viewItsMatched.hidden = YES;
    }
    else
    {
        NSMutableDictionary * dictMatch=[[UserDefaultHelper sharedObject] itsMatch];
        
        //Adding Friend to Db
        NSMutableDictionary *dictFriend = [[NSMutableDictionary alloc] init];
        
        NSString *jid = [NSString stringWithFormat:@"%@@%@/%@",[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dictMatch[@"uFbId"]],CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
        
        [dictFriend setObject:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dictMatch[@"uFbId"]] forKey:@"friendName"];
        [dictFriend setObject:jid forKey:@"friendJid"];
        [dictFriend setObject:[NSNumber numberWithInt:0] forKey:@"messageCount"];
        [dictFriend setObject:@"You 're a match! Now say Hi :)" forKey:@"lastMessage"];
        [dictFriend setObject:@"" forKey:@"lastMessageTime"];
        [dictFriend setObject:@"Offline" forKey:@"presenceStatus"];
        [dictFriend setObject:dictMatch[@"uName"] forKey:@"friendDisplayName"];
        [dictFriend setObject:@"NO" forKey:@"isBlocked"];
       
        NSString *matchedDate = [dictMatch valueForKey:@"ladt"];
        
        if (matchedDate.length)
        {
            matchedDate = [[UtilityClass sharedObject]stringFromDateString:matchedDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"MM/dd"];
            [dictFriend setObject:[NSString stringWithFormat:@"Matched on %@",matchedDate] forKey:@"lastMessage"];
        }
        else
        {
            [dictFriend setObject:[NSString stringWithFormat:@"Matched Just Now"] forKey:@"lastMessage"];
        }
        
        NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dictMatch[@"pPic"]]];
        
        if (imgData)
        {
            [dictFriend setObject:imgData forKey:@"friendImage"];
        }
        else
        {
            [dictFriend setObject:[NSData dataFromBase64String:@""] forKey:@"friendImage"];
        }
        
    //    [[XmppFriendHandler sharedInstance] insertOrUpdateFriendInfoInDatabase:dictFriend];
        
        [self performSelectorOnMainThread:@selector(pushToChatViewController:) withObject:dictMatch waitUntilDone:YES];
    }
}

-(void)pushToChatViewController :(NSDictionary *)dict
{
    JSDemoViewController *vc = [[JSDemoViewController alloc] init];
    /*User *xmppFriend = [[XmppFriendHandler sharedInstance]getXmppFriendWithName:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]]];
    vc.currentChatObj = xmppFriend;
    [[XmppCommunicationHandler sharedInstance]setCurrentFriendName:xmppFriend.friend_Name];*/

    [self.navigationController pushViewController:vc animated:YES];
    
}


#pragma mark -
#pragma mark - Animation Methods

-(void)startAnimation
{
    if ([waveLayer isHidden] || ![homeScreenView window] || inAnimation == YES)
    {
        return;
    }
    inAnimation = YES;
    [self waveAnimation:waveLayer];
}

-(void)waveAnimation:(CALayer*)aLayer
{
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.duration = 3;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transformAnimation.removedOnCompletion = YES;
    transformAnimation.fillMode = kCAFillModeRemoved;
    [aLayer setTransform:CATransform3DMakeScale( 10, 10, 1.0)];
    [transformAnimation setDelegate:self];
    
    CATransform3D xform = CATransform3DIdentity;
   // xform = CATransform3DScale(xform, 40, 40, 1.0);
    xform = CATransform3DScale(xform, 32, 32, 1.0);
    transformAnimation.toValue = [NSValue valueWithCATransform3D:xform];
    [aLayer addAnimation:transformAnimation forKey:@"transformAnimation"];
    
    
    UIColor *fromColor = [UIColor colorWithRed:255 green:120 blue:0 alpha:1];
    UIColor *toColor = [UIColor colorWithRed:255 green:120 blue:0 alpha:0.1];
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    colorAnimation.duration = 3;
    colorAnimation.fromValue = (id)fromColor.CGColor;
    colorAnimation.toValue = (id)toColor.CGColor;
    
    [aLayer addAnimation:colorAnimation forKey:@"colorAnimationBG"];
    
    
    UIColor *fromColor1 = [UIColor colorWithRed:0 green:255 blue:0 alpha:1];
    UIColor *toColor1 = [UIColor colorWithRed:0 green:255 blue:0 alpha:0.1];
    CABasicAnimation *colorAnimation1 = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    colorAnimation1.duration = 3;
    colorAnimation1.fromValue = (id)fromColor1.CGColor;
    colorAnimation1.toValue = (id)toColor1.CGColor;
    
    [aLayer addAnimation:colorAnimation1 forKey:@"colorAnimation"];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    inAnimation = NO;
    [self performSelectorInBackground:@selector(startAnimation) withObject:nil];
}

#pragma mark -
#pragma mark - Mail Methods

-(IBAction)openMail :(id)sender
{
    [super sendMailSubject:@"Flamer App!" toRecipents:[NSArray arrayWithObject:@""] withMessage:@"I am using Flamer App ! Whay don't you try it out…<br/>Install Flamer now !<br/><b>Google Play :-</b> <a href='https://play.google.com/store/apps/details?id=com.appdupe.flamernofb'>https://play.google.com/store/apps/details?id=com.appdupe.flamernofb</a><br/><b>iTunes :-</b>"];
}

#pragma mark -
#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 400) { //connection timeout error
        
    }
}

- (IBAction)btnSettingTapped:(id)sender
{
    NSDictionary *dictInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:TagMenuVIEW] forKey:KeyForScreenNavigation];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SCREEN_NAVIGATION_BUTTON_CLICKED object:nil userInfo:dictInfo];
}

- (IBAction)btnChattingTapped:(id)sender
{
    NSDictionary *dictInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:TagChatView] forKey:KeyForScreenNavigation];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SCREEN_NAVIGATION_BUTTON_CLICKED object:nil userInfo:dictInfo];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

#pragma mark -
#pragma mark - Memory Mgmt
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


/*
//Notification Handler
-(void) userDidLoginToXmpp
{
    [self sendRequestForGetMatches];
}

#pragma mark -
#pragma mark - requestForGetMatches

-(void)sendRequestForGetMatches
{
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_FINDMATCHES withParamData:paramDict withBlock:^(id response, NSError *error)
     {
         if (response)
         {
             if ([[response objectForKey:@"errFlag"] intValue]==0)
             {
                 NSArray *matches = response[@"matches"];
                 if ([matches count] > 0) {
                     [self performSelectorOnMainThread:@selector(fetchMatchesData:) withObject:matches waitUntilDone:NO];
                 }else{
                     [Helper setToLabel:lblNoFriendAround Text:@"There's no one new around you." WithFont:SEGOUE_UI FSize:17 Color:[UIColor blackColor]];
                     btnInvite.hidden = NO;
                     lblNoFriendAround = NO;
                     [waveLayer setHidden:YES];
                 }
             }
             else{
                 [Helper setToLabel:lblNoFriendAround Text:@"There's no one new around you." WithFont:SEGOUE_UI FSize:17 Color:[UIColor blackColor]];
                 btnInvite.hidden = NO;
                 lblNoFriendAround = NO;
                 [waveLayer setHidden:YES];
             }
         }else{
             [Helper setToLabel:lblNoFriendAround Text:@"There's no one new around you." WithFont:SEGOUE_UI FSize:17 Color:[UIColor blackColor]];
             btnInvite.hidden = NO;
             lblNoFriendAround = NO;
             [waveLayer setHidden:YES];
         }
     }];
}

-(void)fetchMatchesData:(NSArray*)matches
{
    myProfileMatches  = [[NSMutableArray alloc] initWithArray:matches];
    
    if(myProfileMatches.count>0)
    {
        NSMutableDictionary *dictForMutal=[myProfileMatches objectAtIndex:0];
        [TinderFBFQL executeFQlForMutualFriendForId:nil andFriendId:[dictForMutal valueForKey:@"fbId"] andDelegate:self];
        [TinderFBFQL executeFQlForMutualLikesForId:nil andFriendId:[dictForMutal valueForKey:@"fbId"] andDelegate:self];
        [self setupMatchesView];
    }
}

-(void)setupMatchesView
{
    self.decision.hidden = YES;
    
    if ([myProfileMatches count] > 0)
    {
        lblNoFriendAround.hidden = YES;
        NSDictionary *match = [myProfileMatches objectAtIndex:0];
        mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        mainImageView.clipsToBounds = YES;
        
        [mainImageView setShowActivity:YES];
        [mainImageView setImageURL:[NSURL URLWithString:[match valueForKey:@"pPic"]]];
        [mainImageView setBackgroundColor:[UIColor whiteColor]];
        [mainImageView setPlaceholderImage:[UIImage imageNamed:@"pfImage.png"]];
        
        [Helper setToLabel:nameLabel Text:[NSString stringWithFormat:@"%@, %@", match[@"firstName"], match[@"age"]] WithFont:HELVETICALTSTD_ROMAN FSize:16 Color: BLACK_COLOR] ;
        
        NSString *strMFC=[NSString stringWithFormat:@"%@",match[@"mutualFriendcout"]];
        NSString *strMLC=[NSString stringWithFormat:@"%@",match[@"mutualLikecount"]];
        
        [Helper setToLabel:commonFriends Text:strMFC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color:[UIColor lightGrayColor]];
        [Helper setToLabel:commonInterest Text:strMLC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: [UIColor lightGrayColor]];
        
        [Helper setToLabel:picsCount Text:[NSString stringWithFormat:@"%@", match[@"imgCnt"]] WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR] ;
        picsCount.text=match[@"images"];
        
        self.lblPercentMatch.text=[NSString stringWithFormat:@"%@%%",[match objectForKey:@"matchPercentage"]];
        
        [waveLayer setHidden:YES];
        [profileImageView setHidden:YES];
        [btnInvite setHidden:YES];
        [lblNoFriendAround setHidden:YES];
        
        [matchesView setHidden:NO];
        [btnInvite setHidden:YES];
        
        originalPositionOfvw1 = visibleView1.center;
        visibleView1.hidden = NO;
        
        
        if ([myProfileMatches count] > 1)
        {
            visibleView2.hidden = NO;
            imgvw.contentMode = UIViewContentModeScaleAspectFill;
            imgvw.clipsToBounds = YES;
            NSDictionary *match1 = [myProfileMatches objectAtIndex:1];
            
            [imgvw setShowActivity:YES];
            [imgvw setImageURL:[NSURL URLWithString:[match1 valueForKey:@"pPic"]]];
            [imgvw setBackgroundColor:[UIColor whiteColor]];
            [imgvw setPlaceholderImage:[UIImage imageNamed:@"pfImage.png"]];
            
            [Helper setToLabel:nameLabel2 Text:[NSString stringWithFormat:@"%@, %@", match1[@"firstName"], match1[@"age"]] WithFont:HELVETICALTSTD_ROMAN FSize:16 Color: BLACK_COLOR] ;
            
            
            NSString *strMFC=[NSString stringWithFormat:@"%@",match1[@"mutualFriendcout"]];
            NSString *strMLC=[NSString stringWithFormat:@"%@",match1[@"mutualLikecount"]];
            
            [Helper setToLabel:lblMutualFriend2 Text:strMFC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: [UIColor lightGrayColor]];
            [Helper setToLabel:lblMutualLikes2 Text:strMLC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: [UIColor lightGrayColor]];
            
            [Helper setToLabel:lblNoOfImage Text:[NSString stringWithFormat:@"%@", match1[@"imgCnt"]] WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR] ;
            lblNoOfImage.text=match1[@"images"];
            
            if ([myProfileMatches count] > 2)
            {
                visibleView3.hidden = NO;
                
                if ([myProfileMatches count] > 3) {
                    visibleView4.hidden = NO;
                }
                else
                {
                    visibleView4.hidden = YES;
                }
            }
            else
            {
                visibleView3.hidden = YES;
                visibleView4.hidden = YES;
            }
        }
        else
        {
            visibleView2.hidden = YES;
            visibleView4.hidden = YES;
            visibleView3.hidden = YES;
        }
    }
    else
    {
        [matchesView setHidden:YES];
        [btnInvite setHidden:NO];
        [waveLayer setHidden:NO];
        [profileImageView setHidden:NO];
        // [self performSelector:@selector(startAnimation) withObject:nil];
    }
}*/

@end
