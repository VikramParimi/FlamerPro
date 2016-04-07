//
//  ADCircularMenuViewController.h
//  iOSCircularMenu
//
//  Created by Aditya Deshmane on 19/10/14.
//  Copyright (c) 2014 Aditya Deshmane. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ADCircularMenuDelegate<NSObject>

@optional

//callback provides button index
- (void)circularMenuClickedButtonAtIndex:(int) buttonIndex;

@end


@interface ADCircularMenuViewController : UIViewController

@property(nonatomic) id <ADCircularMenuDelegate> delegateCircularMenu;
@property (nonatomic,retain) NSMutableArray *arrButtons;

//custom initialization only this should be called to init custom control
-(id)initWithMenuButtonImageNameArray:(NSArray*) arrImage andCornerButtonImageName:(NSString*) strCornerButtonImageName onView:(UIView *)view;

//shows menus
-(void)show;

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
