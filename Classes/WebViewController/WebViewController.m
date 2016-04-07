//
//  WebViewController.m
//  snapchatclone
//
//  Created by soumya ranjan sahu on 25/11/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    
    [_lblTitle setText:self.typeString];
    NSURL *webUrl;
    
    if ([self.typeString isEqualToString:@"Privacy Policy"]) {
        
        webUrl = [NSURL URLWithString:@"http://104.236.104.6/flamerpro_web/privacy.html"];
    }
    else if ([self.typeString isEqualToString:@"Terms of Service"]) {
        
        webUrl = [NSURL URLWithString:@"http://104.236.104.6/flamerpro_web/terms.html"];
    }
    
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi showPIOnView:self.view withMessage:@"Loading"];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:webUrl]];
    // Do any additional setup after loading the view from its nib.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi hideProgressIndicator];
}

- (IBAction)btnBackTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
