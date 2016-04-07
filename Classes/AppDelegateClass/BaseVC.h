//
//  BaseVC.h
//  Tinder
//
//  Created by Elluminati - macbook on 12/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

#import "LocationHelper.h"
#import "TinderGenericUtility.h"
#import "DBHelper.h"

@interface BaseVC : UIViewController<MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>
{
    
}
//NavigationBar Methods
-(void)addBack:(UINavigationItem*)naviItem;
//Weservice Methods
-(void)updateLocation;
//Utility Methods

//Send Mail
-(void)sendMailSubject:(NSString *)subject toRecipents:(NSArray *)toRecipents withMessage:(NSString *)message;
//Send Message
-(void)sendMessage:(NSString *)message;


@end
