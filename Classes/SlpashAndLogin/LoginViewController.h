//
//  LoginViewController.h
//  Tinder
//
//  Created by Rahul Sharma on 24/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "BaseVC.h"
#import "HomeViewController.h"
#import "DataBase.h"


@class TinderAppDelegate;

@interface LoginViewController : BaseVC<UIScrollViewDelegate>
{
    NSMutableArray * arrImages;
    NSString *strBdate;
}
@property(nonatomic,weak)IBOutlet UIScrollView *scrImages;
@property (nonatomic, weak) IBOutlet UIView *viewInfo;
@property (nonatomic, weak) IBOutlet UIPageControl* pageControl;
@property (nonatomic, weak) IBOutlet UIImageView * imgShadow;
@property(nonatomic,weak)IBOutlet UIButton *btnInfo;
@property(weak,nonatomic)IBOutlet UIButton *btnFBLogin;

@property(nonatomic,weak)IBOutlet UIView *viewDatePic;
@property(nonatomic,weak)IBOutlet UIDatePicker *picDate;

-(IBAction)changePage:(id)sender;
-(IBAction)onClickbtnInfo:(id)sender;
-(IBAction)onClickbtnFBLogin:(id)sender;

-(IBAction)onClickDone:(id)sender;

-(void)getLocation;

@end
