//
//  PlaceHolderTextView.h
//  PyaarIO
//
//  Created by iGlobe-9 on 17/11/14.
//  Copyright (c) 2014 Doubbletap. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end