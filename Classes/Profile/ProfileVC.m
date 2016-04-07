//
//  ProfileVC.m
//  Tinder
//
//  Created by Elluminati - macbook on 12/06/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "ProfileVC.h"
#import "UIImageView+Download.h"
#import "EditProfileVC.h"
#import "EGOImageView.h"
#import "Photo.h"

#define HeightScrollView 257.0

@interface ProfileVC ()
{
    IBOutlet UIScrollView *scrContainer;
    IBOutlet UIView *vwContainer;
    IBOutlet UIView *vwDetails;
}

@end

@implementation ProfileVC

@synthesize user;

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
    
    arrImages=[[NSMutableArray alloc]init];
    currentPage=0;
    
   // [self.navigationItem setTitle:@"Profile"];
    self.navigationController.navigationBarHidden = YES;
    
    if (user==nil)                  //Self Profile
    {
        [btnDone setHidden:NO];
        self.lblActive.hidden=YES;
        self.lblAway.hidden=YES;
        [btnEditProfile setHidden:NO];
    }
    else{
        self.lblActive.hidden=NO;
        self.lblAway.hidden=NO;
        [btnDone setHidden:NO];
        [btnEditProfile setHidden:YES];
    }
    
    [self.pcImage setNumberOfPages:[arrImages count]];
    [self.pcImage setCurrentPage:currentPage];
    
    //Setting up the scrollView
    _scrImage.bouncesZoom = YES;
    _scrImage.clipsToBounds = YES;
    
    _scrImage.delegate = self;
    scrContainer.delegate = self;
    [scrContainer setContentSize:CGSizeMake(ScreenSize.width, vwContainer.frame.size.height+200)];
    
    [self initialSettingUpView];
    
}

-(void)initialSettingUpView
{
    EGOImageView *imgProfilePic=[[EGOImageView alloc]initWithFrame:CGRectMake(0, 0, self.scrImage.frame.size.width, self.scrImage.frame.size.height)];
    [imgProfilePic setBackgroundColor:[UIColor whiteColor]];
    [imgProfilePic setShowActivity:YES];
    [imgProfilePic setImageURL:[NSURL URLWithString:[User currentUser].profile_pic]];
    imgProfilePic.tag=1000;
    [self.scrImage addSubview:imgProfilePic];
    
    [self.scrImage setContentSize:CGSizeMake(self.scrImage.frame.size.width, self.scrImage.frame.size.height)];
    [self.pcImage setNumberOfPages:1];
    [self.pcImage setCurrentPage:0];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.navigationController.navigationBarHidden = YES;
    
    [self setUserProfile:user];
    
    /*if (user==nil) {
        [self getUserProfile:[User currentUser].fbid];
    }else{
        [self getUserProfile:user.fbid];
    }*/
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

-(void)BackToMassageController:(UIButton*)sender
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)btnDoneTapped:(id)sender
{
    //[self.navigationController popViewControllerAnimated:NO];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - Methods


-(void)setUserProfile:(User *)user
{
    self.lblNameAndAge.text=[NSString stringWithFormat:@"%@(%d)",user.name,[user getAge]];
    
    self.lblNameAndAge.text=user.name;
    self.txtAbout.text=[NSString stringWithFormat:@"Status: n/a"];

    int userphotoCount = [user photoCount];
    if (userphotoCount > 0) {
        [arrImages removeAllObjects];
        // [arrImages addObject:[user photoIndex:0]];
        [arrImages addObjectsFromArray:[user.photos allObjects] ];
        [self setScroll];
    }
    //origin.
  /*   NSMutableArray *arr=[[NSMutableArray alloc]initWithArray:[response objectForKey:@"images"]];
     if (arr)
     {
         [arr removeObject:[response objectForKey:@"profilePic"]];
         [arrImages removeAllObjects];
         [arrImages addObject:[response objectForKey:@"profilePic"]];
         [arrImages addObjectsFromArray:arr];
         [self setScroll];
     }*/
     
     NSString *strActiveText = [Helper ConverGMTtoLocal:[user lastActiveString]];
     self.lblActive.text=[NSString stringWithFormat:@"active %@ hour ago",strActiveText];
     
     CLLocationDistance distance;
     /*NSString *userLati= user.curr_lat;
     NSString *userLongi=user.curr_long;
     CLLocation *locB = [[CLLocation alloc] initWithLatitude:[[[UserDefaultHelper sharedObject] currentLatitude] floatValue] longitude:[[[UserDefaultHelper sharedObject] currentLongitude] floatValue]];
     CLLocation *locA = [[CLLocation alloc] initWithLatitude:[userLati floatValue] longitude:[userLongi floatValue]];*/
     NSNumber* dist = user.distanceFilter;
     distance=(double)[dist doubleValue];//[locA distanceFromLocation:locB];
     int Km = distance/1000;
     self.lblAway.text=[NSString stringWithFormat:@"less than %dkm away",Km];
}

/*
-(void)getUserProfile:(NSString *)fbid
{
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:fbid forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GETPROFILE withParamData:dictParam withBlock:^(id response, NSError *error)
    {
        if (response)
        {
            if ([[response objectForKey:@"errFlag"] intValue]==0)
            {
              
                if ([response objectForKey:@"age"]!=nil)
                {
                    self.lblNameAndAge.text=[NSString stringWithFormat:@"%@(%@)",[response objectForKey:@"firstName"],[response objectForKey:@"age"]];
                }
                else
                {
                    self.lblNameAndAge.text=[response objectForKey:@"firstName"];
                }
                if ([response objectForKey:@"status"]==nil || [[response objectForKey:@"status"]isEqualToString:@""])
                {
                    self.txtAbout.text=[NSString stringWithFormat:@"Status: n/a"];
                }
                else
                {
                    self.txtAbout.text=[NSString stringWithFormat:@"Status: %@",[response objectForKey:@"status"]];
                }
                
                NSMutableArray *arr=[[NSMutableArray alloc]initWithArray:[response objectForKey:@"images"]];
                if (arr)
                {
                    [arr removeObject:[response objectForKey:@"profilePic"]];
                    [arrImages removeAllObjects];
                    [arrImages addObject:[response objectForKey:@"profilePic"]];
                    [arrImages addObjectsFromArray:arr];
                    [self setScroll];
                }
                
                NSString *strActiveText = [Helper ConverGMTtoLocal:response[@"lastActive"]];
                self.lblActive.text=[NSString stringWithFormat:@"active %@ hour ago",strActiveText];
                
                CLLocationDistance distance;
                NSString *userLati=[response valueForKey:@"lati"];
                NSString *userLongi=[response valueForKey:@"long"];
                CLLocation *locB = [[CLLocation alloc] initWithLatitude:[[[UserDefaultHelper sharedObject] currentLatitude] floatValue] longitude:[[[UserDefaultHelper sharedObject] currentLongitude] floatValue]];
                CLLocation *locA = [[CLLocation alloc] initWithLatitude:[userLati floatValue] longitude:[userLongi floatValue]];
                distance=[locA distanceFromLocation:locB];
                int Km = distance/1000;
                self.lblAway.text=[NSString stringWithFormat:@"less than %dkm away",Km];
                
            }
        }
    }];
}*/

-(void)setScroll
{
    [self.scrImage.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    int x=0;
    for (int i=0; i<[arrImages count]; i++)
    {
        EGOImageView *img=[[EGOImageView alloc]initWithFrame:CGRectMake(x, 0, self.scrImage.frame.size.width, self.scrImage.frame.size.height)];
        [img setBackgroundColor:[UIColor whiteColor]];
        [img setShowActivity:YES];
        Photo* iPhoto = [arrImages objectAtIndex:i];
        [img setImageURL:[NSURL URLWithString:iPhoto.url]];
       
        img.tag=1000+i;
        [self.scrImage addSubview:img];
        x+=self.scrImage.frame.size.width;
    }
    
    [self.scrImage setContentSize:CGSizeMake(x, self.scrImage.frame.size.height)];
    [self.pcImage setNumberOfPages:[arrImages count]];
    [self.pcImage setCurrentPage:currentPage];
}

-(IBAction)editProfile:(id)sender
{
    EditProfileVC *editPC=[[EditProfileVC alloc]initWithNibName:@"EditProfileVC" bundle:nil];
    editPC.strStatus=[self.txtAbout.text stringByReplacingOccurrencesOfString:@"Status: " withString:@""];
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:editPC];
    [self presentViewController:navC animated:NO completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = self.scrImage.frame.size.width;
    currentPage = floor((self.scrImage.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pcImage.currentPage = currentPage  ;
    
    if (sender == scrContainer)
    {
        EGOImageView *imgVwCurrent = (EGOImageView *)[self.scrImage viewWithTag:1000+currentPage];
        
        CGFloat yPos = -scrContainer.contentOffset.y;
        if (yPos > 0)
        {
            CGRect imgRect = imgVwCurrent.frame;
            imgRect.origin.x = ScreenSize.width * currentPage -yPos/2;
            imgRect.size.height = HeightScrollView+yPos;
            imgRect.size.width =  ScreenSize.width+yPos;
            imgVwCurrent.frame = imgRect;
            
            CGRect scrImgRect = _scrImage.frame;
            scrImgRect.origin.y =  _scrImage.frame.origin.y;
            scrImgRect.size.height = HeightScrollView+yPos;
            _scrImage.frame = scrImgRect;
            
            CGRect vwDetailRect = vwDetails.frame;
            vwDetailRect.origin.y = scrImgRect.origin.y+scrImgRect.size.height;
            vwDetails.frame = vwDetailRect;
            
            CGRect vwContainerFrame = vwContainer.frame;
            vwContainerFrame.origin.y =scrContainer.contentOffset.y;
            vwContainerFrame.size.height = ScreenSize.height+yPos;
            vwContainer.frame = vwContainerFrame;
        }
    }
   
}

- (IBAction)changePage
{
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrImage.frame.size.width * self.pcImage.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrImage.frame.size;
    [self.scrImage scrollRectToVisible:frame animated:YES];
    //pageControlBeingUsed = YES;
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
