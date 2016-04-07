//
//  ProgressIndicator.h
//  HiCab_Passenger
//
//  Created by 3Embed on 14/12/12.
//  Copyright (c) 2012 Mayank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface ProgressIndicator : NSObject<MBProgressHUDDelegate>
{
    UIView *onView;
    MBProgressHUD *HUD;
}
@property(nonatomic,strong)UIView *onView;
@property(nonatomic,strong)NSString *displayMessage;


+ (id)sharedInstance;
-(void)showPIOnView:(UIView*)view withMessage:(NSString*)message;
-(void)showMessage:(NSString*)message On:(UIView*)view;
-(void)hideProgressIndicator;
-(MBProgressHUD*)getSharedInstace;
-(void)changePIMessage:(NSString*)_newMessage;
-(void)showPIOnWindow:(UIWindow*)window withMessge:(NSString*)message;
-(void)showtoastOnWindow:(UIWindow*)window withMessge:(NSString*)message;
//- (void)registerForKVO;
//- (void)unregisterFromKVO;
@end
