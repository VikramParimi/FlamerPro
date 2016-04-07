//
//  CellQuestion.m
//  Tinder
//
//  Created by Elluminati - macbook on 04/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "CellQuestion.h"

#import "Question.h"

#define X_OPT 10
#define X_ANS 40
#define W_OPT 30
#define W_ANS 260

@implementation CellQuestion

#pragma mark -
#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initAllViews];
    }
    return self;
}

#pragma mark -
#pragma mark - Methods

-(void)initAllViews
{
    lblQuestion=[[UILabel alloc]initWithFrame:CGRectMake(10, 10, 300, 20)];
    lblQuestion.font=[UIFont boldSystemFontOfSize:16.0];
    lblQuestion.numberOfLines=0;
    lblQuestion.backgroundColor=[UIColor clearColor];
    [self.contentView addSubview:lblQuestion];
    
    lblOpt1=[[UILabel alloc]initWithFrame:CGRectMake(X_OPT, 10, W_OPT, 20)];
    lblOpt1.numberOfLines=0;
    lblOpt1.backgroundColor=[UIColor clearColor];
    lblOpt1.text=@"A.";
    [self.contentView addSubview:lblOpt1];
    
    lblOpt2=[[UILabel alloc]initWithFrame:CGRectMake(X_OPT, 10, W_OPT, 20)];
    lblOpt2.numberOfLines=0;
    lblOpt2.backgroundColor=[UIColor clearColor];
    lblOpt2.text=@"B.";
    [self.contentView addSubview:lblOpt2];
    
    lblOpt3=[[UILabel alloc]initWithFrame:CGRectMake(X_OPT, 10, W_OPT, 20)];
    lblOpt3.numberOfLines=0;
    lblOpt3.backgroundColor=[UIColor clearColor];
    lblOpt3.text=@"C.";
    [self.contentView addSubview:lblOpt3];
    
    lblOpt4=[[UILabel alloc]initWithFrame:CGRectMake(X_OPT, 10, W_OPT, 20)];
    lblOpt4.numberOfLines=0;
    lblOpt4.backgroundColor=[UIColor clearColor];
    lblOpt4.text=@"D.";
    [self.contentView addSubview:lblOpt4];
    
    lblAns1=[[UILabel alloc]initWithFrame:CGRectMake(X_ANS, 10, W_ANS, 20)];
    lblAns1.numberOfLines=0;
    lblAns1.backgroundColor=[UIColor clearColor];
    [self.contentView addSubview:lblAns1];
    
    lblAns2=[[UILabel alloc]initWithFrame:CGRectMake(X_ANS, 10, W_ANS, 20)];
    lblAns2.numberOfLines=0;
    lblAns2.backgroundColor=[UIColor clearColor];
    [self.contentView addSubview:lblAns2];
    
    lblAns3=[[UILabel alloc]initWithFrame:CGRectMake(X_ANS, 10, W_ANS, 20)];
    lblAns3.numberOfLines=0;
    lblAns3.backgroundColor=[UIColor clearColor];
    [self.contentView addSubview:lblAns3];
    
    lblAns4=[[UILabel alloc]initWithFrame:CGRectMake(X_ANS, 10, W_ANS, 20)];
    lblAns4.numberOfLines=0;
    lblAns4.backgroundColor=[UIColor clearColor];
    [self.contentView addSubview:lblAns4];
}

-(void)setCellData:(Question *)data
{
    cellData=data;
    
    lblQuestion.text=cellData.quetion;
    
    lblAns1.text=cellData.option_a;
    lblAns2.text=cellData.option_b;
    lblAns3.text=cellData.option_c;
    lblAns4.text=cellData.option_d;
    
    [self changeLableColor];
    
    [self getCellHeight];
}

-(void)setAllBlack
{
    lblAns1.textColor=lblAns2.textColor=lblAns3.textColor=lblAns4.textColor=[UIColor blackColor];
}

-(void)changeLableColor
{
    NSString *ans=cellData.your_ans;
    if (ans==nil || [ans isEqualToString:@""]) {
        [self setAllBlack];
    }
    else{
        [self setAllBlack];
        switch ([ans intValue]) {
            case 1:
                lblAns1.textColor=[UIColor greenColor];
                break;
            case 2:
                lblAns2.textColor=[UIColor greenColor];
                break;
            case 3:
                lblAns3.textColor=[UIColor greenColor];
                break;
            case 4:
                lblAns4.textColor=[UIColor greenColor];
                break;
                
            default:
                break;
        }
    }
}

-(float)getCellHeight
{
    float height=0.0f;
    //Que
    CGRect rect=lblQuestion.frame;
    rect.size=[self getExpectedLabelSize:lblQuestion For:CGSizeMake(300.0, 999)];
    lblQuestion.frame=rect;
    height=lblQuestion.frame.size.height+20;
    //OptA
    rect=lblAns1.frame;
    rect.size=[self getExpectedLabelSize:lblAns1 For:CGSizeMake(W_ANS, 999)];
    rect.origin.y=height;
    lblAns1.frame=rect;
    if ([cellData.option_a isEqualToString:@""] || cellData.option_a==nil) {
        lblOpt1.hidden=TRUE;
    }else{
        lblOpt1.hidden=FALSE;
        height+=rect.size.height;
    }
    rect=lblOpt1.frame;
    rect.origin.y=lblAns1.frame.origin.y;
    lblOpt1.frame=rect;
    //OptB
    rect=lblAns2.frame;
    rect.size=[self getExpectedLabelSize:lblAns2 For:CGSizeMake(W_ANS, 999)];
    rect.origin.y=height;
    lblAns2.frame=rect;
    if ([cellData.option_b isEqualToString:@""] || cellData.option_b==nil) {
        lblOpt2.hidden=TRUE;
    }else{
        lblOpt2.hidden=FALSE;
        height+=rect.size.height;
    }
    rect=lblOpt2.frame;
    rect.origin.y=lblAns2.frame.origin.y;
    lblOpt2.frame=rect;
    //OptC
    rect=lblAns3.frame;
    rect.size=[self getExpectedLabelSize:lblAns3 For:CGSizeMake(W_ANS, 999)];
    rect.origin.y=height;
    lblAns3.frame=rect;
    if ([cellData.option_c isEqualToString:@""] || cellData.option_c==nil) {
        lblOpt3.hidden=TRUE;
    }else{
        lblOpt3.hidden=FALSE;
        height+=rect.size.height;
    }
    rect=lblOpt3.frame;
    rect.origin.y=lblAns3.frame.origin.y;
    lblOpt3.frame=rect;
    //OptD
    rect=lblAns4.frame;
    rect.size=[self getExpectedLabelSize:lblAns4 For:CGSizeMake(W_ANS, 999)];
    rect.origin.y=height;
    lblAns4.frame=rect;
    if ([cellData.option_d isEqualToString:@""] || cellData.option_d==nil) {
        lblOpt4.hidden=TRUE;
    }else{
        lblOpt4.hidden=FALSE;
        height+=rect.size.height;
    }
    rect=lblOpt4.frame;
    rect.origin.y=lblAns4.frame.origin.y;
    lblOpt4.frame=rect;
    
    height+=10;
    
    rect=self.frame;
    rect.size.height=height;
    self.frame=rect;
    
    return height;
}

-(CGSize)getExpectedLabelSize:(UILabel *)lbl For:(CGSize)maximumLabelSize
{
    CGSize expectedLabelSize = [lbl.text sizeWithFont:lbl.font
                                         constrainedToSize:maximumLabelSize
                                             lineBreakMode:lbl.lineBreakMode];
    return expectedLabelSize;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end

/*
 {
 id = 1;
 "option_a" = "1-25 dates ";
 "option_b" = "3-5 dates";
 "option_c" = "6 or more dates";
 "option_d" = "only after the wedding";
 "pref_a" = 1;
 "pref_b" = 2;
 "pref_c" = 3;
 "pref_d" = 4;
 quetion = "Say you've started seeing someone tou really like.as far as  you're concerned,how long will it take before you have sex?";
 "your_ans" = 3;
 }
 */
