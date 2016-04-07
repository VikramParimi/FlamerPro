//
//  BaseVC.m
//  Tinder
//
//  Created by Elluminati - macbook on 12/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "BaseVC.h"

@interface BaseVC ()

@end

@implementation BaseVC

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
}

#pragma mark -
#pragma mark - NavigationBar Methods

-(void)addBack:(UINavigationItem*)naviItem
{
    UIImage *imgButton = [UIImage imageNamed:@"chat_icon_off_line.png"];
	UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightbarbutton setFrame:CGRectMake(0, 0, imgButton.size.width+20, imgButton.size.height)];
    [rightbarbutton setTitle:@"Back" forState:UIControlStateNormal];
    [rightbarbutton addTarget:self action:@selector(buttonBackPressed:) forControlEvents:UIControlEventTouchUpInside];
    naviItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
}

- (void)buttonBackPressed:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - LocationService

-(void)updateLocation
{
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:flStrForStr([[UserDefaultHelper sharedObject] currentLatitude]) forKey:PARAM_ENT_CURR_LAT];
    [dictParam setObject:flStrForStr([[UserDefaultHelper sharedObject] currentLongitude]) forKey:PARAM_ENT_CURR_LONG];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_UPDATELOCATIONS withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response) {
            
        }
    }];
}

#pragma mark -
#pragma mark - Utility Methods

#pragma mark -
#pragma mark - Send Mail

-(void)sendMailSubject:(NSString *)subject toRecipents:(NSArray *)toRecipents withMessage:(NSString *)message
{
    if ([MFMailComposeViewController canSendMail])
    {
        NSMutableDictionary* navBarTitleAttributes = [[UINavigationBar appearance] titleTextAttributes].mutableCopy;
        UIFont *navBarTitleFont = navBarTitleAttributes[UITextAttributeFont];
        navBarTitleAttributes[UITextAttributeFont] = [UIFont systemFontOfSize:navBarTitleFont.pointSize];
        [[UINavigationBar appearance] setTitleTextAttributes:navBarTitleAttributes];
        MFMailComposeViewController *  mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        [mailer setSubject:subject];
       
        [mailer setMessageBody:message isHTML:YES];
        [mailer setToRecipients:toRecipents];
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)sendMessage:(NSString *)message
{
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc] init];
        messageVC.body = message;
        messageVC.messageComposeDelegate = self;
        [self presentViewController:messageVC animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the message sending."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark -
#pragma mark - MFMailComposeViewController Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0){
    [self dismissViewControllerAnimated:YES completion:nil];
    if (result == MFMailComposeResultCancelled){
        DLog(@"Message cancelled");
    }else if (result == MFMailComposeResultSent){
        DLog(@"Message sent");
    }else{
        DLog(@"Message failed");
    }
}

#pragma mark -
#pragma mark - MFMessageComposeViewController Delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultCancelled)
        DLog(@"Message cancelled");
    else if (result == MessageComposeResultSent)
        DLog(@"Message sent");
    else
        DLog(@"Message failed")  ;
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
