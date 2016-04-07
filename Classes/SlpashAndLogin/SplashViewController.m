//
//  SplashViewController.m
//  Tinder
//
//  Created by Rahul Sharma on 24/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "SplashViewController.h"
#import "LocationHelper.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

@synthesize imageview;

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
    imageview.image= [UIImage imageNamed:@"Default.png"];
    [[LocationHelper sharedObject] startLocationUpdating];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[LocationHelper sharedObject] stopLocationUpdating];
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
