//
//  MenuViewController.h
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "BaseVC.h"

#import "SettingsViewController.h"
#import "AppSettingsViewController.h"
#import "Helper.h"
#import "HomeViewController.h"
#import "UIImageView+Download.h"
#import "QuestionVC.h"
#import "ProfileVC.h"
#import <AVFoundation/AVFoundation.h>

@interface MenuViewController : BaseVC<UIActionSheetDelegate,UIScrollViewDelegate>
{
    IBOutlet UIButton *btnProfile;
}
-(IBAction)btnAction:(id)sender;

@end

@interface UIImage (Blur)
-(UIImage *)boxblurImageWithBlur:(CGFloat)blur;
@end