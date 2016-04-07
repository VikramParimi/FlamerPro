//
//  ViewQA.h
//  Tinder
//
//  Created by Elluminati - macbook on 27/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewQA : UIView
{
    NSDictionary *data;
}
@property(nonatomic,strong)id parent;

@property(nonatomic,strong) UILabel *lblQuestion;

//@property(nonatomic,strong) UILabel *lblYou;
//@property(nonatomic,strong) UILabel *lblThem;

@property(nonatomic,strong) UILabel *lblOpt1;
@property(nonatomic,strong) UILabel *lblOpt2;
@property(nonatomic,strong) UILabel *lblOpt3;
@property(nonatomic,strong) UILabel *lblOpt4;

@property(nonatomic,strong) UILabel *lblAns1;
@property(nonatomic,strong) UILabel *lblAns2;
@property(nonatomic,strong) UILabel *lblAns3;
@property(nonatomic,strong) UILabel *lblAns4;

@property(nonatomic,strong) UIButton *btnY1;
@property(nonatomic,strong) UIButton *btnY2;
@property(nonatomic,strong) UIButton *btnY3;
@property(nonatomic,strong) UIButton *btnY4;

/*
@property(nonatomic,strong) UIButton *btnT1;
@property(nonatomic,strong) UIButton *btnT2;
@property(nonatomic,strong) UIButton *btnT3;
@property(nonatomic,strong) UIButton *btnT4;
*/

@property(nonatomic,strong)UIButton *btnSubmit;

-(void)setAllViews:(NSDictionary *)dictData;
 
-(IBAction)onClickBtn:(id)sender;
-(IBAction)onClickSubmit:(id)sender;

@end
