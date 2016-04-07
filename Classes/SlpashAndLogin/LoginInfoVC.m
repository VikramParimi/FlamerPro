//
//  LoginInfoVC.m
//  Tinder
//
//  Created by Elluminati - macbook on 08/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "LoginInfoVC.h"

#import "LoginViewController.h"

@interface LoginInfoVC ()

@end

@implementation LoginInfoVC

@synthesize parent;

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
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpAllViews];
}

-(void)setUpAllViews
{
    UIImage * image = [UIImage imageNamed:@"privacy_horizantal_line.png"];
    UIImage * imageDot = [UIImage imageNamed:@"bullet_icon.png"];
    
    UIImageView *imgLine = [[UIImageView alloc]initWithFrame:CGRectMake(20, self.btnFBLogin.frame.origin.y+90, image.size.width, image.size.height)];
    imgLine.image =image;
    
    [self.view addSubview:imgLine];
    
    UILabel * lblHead = [[UILabel alloc]initWithFrame:CGRectMake(0, imgLine.frame.origin.y+imgLine.frame.size.height+30,320,25)];
    
    [Helper setToLabel:lblHead Text:@"We take your privacy seriously" WithFont:SEGOUE_BOLD FSize:18 Color:[Helper getColorFromHexString:@"#4c4c4c" :1]];
    lblHead.textAlignment =NSTextAlignmentCenter;
    [self.view addSubview:lblHead];
    
    UILabel * lblLine1 = [[UILabel alloc]initWithFrame:CGRectMake(55, lblHead.frame.origin.y+lblHead.frame.size.height+15,265,36)];
    lblLine1.numberOfLines = 3;
    [Helper setToLabel:lblLine1 Text:@"We will naver post anything to Facebook" WithFont:SEGOUE_UI FSize:13 Color:[Helper getColorFromHexString:@"#4c4c4c" :1]];
    [self.view addSubview:lblLine1];
    
    UILabel * lblLine2 = [[UILabel alloc]initWithFrame:CGRectMake(55, lblLine1.frame.origin.y+lblLine1.frame.size.height+15,265,36)];
    lblLine2.numberOfLines = 3;
    [Helper setToLabel:lblLine2 Text:@"Other users will never know if you've liked them unless they like u back" WithFont:SEGOUE_UI FSize:13 Color:[Helper getColorFromHexString:@"#4c4c4c" :1]];
    [self.view addSubview:lblLine2];
    
    UILabel * lblLine3 = [[UILabel alloc]initWithFrame:CGRectMake(55, lblLine2.frame.origin.y+lblLine2.frame.size.height+15,265,36)];
    lblLine3.numberOfLines = 3;
    [Helper setToLabel:lblLine3 Text:@"Other user cannot contact you unless you've already been matched" WithFont:SEGOUE_UI FSize:13 Color:[Helper getColorFromHexString:@"#4c4c4c" :1]];
    [self.view addSubview:lblLine3];
    
    UILabel * lblLine4 = [[UILabel alloc]initWithFrame:CGRectMake(55, lblLine3.frame.origin.y+lblLine3.frame.size.height+15,265,36)];
    lblLine4.numberOfLines = 3;
    
    [Helper setToLabel:lblLine4 Text:@"Your location will never be shown to other users" WithFont:SEGOUE_UI FSize:13 Color:[Helper getColorFromHexString:@"#4c4c4c" :1]];
    [self.view addSubview:lblLine4];
    
    
    UIImageView * img1 = [[UIImageView alloc]initWithFrame:CGRectMake(26, lblLine1.frame.origin.y+15, imageDot.size.width, imageDot.size.height)];
    img1.image =imageDot;
    [self.view addSubview:img1];
    
    UIImageView * img2 = [[UIImageView alloc]initWithFrame:CGRectMake(26, lblLine2.frame.origin.y+10, imageDot.size.width, imageDot.size.height)];
    img2.image =imageDot;
    [self.view addSubview:img2];
    
    UIImageView * img3 = [[UIImageView alloc]initWithFrame:CGRectMake(26, lblLine3.frame.origin.y+10, imageDot.size.width, imageDot.size.height)];
    img3.image =imageDot;
    [self.view addSubview:img3];
    
    UIImageView * img4 = [[UIImageView alloc]initWithFrame:CGRectMake(26, lblLine4.frame.origin.y+10, imageDot.size.width, imageDot.size.height)];
    img4.image =imageDot;
    [self.view addSubview:img4];
}

#pragma mark -
#pragma mark - Actions

-(IBAction)onClickbtnClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(IBAction)onClickbtnFBLogin:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([parent isKindOfClass:[LoginViewController class]]) {
            LoginViewController *vc=(LoginViewController *)parent;
            [vc onClickbtnFBLogin:nil];
        }
    }];
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
