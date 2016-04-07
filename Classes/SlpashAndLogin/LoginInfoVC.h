//
//  LoginInfoVC.h
//  Tinder
//
//  Created by Elluminati - macbook on 08/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginInfoVC : UIViewController
{
    
}
@property(nonatomic,strong)id parent;

@property(nonatomic,weak)IBOutlet UIButton *btnClose;
@property(weak,nonatomic)IBOutlet UIButton *btnFBLogin;

-(IBAction)onClickbtnClose:(id)sender;
-(IBAction)onClickbtnFBLogin:(id)sender;

@end
