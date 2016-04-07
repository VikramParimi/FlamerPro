//
//  ProgressIndicator.m
//  HiCab_Passenger
//
//  Created by 3Embed on 14/12/12.
//  Copyright (c) 2012 Mayank. All rights reserved.
//

#import "ProgressIndicator.h"

@implementation ProgressIndicator
@synthesize onView;
@synthesize displayMessage;

static ProgressIndicator *pi;

#define DEAFULT_MESSAGE @"Loading.."

+ (id)sharedInstance {
	if (!pi) {
		pi  = [[self alloc] init];
	}
	
	return pi;
}
-(void)showPIOnWindow:(UIWindow*)window withMessge:(NSString*)message
{
    if (HUD) {
        HUD = nil;
    }
    MBProgressHUD *hud = [self getSharedInstace];
   
	[window addSubview:hud];
	
	hud.delegate = self;
    if (message == nil) {
        hud.labelText = DEAFULT_MESSAGE;
    }
	hud.labelText = message;
	
	[hud show:YES];
}
-(void)changePIMessage:(NSString*)_newMessage
{
    MBProgressHUD *hud = [self getSharedInstace];
    if (_newMessage != nil)
        hud.labelText = _newMessage;
    else
        hud.labelText = DEAFULT_MESSAGE;
}
-(void)showPIOnView:(UIView*)view withMessage:(NSString*)message
{
    onView = view;
    MBProgressHUD *hud = [self getSharedInstace];
	[onView addSubview:hud];
	
	hud.delegate = self;
    if (message == nil) {
        hud.labelText = DEAFULT_MESSAGE;
    }
	hud.labelText = message;
	
	[hud show:YES];
    
   
}
-(void)showMessage:(NSString*)message On:(UIView*)view
{
    onView = view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	
	// Configure for text only and offset down
	hud.mode = MBProgressHUDModeText;
	hud.labelText = message;
	hud.margin = 10.f;
	hud.yOffset = 50.f;
	hud.removeFromSuperViewOnHide = YES;
	
	[hud hide:YES afterDelay:2];
}

-(void)showtoastOnWindow:(UIWindow*)window withMessge:(NSString*)message
{
    
    onView = window;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:onView animated:YES];
	
	// Configure for text only and offset down
	hud.mode = MBProgressHUDModeText;
	hud.labelText = message;
	hud.margin = 10.f;
	hud.yOffset = 50.f;
	hud.removeFromSuperViewOnHide = YES;
	
	[hud hide:YES afterDelay:2];

    
//    if (HUD) {
//        HUD = nil;
//    }
//    MBProgressHUD *hud = [self getSharedInstace];
//    
//	[window addSubview:hud];
//	
//	hud.delegate = self;
//    if (message == nil) {
//        hud.labelText = DEAFULT_MESSAGE;
//    }
//	hud.labelText = message;
//	
//	[hud show:YES];
}

-(MBProgressHUD*)getSharedInstace
{
    if (!HUD)
    {
        HUD = [[MBProgressHUD alloc] init];
        return HUD;
    }
    return HUD;
}

- (IBAction)showWithLabel:(NSString*)msg
{
	MBProgressHUD *hud = [self getSharedInstace];
	[onView addSubview:hud];
	
	hud.delegate = self;
    if (msg == nil)
    {
        hud.labelText = DEAFULT_MESSAGE;
    }
	hud.labelText = msg;
	
	[hud show:YES];
}
-(void)hideProgressIndicator
{
//    NSLog(@"removed");
    MBProgressHUD *hud = [self getSharedInstace];
    [hud hide:YES];
}


#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
    NSLog(@"removed");
	[HUD removeFromSuperview];
	
	HUD = nil;
}
@end
