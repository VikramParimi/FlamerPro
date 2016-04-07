//
//  AppSettingsViewController.h
//  Karmic
//
//  Created by AC on 20/11/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface AppSettingsViewController : BaseVC
{
    NSUserDefaults *stdDefaults;
}

- (IBAction)logoutSession:(id)sender;


@end
